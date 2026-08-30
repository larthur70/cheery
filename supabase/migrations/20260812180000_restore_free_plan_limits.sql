-- Restore Free plan hard limits (100 clients + default template only).

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

CREATE OR REPLACE FUNCTION public.enforce_free_template_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_plan text;
BEGIN
  IF NEW.is_default IS TRUE THEN
    RETURN NEW;
  END IF;

  SELECT plan INTO user_plan FROM public.profiles WHERE id = NEW.user_id;
  IF coalesce(user_plan, 'free') <> 'pro' THEN
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
