# WhatsApp sync templates

Function: `whatsapp-sync-templates`  
Auth: **User JWT** or `Authorization: Bearer CRON_SECRET`  
Cron: every 30 minutes (`whatsapp-sync-templates` via `pg_cron` + `pg_net`)  
Vault secret: `birthday_reminders_cron_secret` (same as Edge `CRON_SECRET`)

URL: `https://ssgyoystsndmodubaqlh.supabase.co/functions/v1/whatsapp-sync-templates`

## Body (optional)

```json
{ "template_id": "<uuid>" }
```

Polls Graph for `pending_approval` templates. On Meta `APPROVED`, sets approved + `approved_at` and sends an FCM push (`data.route = "/templates"`).

Without Meta configured, returns `{ updated: 0 }` and leaves rows as-is.

## Response

`{ "updated": number }`
