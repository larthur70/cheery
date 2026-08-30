-- Track product tour completion after first signup.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean NOT NULL DEFAULT false;

-- Existing accounts skip the tour.
UPDATE public.profiles
SET onboarding_completed = true
WHERE onboarding_completed = false;

DROP VIEW IF EXISTS public.profiles_app;

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
  whatsapp_last_error,
  onboarding_completed
FROM public.profiles;

GRANT SELECT ON public.profiles_app TO authenticated;
GRANT SELECT ON public.profiles_app TO anon;
