# delete-account

Permanently deletes the user's Auth account after **email confirmation**.
Works for Google/Apple (OAuth) and email/password accounts — no password required.

## Auth

Gateway JWT verification is **off** (`verify_jwt = false`). Auth is handled in-handler:

| Action | Auth | Body |
|--------|------|------|
| `request` (default) | User JWT required | `{}` or `{ "action": "request" }` |
| `confirm` | One-time email token | `{ "action": "confirm", "token": "…" }` |

## Client flow

1. User confirms intent in the app (no password)
2. `POST /functions/v1/delete-account` with JWT → sends confirmation email
3. User opens the link → app calls confirm with the token
4. Local `signOut` / navigate to login

## Server side — request

1. Resolve user from JWT
2. Invalidate previous unused tokens for that user
3. Store SHA-256 of a random token (`account_deletion_requests`, 1h TTL)
4. Send email via Resend with link  
   Web: `{APP_ORIGIN}/auth/confirm-delete?token=…`  
   Mobile (`return_origin: cheery://`): `{APP_ORIGIN}/open.html?to=cheery://auth/confirm-delete&token=…`

## Server side — confirm

1. Hash token and look up a non-consumed, non-expired row
2. Mark token consumed (one-time)
3. Delete `clients` then `templates` for the user
4. `auth.admin.deleteUser(userId)` — cascades `profiles` and related rows

## Secrets

```bash
npx supabase secrets set RESEND_API_KEY=re_xxxxxxxx
# Optional overrides (no surrounding quotes in the Dashboard value):
npx supabase secrets set EMAIL_FROM='Cheery <noreply@usecheery.com>'
npx supabase secrets set APP_ORIGIN=https://app.usecheery.com
```

`EMAIL_FROM` must be exactly `email@domain` or `Name <email@domain>`.
If the Dashboard value includes literal quotes (`"Cheery <…>"`), Resend returns 422.
Resend domain must be verified for `usecheery.com` (or whatever you put in `EMAIL_FROM`).

## Email template

Source of truth for copy/design: `supabase/email-templates/confirm-account-deletion.html`.  
The edge function embeds the same HTML via `_shared/email.ts`.
