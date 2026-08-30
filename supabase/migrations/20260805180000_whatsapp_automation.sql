-- WhatsApp Business Cloud API automation: profiles, templates, clients, audit/logs

-- ---------------------------------------------------------------------------
-- profiles: connection state (token protected like billing columns)
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS whatsapp_connected boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS whatsapp_integration_status text NOT NULL DEFAULT 'disconnected',
  ADD COLUMN IF NOT EXISTS whatsapp_phone_number_id text,
  ADD COLUMN IF NOT EXISTS whatsapp_business_account_id text,
  ADD COLUMN IF NOT EXISTS whatsapp_display_phone text,
  ADD COLUMN IF NOT EXISTS whatsapp_access_token text,
  ADD COLUMN IF NOT EXISTS whatsapp_token_expires_at timestamptz,
  ADD COLUMN IF NOT EXISTS whatsapp_connected_at timestamptz,
  ADD COLUMN IF NOT EXISTS whatsapp_last_error text;

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_whatsapp_integration_status_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_whatsapp_integration_status_check
  CHECK (
    whatsapp_integration_status IN (
      'disconnected',
      'connecting',
      'connected',
      'error',
      'needs_reauth'
    )
  );

CREATE OR REPLACE FUNCTION public.protect_profile_whatsapp_columns()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF coalesce(auth.role(), '') = 'service_role' THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.whatsapp_connected := false;
    NEW.whatsapp_integration_status := 'disconnected';
    NEW.whatsapp_phone_number_id := NULL;
    NEW.whatsapp_business_account_id := NULL;
    NEW.whatsapp_display_phone := NULL;
    NEW.whatsapp_access_token := NULL;
    NEW.whatsapp_token_expires_at := NULL;
    NEW.whatsapp_connected_at := NULL;
    NEW.whatsapp_last_error := NULL;
    RETURN NEW;
  END IF;

  NEW.whatsapp_connected := OLD.whatsapp_connected;
  NEW.whatsapp_integration_status := OLD.whatsapp_integration_status;
  NEW.whatsapp_phone_number_id := OLD.whatsapp_phone_number_id;
  NEW.whatsapp_business_account_id := OLD.whatsapp_business_account_id;
  NEW.whatsapp_display_phone := OLD.whatsapp_display_phone;
  NEW.whatsapp_access_token := OLD.whatsapp_access_token;
  NEW.whatsapp_token_expires_at := OLD.whatsapp_token_expires_at;
  NEW.whatsapp_connected_at := OLD.whatsapp_connected_at;
  NEW.whatsapp_last_error := OLD.whatsapp_last_error;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_whatsapp_columns_trg ON public.profiles;
CREATE TRIGGER protect_profile_whatsapp_columns_trg
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_whatsapp_columns();

-- App-facing view without access token
CREATE OR REPLACE VIEW public.profiles_app
WITH (security_invoker = true)
AS
SELECT
  id,
  full_name,
  company_name,
  plan,
  created_at,
  notifications_enabled,
  notification_time,
  timezone,
  stripe_customer_id,
  stripe_subscription_id,
  subscription_status,
  current_period_end,
  whatsapp_connected,
  whatsapp_integration_status,
  whatsapp_phone_number_id,
  whatsapp_business_account_id,
  whatsapp_display_phone,
  whatsapp_connected_at,
  whatsapp_last_error
FROM public.profiles;

GRANT SELECT ON public.profiles_app TO authenticated;
GRANT SELECT ON public.profiles_app TO anon;

-- ---------------------------------------------------------------------------
-- templates: Meta approval lifecycle
-- ---------------------------------------------------------------------------
ALTER TABLE public.templates
  ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS meta_template_name text,
  ADD COLUMN IF NOT EXISTS meta_template_id text,
  ADD COLUMN IF NOT EXISTS submitted_at timestamptz,
  ADD COLUMN IF NOT EXISTS approved_at timestamptz,
  ADD COLUMN IF NOT EXISTS rejected_reason text,
  ADD COLUMN IF NOT EXISTS meta_category text NOT NULL DEFAULT 'UTILITY',
  ADD COLUMN IF NOT EXISTS meta_language text NOT NULL DEFAULT 'pt_BR';

ALTER TABLE public.templates
  DROP CONSTRAINT IF EXISTS templates_approval_status_check;

ALTER TABLE public.templates
  ADD CONSTRAINT templates_approval_status_check
  CHECK (
    approval_status IN ('draft', 'pending_approval', 'approved', 'rejected')
  );

CREATE INDEX IF NOT EXISTS idx_templates_user_approval_status
  ON public.templates (user_id, approval_status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_templates_user_meta_name
  ON public.templates (user_id, meta_template_name)
  WHERE meta_template_name IS NOT NULL;

-- ---------------------------------------------------------------------------
-- clients: per-client automation flag
-- ---------------------------------------------------------------------------
ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS automatic_enabled boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.enforce_client_automatic_rules()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  connected boolean;
  tmpl_status text;
BEGIN
  IF NEW.automatic_enabled IS NOT TRUE THEN
    RETURN NEW;
  END IF;

  SELECT whatsapp_connected INTO connected
  FROM public.profiles
  WHERE id = NEW.user_id;

  IF coalesce(connected, false) IS NOT TRUE THEN
    RAISE EXCEPTION 'Ative a integração WhatsApp antes de usar automação.'
      USING ERRCODE = 'P0001';
  END IF;

  SELECT approval_status INTO tmpl_status
  FROM public.templates
  WHERE id = NEW.template_id AND user_id = NEW.user_id;

  IF tmpl_status IS DISTINCT FROM 'approved' THEN
    RAISE EXCEPTION 'Para automação, escolha um template aprovado pela Meta.'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_client_automatic_rules_trg ON public.clients;
CREATE TRIGGER enforce_client_automatic_rules_trg
  BEFORE INSERT OR UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_client_automatic_rules();

-- ---------------------------------------------------------------------------
-- Audit + message logs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.whatsapp_template_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  template_id uuid REFERENCES public.templates (id) ON DELETE SET NULL,
  event_type text NOT NULL,
  previous_status text,
  new_status text,
  payload jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_template_events_user
  ON public.whatsapp_template_events (user_id, created_at DESC);

ALTER TABLE public.whatsapp_template_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS whatsapp_template_events_select_own ON public.whatsapp_template_events;
CREATE POLICY whatsapp_template_events_select_own
  ON public.whatsapp_template_events
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.whatsapp_message_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  client_id uuid NOT NULL REFERENCES public.clients (id) ON DELETE CASCADE,
  template_id uuid REFERENCES public.templates (id) ON DELETE SET NULL,
  meta_message_id text,
  status text NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'sent', 'delivered', 'read', 'failed')),
  error text,
  sent_for_year integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_whatsapp_message_logs_client_year
  ON public.whatsapp_message_logs (client_id, sent_for_year)
  WHERE status IN ('queued', 'sent', 'delivered', 'read');

CREATE INDEX IF NOT EXISTS idx_whatsapp_message_logs_user
  ON public.whatsapp_message_logs (user_id, created_at DESC);

ALTER TABLE public.whatsapp_message_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS whatsapp_message_logs_select_own ON public.whatsapp_message_logs;
CREATE POLICY whatsapp_message_logs_select_own
  ON public.whatsapp_message_logs
  FOR SELECT
  USING (auth.uid() = user_id);
