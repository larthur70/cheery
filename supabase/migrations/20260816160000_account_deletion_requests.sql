-- One-time tokens for email-confirmed account deletion (OAuth-safe).
create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token_hash text not null unique,
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists account_deletion_requests_user_id_idx
  on public.account_deletion_requests (user_id);

create index if not exists account_deletion_requests_expires_at_idx
  on public.account_deletion_requests (expires_at);

alter table public.account_deletion_requests enable row level security;

-- No client policies: only service_role (edge functions) may read/write.
revoke all on table public.account_deletion_requests from anon, authenticated;
grant all on table public.account_deletion_requests to service_role;

comment on table public.account_deletion_requests is
  'Hashed one-time tokens for account-deletion confirmation emails.';
