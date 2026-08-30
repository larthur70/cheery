-- Stripe billing columns on profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS stripe_customer_id text,
  ADD COLUMN IF NOT EXISTS stripe_subscription_id text,
  ADD COLUMN IF NOT EXISTS subscription_status text,
  ADD COLUMN IF NOT EXISTS current_period_end timestamptz;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_stripe_customer_id_key
  ON public.profiles (stripe_customer_id)
  WHERE stripe_customer_id IS NOT NULL;

-- Prevent clients from changing plan / Stripe fields (service_role webhooks can)
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

DROP TRIGGER IF EXISTS protect_profile_billing_columns_trg ON public.profiles;
CREATE TRIGGER protect_profile_billing_columns_trg
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_billing_columns();

-- Free plan: max 100 clients
CREATE OR REPLACE FUNCTION public.enforce_free_client_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_plan text;
  client_count integer;
BEGIN
  SELECT plan INTO user_plan FROM public.profiles WHERE id = NEW.user_id;
  IF coalesce(user_plan, 'free') <> 'pro' THEN
    SELECT count(*)::integer INTO client_count
    FROM public.clients
    WHERE user_id = NEW.user_id;
    IF client_count >= 100 THEN
      RAISE EXCEPTION 'Limite de 100 clientes do plano Free atingido. Faça upgrade para o Pro.'
        USING ERRCODE = 'P0001';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_free_client_limit_trg ON public.clients;
CREATE TRIGGER enforce_free_client_limit_trg
  BEFORE INSERT ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_free_client_limit();

-- Free plan: only default template may be created
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
