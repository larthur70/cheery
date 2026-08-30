# WhatsApp connect session

Function: `whatsapp-connect-session`  
Auth: **User JWT** (Pro plan required)

Starts Meta Embedded Signup and sets `profiles.whatsapp_integration_status = connecting`. Returns `{ url }` for the browser/app to open.

When Meta secrets are missing but `SITE_URL` is set, returns a **mock** callback URL so local/dev can complete the flow:

`{SITE_URL}/whatsapp/callback?phone_number_id=dev&waba_id=dev&display_phone=%2B5511999999999`

## Required Edge Function secrets

Set in Supabase Dashboard → Edge Functions → Secrets:

| Secret | Purpose |
|--------|---------|
| `META_APP_ID` | Meta / Facebook App ID (Embedded Signup) |
| `META_APP_SECRET` | App secret (OAuth token exchange + webhook HMAC) |
| `META_WEBHOOK_VERIFY_TOKEN` | Shared verify token for `whatsapp-webhook` GET challenge |
| `WHATSAPP_CONFIG_ID` | Embedded Signup configuration ID from Meta |
| `SITE_URL` | App origin without trailing slash (e.g. `http://localhost:3000`) |
| `CRON_SECRET` | Bearer token for cron jobs (`send-birthday-whatsapp`, optional sync) |
| `FCM_SERVICE_ACCOUNT_JSON` | Firebase service account JSON (template-approved pushes) |
| `FIREBASE_PROJECT_ID` | Optional if `project_id` is inside the service account JSON |

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are provided automatically.

WhatsApp profile columns are updated only via **service role** (protected by `protect_profile_whatsapp_columns` trigger).

## Related functions

| Function | JWT | Role |
|----------|-----|------|
| `whatsapp-connect-session` | yes | Start Embedded Signup / mock connect |
| `whatsapp-oauth-callback` | yes | Persist connection after redirect |
| `whatsapp-disconnect` | yes | Clear WhatsApp fields |
| `whatsapp-submit-template` | yes | Create Meta message template |
| `whatsapp-sync-templates` | yes or CRON | Poll Meta approval status |
| `whatsapp-webhook` | **no** | Meta webhooks (verify + status) |
| `send-birthday-whatsapp` | CRON | Auto-send birthday templates |

## Setup checklist

See [WHATSAPP_SETUP.md](../WHATSAPP_SETUP.md) for secrets, Meta webhook, and smoke tests.

## Deploy

```bash
supabase functions deploy whatsapp-connect-session
supabase functions deploy whatsapp-oauth-callback
supabase functions deploy whatsapp-disconnect
supabase functions deploy whatsapp-submit-template
supabase functions deploy whatsapp-sync-templates
supabase functions deploy whatsapp-webhook --no-verify-jwt
supabase functions deploy send-birthday-whatsapp
```

## Manual test

```bash
curl -X POST \
  'https://<project-ref>.supabase.co/functions/v1/whatsapp-connect-session' \
  -H "Authorization: Bearer $USER_JWT" \
  -H 'Content-Type: application/json' \
  -d '{}'
```
