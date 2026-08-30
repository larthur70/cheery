# WhatsApp OAuth callback

Function: `whatsapp-oauth-callback`  
Auth: **User JWT**

Persists WhatsApp Business connection on `profiles` via service role.

## Body

```json
{
  "code": optional OAuth code from Meta redirect,
  "phone_number_id": optional,
  "waba_id": optional,
  "display_phone": optional
}
```

- With `META_APP_ID` + `META_APP_SECRET`: **requires** `code` and exchanges it for an access token. Phone / WABA ids come from Graph discovery (body ids are fallback only).
- Without Meta (local): accepts `phone_number_id` + `waba_id` (+ `display_phone`) from the mock connect URL and stores `dev_token`.

## WABA change

If the profile already had a `whatsapp_business_account_id` and the new `waba_id` is **different**:

1. All non-`draft` templates for that user → `draft` (clears Meta name/id/dates/rejection)
2. Audit rows in `whatsapp_template_events` (`event_type = waba_changed_reset`)
3. All clients with `automatic_enabled = true` → `false`

First connect (`null` → WABA) and reconnect to the **same** WABA do **not** reset templates.

## Response

```json
{ "ok": true, "waba_changed": false, "templates_reset": 0 }
```

or `{ "error": "..." }`
