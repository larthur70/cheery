-- Unique client phone per user (digits normalized like WhatsAppPhone.normalize).
-- Also removes existing duplicates, keeping the oldest client row.

CREATE OR REPLACE FUNCTION public.client_phone_digits(phone text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN digits IS NULL OR digits = '' THEN NULL
    WHEN digits ~ '^55\d{10,11}$' THEN digits
    WHEN length(digits) IN (10, 11) THEN '55' || digits
    ELSE NULL
  END
  FROM (
    SELECT regexp_replace(COALESCE(phone, ''), '\D', '', 'g') AS digits
  ) s;
$$;

-- Reassign message logs from duplicate clients to the kept (oldest) client.
UPDATE public.whatsapp_message_logs AS logs
SET client_id = keeper.id
FROM public.clients AS dup
JOIN LATERAL (
  SELECT c.id
  FROM public.clients AS c
  WHERE c.user_id = dup.user_id
    AND public.client_phone_digits(c.phone) = public.client_phone_digits(dup.phone)
  ORDER BY c.created_at ASC, c.id ASC
  LIMIT 1
) AS keeper ON true
WHERE logs.client_id = dup.id
  AND dup.id <> keeper.id
  AND public.client_phone_digits(dup.phone) IS NOT NULL;

-- Delete newer duplicate client rows.
DELETE FROM public.clients AS dup
WHERE public.client_phone_digits(dup.phone) IS NOT NULL
  AND dup.id <> (
    SELECT c.id
    FROM public.clients AS c
    WHERE c.user_id = dup.user_id
      AND public.client_phone_digits(c.phone) = public.client_phone_digits(dup.phone)
    ORDER BY c.created_at ASC, c.id ASC
    LIMIT 1
  )
  AND EXISTS (
    SELECT 1
    FROM public.clients AS other
    WHERE other.user_id = dup.user_id
      AND other.id <> dup.id
      AND public.client_phone_digits(other.phone) = public.client_phone_digits(dup.phone)
  );

CREATE UNIQUE INDEX IF NOT EXISTS clients_user_phone_digits_key
  ON public.clients (user_id, (public.client_phone_digits(phone)))
  WHERE public.client_phone_digits(phone) IS NOT NULL;
