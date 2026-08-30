# Send birthday WhatsApp (Cloud API)

Function: `send-birthday-whatsapp`  
Auth: `Authorization: Bearer CRON_SECRET`  
Cron: every 15 minutes (`send-birthday-whatsapp` via `pg_cron` + `pg_net`)  
Vault secret: `birthday_reminders_cron_secret` (same as Edge `CRON_SECRET`)

URL: `https://<project-ref>.supabase.co/functions/v1/send-birthday-whatsapp`

Mirrors `send-birthday-reminders` timing (`notification_time` + timezone window), but sends approved templates via Graph `POST /{phone_number_id}/messages` for clients with `automatic_enabled`.

## Behaviour

1. Profiles with `whatsapp_connected` + Pro in the notification window  
2. Clients with birthday today and `automatic_enabled`  
3. Template must be `approved` with `meta_template_name`  
4. Skip if `whatsapp_message_logs` already has a non-failed row for `sent_for_year`  
5. Normalize phone with Brazil `55` prefix  
6. Compose body parameters from `template.variables` (`client_name`, `company_name`)  
7. On success: log `sent` + update `clients.message_sent_year`  
8. On failure: log `failed`

## Manual test

```bash
curl -X POST \
  'https://<project-ref>.supabase.co/functions/v1/send-birthday-whatsapp' \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H 'Content-Type: application/json' \
  -d '{}'
```

## Response

```json
{ "ok": true, "due": 0, "attempted": 0, "sent": 0, "failed": 0, "skipped": 0 }
```
