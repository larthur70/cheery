-- Security: hide WhatsApp tokens, lock template Meta columns, close Free
-- template bypass, drop email enumeration RPC.
-- Scale: birthday month/day columns + indexes for cron/list filters.

-- ---------------------------------------------------------------------------
-- profiles: authenticated must not read access tokens
-- SELECT * on profiles fails for clients; they must list columns or use
-- profiles_app. Service role (Edge Functions) is unaffected.
-- ---------------------------------------------------------------------------
REVOKE SELECT (whatsapp_access_token, whatsapp_token_expires_at)
  ON public.profiles
  FROM PUBLIC, anon, authenticated;

REVOKE SELECT ON public.profiles_app FROM anon;

-- ---------------------------------------------------------------------------
-- templates: only service_role may set approval / Meta ids
-- Content edits by the owner reset the template to draft.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.protect_template_meta_columns()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  content_changed boolean;
BEGIN
  IF coalesce(auth.role(), '') = 'service_role' THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.approval_status := 'draft';
    NEW.meta_template_name := NULL;
    NEW.meta_template_id := NULL;
    NEW.submitted_at := NULL;
    NEW.approved_at := NULL;
    NEW.rejected_reason := NULL;
    RETURN NEW;
  END IF;

  content_changed :=
    NEW.name IS DISTINCT FROM OLD.name
    OR NEW.message IS DISTINCT FROM OLD.message
    OR NEW.variables IS DISTINCT FROM OLD.variables;

  IF content_changed THEN
    NEW.approval_status := 'draft';
    NEW.meta_template_name := NULL;
    NEW.meta_template_id := NULL;
    NEW.submitted_at := NULL;
    NEW.approved_at := NULL;
    NEW.rejected_reason := NULL;
  ELSE
    NEW.approval_status := OLD.approval_status;
    NEW.meta_template_name := OLD.meta_template_name;
    NEW.meta_template_id := OLD.meta_template_id;
    NEW.submitted_at := OLD.submitted_at;
    NEW.approved_at := OLD.approved_at;
    NEW.rejected_reason := OLD.rejected_reason;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_template_meta_columns_trg ON public.templates;
CREATE TRIGGER protect_template_meta_columns_trg
  BEFORE INSERT OR UPDATE ON public.templates
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_template_meta_columns();

REVOKE ALL ON FUNCTION public.protect_template_meta_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_template_meta_columns() FROM anon;
REVOKE ALL ON FUNCTION public.protect_template_meta_columns() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.protect_template_meta_columns() TO postgres;
GRANT EXECUTE ON FUNCTION public.protect_template_meta_columns() TO service_role;

-- ---------------------------------------------------------------------------
-- Free plan: at most one template (INSERT), including is_default
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_free_template_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_plan text;
  template_count integer;
BEGIN
  SELECT plan INTO user_plan FROM public.profiles WHERE id = NEW.user_id;
  IF coalesce(user_plan, 'free') = 'pro' THEN
    RETURN NEW;
  END IF;

  SELECT count(*)::integer INTO template_count
  FROM public.templates
  WHERE user_id = NEW.user_id;

  IF template_count >= 1 THEN
    RAISE EXCEPTION 'No plano Free só é possível editar o template padrão. Faça upgrade para o Pro.'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_free_template_limit_trg ON public.templates;
CREATE TRIGGER enforce_free_template_limit_trg
  BEFORE INSERT ON public.templates
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_free_template_limit();

-- ---------------------------------------------------------------------------
-- Stop email enumeration via SECURITY DEFINER RPC
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.email_is_registered(text);

-- ---------------------------------------------------------------------------
-- Birthday lookup without loading every client
-- ---------------------------------------------------------------------------
ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS birth_month smallint
    GENERATED ALWAYS AS ((EXTRACT(MONTH FROM birth_date))::smallint) STORED;

ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS birth_day smallint
    GENERATED ALWAYS AS ((EXTRACT(DAY FROM birth_date))::smallint) STORED;

CREATE INDEX IF NOT EXISTS idx_clients_user_birthday
  ON public.clients (user_id, birth_month, birth_day);

CREATE INDEX IF NOT EXISTS idx_whatsapp_message_logs_meta_id
  ON public.whatsapp_message_logs (meta_message_id)
  WHERE meta_message_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_wa_connected_plan
  ON public.profiles (whatsapp_connected, plan)
  WHERE whatsapp_connected = true;
