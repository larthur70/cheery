-- Allows the app to distinguish "account not found" vs "wrong password"
-- on login/password-reset (intentional email existence check for clearer UX).

CREATE OR REPLACE FUNCTION public.email_is_registered(p_email text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = auth, public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users u
    WHERE lower(u.email) = lower(trim(p_email))
  );
$$;

REVOKE ALL ON FUNCTION public.email_is_registered(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.email_is_registered(text) TO anon, authenticated;

COMMENT ON FUNCTION public.email_is_registered(text) IS
  'Returns true if auth.users has this email. Used for clearer auth error messages.';
