-- Allow authenticated users to check if they already joined the Pro waitlist.

CREATE OR REPLACE FUNCTION public.is_on_pro_waitlist()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  uid uuid := auth.uid();
  mail text;
BEGIN
  IF uid IS NULL THEN
    RETURN false;
  END IF;

  mail := lower(trim(coalesce(auth.jwt() ->> 'email', '')));

  RETURN EXISTS (
    SELECT 1
    FROM public.pro_waitlist w
    WHERE (w.user_id IS NOT NULL AND w.user_id = uid)
       OR (mail <> '' AND w.email = mail)
  );
END;
$$;

REVOKE ALL ON FUNCTION public.is_on_pro_waitlist() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_on_pro_waitlist() TO authenticated;
