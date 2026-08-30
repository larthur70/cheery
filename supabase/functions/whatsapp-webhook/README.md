# WhatsApp webhook (Meta)

Function: `whatsapp-webhook`  
Auth: **none** (`--no-verify-jwt`). Validates `hub.verify_token` (GET) and `X-Hub-Signature-256` (POST) with `META_APP_SECRET`.

## GET

Meta subscription challenge using `META_WEBHOOK_VERIFY_TOKEN`.

## POST

Handles:

- `message_template_status_update` → updates `templates.approval_status`, inserts `whatsapp_template_events`, FCM on `APPROVED`
- message `statuses` → updates `whatsapp_message_logs`

## Deploy

```bash
supabase functions deploy whatsapp-webhook --no-verify-jwt
```

Webhook URL:

`https://<project-ref>.supabase.co/functions/v1/whatsapp-webhook`
