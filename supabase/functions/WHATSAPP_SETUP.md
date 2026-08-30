# WhatsApp automation — setup checklist

Infra no Supabase (já feito):

- [x] Migrations de schema (`whatsapp_automation`, default `automatic_enabled = false`)
- [x] Edge functions deployadas (7)
- [x] Crons `pg_cron` + `pg_net`:
  - `whatsapp-sync-templates` — a cada 30 min
  - `send-birthday-whatsapp` — a cada 15 min
  - Ambos usam o Vault secret existente `birthday_reminders_cron_secret` (= Edge secret `CRON_SECRET`)
- [x] Hardening: triggers `SECURITY DEFINER` sem `EXECUTE` para `anon`/`authenticated`
- [x] App Flutter (domain/data/presentation) + rotas + import Automático

## O que você precisa configurar

### 1. Edge Function secrets

Dashboard → Project Settings → Edge Functions → Secrets  
(ou CLI `supabase secrets set …`)

| Secret | Obrigatório? | Notas |
|--------|--------------|--------|
| `SITE_URL` | Sim (mesmo sem Meta) | Origem do app sem barra final. Ex.: `http://localhost:3000` em dev; URL de produção depois. Usado pelo OAuth callback e pelo mock connect. |
| `CRON_SECRET` | Já deve existir | Deve ser **igual** ao Vault `birthday_reminders_cron_secret` (já usado por `send-birthday-reminders`). |
| `FCM_SERVICE_ACCOUNT_JSON` | Já deve existir | Reaproveitado para push “Template aprovado”. |
| `FIREBASE_PROJECT_ID` | Opcional | `cheery-28b8a` se não estiver no JSON. |
| `META_APP_ID` | Para produção Meta | Sem isso o fluxo roda em **mock** (IDs `dev`). |
| `META_APP_SECRET` | Para produção Meta | OAuth + HMAC do webhook. |
| `WHATSAPP_CONFIG_ID` | Para Embedded Signup | Config ID do Embedded Signup no Meta. |
| `META_WEBHOOK_VERIFY_TOKEN` | Para webhook Meta | String que você inventa e cola também no painel Meta. |

Sem Meta: basta `SITE_URL` (+ `CRON_SECRET`/`FCM` já existentes) para testar UI e mock connect.

### 2. Webhook na Meta (só produção)

Callback URL:

```text
https://<project-ref>.supabase.co/functions/v1/whatsapp-webhook
```

- Verify token = valor de `META_WEBHOOK_VERIFY_TOKEN`
- Campos: `message_template_status_update`, `messages` (status de entrega)
- App deve assinar com o App Secret (= `META_APP_SECRET`)

### 3. Meta Embedded Signup / OAuth

- Redirect URI: `{SITE_URL}/whatsapp/callback`
  On a phone with the app installed, that HTTPS page opens `cheery://whatsapp/callback` so the native app finishes the connect.
- Cadastrar a mesma URI no app Meta
- Escopos / produto WhatsApp Business Platform conforme doc Meta

### 4. Smoke test local (mock)

1. Conta Pro no app
2. Home → Integrar com WhatsApp → concluir onboarding
3. Callback mock marca `whatsapp_connected`
4. Templates → Enviar para aprovação → status `pending_approval` (mock)
5. No SQL Editor (só teste): `UPDATE templates SET approval_status = 'approved', approved_at = now() WHERE id = '…';`
6. Cliente com Automático = on + template aprovado

**Troca de WABA:** ao conectar com um `waba_id` diferente do último salvo no perfil, templates não-`draft` voltam para `draft`, Meta IDs são limpos e a automação dos clientes é desligada. O disconnect **mantém** o último `whatsapp_business_account_id` só para detectar essa troca; reconectar a mesma WABA não reseta.

### 5. Smoke test cron (opcional)

```bash
curl -X POST \
  'https://<project-ref>.supabase.co/functions/v1/send-birthday-whatsapp' \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H 'Content-Type: application/json' \
  -d '{}'
```

```bash
curl -X POST \
  'https://<project-ref>.supabase.co/functions/v1/whatsapp-sync-templates' \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H 'Content-Type: application/json' \
  -d '{}'
```

## Observação Auth (opcional)

Advisor restante: **Leaked Password Protection** desabilitado no Auth.  
Ative em Dashboard → Authentication → Providers → Email → Password strength se quiser.
