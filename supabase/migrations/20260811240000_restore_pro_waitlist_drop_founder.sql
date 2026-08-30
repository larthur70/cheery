-- Revert founder/import-quota experiment. Restore Pro waitlist for MVP.

DROP FUNCTION IF EXISTS public.assert_can_import_clients();
DROP FUNCTION IF EXISTS public.record_successful_client_import();
DROP FUNCTION IF EXISTS public.founder_cutoff_at();

DROP VIEW IF EXISTS public.profiles_app;

ALTER TABLE public.profiles
  DROP COLUMN IF EXISTS is_founder,
  DROP COLUMN IF EXISTS completed_import_count;

CREATE OR REPLACE FUNCTION public.protect_profile_billing_columns()
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
    NEW.plan := 'free';
    NEW.stripe_customer_id := NULL;
    NEW.stripe_subscription_id := NULL;
    NEW.subscription_status := NULL;
    NEW.current_period_end := NULL;
    RETURN NEW;
  END IF;

  NEW.plan := OLD.plan;
  NEW.stripe_customer_id := OLD.stripe_customer_id;
  NEW.stripe_subscription_id := OLD.stripe_subscription_id;
  NEW.subscription_status := OLD.subscription_status;
  NEW.current_period_end := OLD.current_period_end;
  RETURN NEW;
END;
$$;

CREATE VIEW public.profiles_app
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

CREATE TABLE IF NOT EXISTS public.pro_waitlist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  source text NOT NULL DEFAULT 'app'
    CHECK (source IN ('app', 'landing')),
  user_id uuid REFERENCES auth.users (id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT pro_waitlist_email_unique UNIQUE (email)
);

CREATE INDEX IF NOT EXISTS pro_waitlist_created_at_idx
  ON public.pro_waitlist (created_at DESC);

ALTER TABLE public.pro_waitlist ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.pro_waitlist FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.pro_waitlist TO service_role;
