# WhatsApp submit template

Function: `whatsapp-submit-template`  
Auth: **User JWT** (Pro + WhatsApp connected)

## Body

```json
{ "template_id": "<uuid>" }
```

Creates a message template on Graph `POST /{waba_id}/message_templates`, then sets `approval_status=pending_approval`, `submitted_at`, and `meta_template_name`.

Without Meta configured (or `waba_id=dev`), marks `pending_approval` locally so the UI can continue.

## Response

`{ "ok": true }` or `{ "error": "..." }`
