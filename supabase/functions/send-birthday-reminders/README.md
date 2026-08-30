# Birthday reminders — Edge Function ops

Function: `send-birthday-reminders`  
URL: `https://ssgyoystsndmodubaqlh.supabase.co/functions/v1/send-birthday-reminders`  
Cron: every 15 minutes (`send-birthday-reminders` via `pg_cron` + `pg_net`)

## Required Edge Function secrets

In Supabase Dashboard → Edge Functions → Secrets, set:

1. `CRON_SECRET` — must match Vault secret `birthday_reminders_cron_secret`
2. `FCM_SERVICE_ACCOUNT_JSON` — full JSON of a Firebase service account with Firebase Cloud Messaging API enabled
3. `FIREBASE_PROJECT_ID` — `cheery-28b8a` (optional if `project_id` is inside the JSON)

Without (1) and (2), the cron will call the function but sends will fail.

## Manual test

```bash
curl -X POST \
  'https://ssgyoystsndmodubaqlh.supabase.co/functions/v1/send-birthday-reminders' \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H 'Content-Type: application/json' \
  -d '{}'
```
