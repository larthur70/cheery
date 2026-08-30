# WhatsApp disconnect

Function: `whatsapp-disconnect`  
Auth: **User JWT**

Clears WhatsApp fields on `profiles` (`status=disconnected`, `connected=false`) via service role and sets `clients.automatic_enabled=false` for that user.

## Response

`{ "ok": true }`
