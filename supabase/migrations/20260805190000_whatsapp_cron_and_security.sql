-- WhatsApp automation: schedule crons + harden SECURITY DEFINER trigger RPCs.
-- Reuses vault secret birthday_reminders_cron_secret (same value as Edge CRON_SECRET).

-- ---------------------------------------------------------------------------
-- pg_cron: sync pending templates every 30 min
-- ---------------------------------------------------------------------------
SELECT cron.unschedule(jobid)
FROM cron.job
WHERE jobname = 'whatsapp-sync-templates';

SELECT cron.schedule(
  'whatsapp-sync-templates',
  '*/30 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://ssgyoystsndmodubaqlh.supabase.co/functions/v1/whatsapp-sync-templates',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (
        SELECT decrypted_secret
        FROM vault.decrypted_secrets
        WHERE name = 'birthday_reminders_cron_secret'
        LIMIT 1
      )
    ),
    body := '{}'::jsonb
  ) AS request_id;
  $$
);

-- ---------------------------------------------------------------------------
-- pg_cron: send birthday WhatsApp every 15 min (same window as push reminders)
-- ---------------------------------------------------------------------------
SELECT cron.unschedule(jobid)
FROM cron.job
WHERE jobname = 'send-birthday-whatsapp';

SELECT cron.schedule(
  'send-birthday-whatsapp',
  '*/15 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://ssgyoystsndmodubaqlh.supabase.co/functions/v1/send-birthday-whatsapp',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (
        SELECT decrypted_secret
        FROM vault.decrypted_secrets
        WHERE name = 'birthday_reminders_cron_secret'
        LIMIT 1
      )
    ),
    body := '{}'::jsonb
  ) AS request_id;
  $$
);

-- ---------------------------------------------------------------------------
-- Security: trigger-only SECURITY DEFINER functions must not be callable via RPC
-- ---------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.protect_profile_whatsapp_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_profile_whatsapp_columns() FROM anon;
REVOKE ALL ON FUNCTION public.protect_profile_whatsapp_columns() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.protect_profile_whatsapp_columns() TO postgres;
GRANT EXECUTE ON FUNCTION public.protect_profile_whatsapp_columns() TO service_role;

REVOKE ALL ON FUNCTION public.enforce_client_automatic_rules() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enforce_client_automatic_rules() FROM anon;
REVOKE ALL ON FUNCTION public.enforce_client_automatic_rules() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.enforce_client_automatic_rules() TO postgres;
GRANT EXECUTE ON FUNCTION public.enforce_client_automatic_rules() TO service_role;

REVOKE ALL ON FUNCTION public.protect_profile_billing_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_profile_billing_columns() FROM anon;
REVOKE ALL ON FUNCTION public.protect_profile_billing_columns() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.protect_profile_billing_columns() TO postgres;
GRANT EXECUTE ON FUNCTION public.protect_profile_billing_columns() TO service_role;

REVOKE ALL ON FUNCTION public.enforce_free_client_limit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enforce_free_client_limit() FROM anon;
REVOKE ALL ON FUNCTION public.enforce_free_client_limit() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.enforce_free_client_limit() TO postgres;
GRANT EXECUTE ON FUNCTION public.enforce_free_client_limit() TO service_role;

REVOKE ALL ON FUNCTION public.enforce_free_template_limit() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enforce_free_template_limit() FROM anon;
REVOKE ALL ON FUNCTION public.enforce_free_template_limit() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.enforce_free_template_limit() TO postgres;
GRANT EXECUTE ON FUNCTION public.enforce_free_template_limit() TO service_role;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM anon;
REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.rls_auto_enable() TO postgres;
GRANT EXECUTE ON FUNCTION public.rls_auto_enable() TO service_role;

-- Fix mutable search_path on push_tokens trigger helper
CREATE OR REPLACE FUNCTION public.set_push_tokens_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;
