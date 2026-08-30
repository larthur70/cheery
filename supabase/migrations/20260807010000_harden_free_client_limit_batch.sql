-- Harden free-plan client limit for multi-row INSERT and concurrent inserts.
-- AFTER STATEMENT + transition tables sees all new rows; FOR UPDATE serializes per user.

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
    -- Serialize concurrent inserts for this account.
    PERFORM 1 FROM public.profiles WHERE id = rec.user_id FOR UPDATE;

    SELECT plan INTO user_plan FROM public.profiles WHERE id = rec.user_id;
    IF coalesce(user_plan, 'free') = 'pro' THEN
      CONTINUE;
    END IF;

    SELECT count(*)::integer INTO client_count
    FROM public.clients
    WHERE user_id = rec.user_id;

    -- AFTER INSERT: count already includes this statement's rows.
    IF client_count > 100 THEN
      RAISE EXCEPTION 'Limite de 100 clientes do plano Free atingido. Faça upgrade para o Pro.'
        USING ERRCODE = 'P0001';
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS enforce_free_client_limit_trg ON public.clients;

CREATE TRIGGER enforce_free_client_limit_trg
  AFTER INSERT ON public.clients
  REFERENCING NEW TABLE AS new_rows
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.enforce_free_client_limit();
