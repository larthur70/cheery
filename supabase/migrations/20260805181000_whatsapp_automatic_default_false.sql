-- Align automatic_enabled default with app (opt-in) and unblock updates
-- for users who are not yet WhatsApp-connected.

UPDATE public.clients
SET automatic_enabled = false
WHERE automatic_enabled = true;

ALTER TABLE public.clients
  ALTER COLUMN automatic_enabled SET DEFAULT false;
