-- Raise Free plan client limit from 100 to 250.

CREATE OR REPLACE FUNCTION public.enforce_free_client_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  rec record;
  user_plan text;
  client_count integer;
BEGIN
  FOR rec IN
    SELECT DISTINCT user_id FROM new_rows
  LOOP
    PERFORM 1 FROM public.profiles WHERE id = rec.user_id FOR UPDATE;

    SELECT plan INTO user_plan FROM public.profiles WHERE id = rec.user_id;
    IF coalesce(user_plan, 'free') = 'pro' THEN
      CONTINUE;
    END IF;

    SELECT count(*)::integer INTO client_count
    FROM public.clients
    WHERE user_id = rec.user_id;

    IF client_count > 250 THEN
      RAISE EXCEPTION 'Limite de 250 clientes do plano Free atingido. Faça upgrade para o Pro.'
        USING ERRCODE = 'P0001';
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$;
