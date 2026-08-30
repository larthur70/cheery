-- MVP Free: unlimited clients & templates. Pro waitlist for interest capture.

DROP TRIGGER IF EXISTS enforce_free_client_limit_trg ON public.clients;
DROP FUNCTION IF EXISTS public.enforce_free_client_limit();

DROP TRIGGER IF EXISTS enforce_free_template_limit_trg ON public.templates;
DROP FUNCTION IF EXISTS public.enforce_free_template_limit();

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
