# Templates de e-mail (Supabase Auth + exclusão de conta)

HTML no visual do Cheery (blush `#FEF2F2`, cherry `#EF4444`, ink `#1C1212`) com logo em `https://usecheery.com/logo.png`.

## Arquivos

| Arquivo | Onde usar | Subject sugerido |
|---------|-----------|------------------|
| `confirm-signup.html` | Dashboard → **Confirm sign up** | `Confirme seu e-mail no Cheery` |
| `reset-password.html` | Dashboard → **Reset password** | `Redefina sua senha no Cheery` |
| `change-email.html` | Dashboard → **Change Email Address** | `Confirme o novo e-mail no Cheery` |
| `confirm-account-deletion.html` | Edge Function `delete-account` (Resend) | `Confirme a exclusão da sua conta no Cheery` |

## Auth templates (colar no Dashboard)

1. Abra [Authentication → Email Templates](https://supabase.com/dashboard/project/_/auth/templates)
2. Selecione o template
3. Cole o **Subject** da tabela acima
4. Cole o conteúdo HTML do arquivo correspondente no corpo
5. Salve

Variável usada nos templates de Auth: `{{ .ConfirmationURL }}` (link que confirma o cadastro, redefine a senha ou altera o e-mail).

## Alteração de e-mail

Cole `change-email.html` em **Change Email Address** (não em Confirm sign up).

O e-mail vai para o **endereço novo**, não para o atual. Com “Secure email change” ligado, o endereço antigo também pode receber um aviso (template padrão do GoTrue).

Contas que entraram só com **Google** ou **Apple** não conseguem trocar o e-mail no Cheery: o endereço pertence ao provedor. O app bloqueia o campo nesses casos.

Depois de salvar o template, peça uma **nova** alteração (e-mails já enviados continuam com o HTML antigo).

## Exclusão de conta

Não há template nativo no Supabase Auth para exclusão. O HTML em `confirm-account-deletion.html` é a referência visual; a Edge Function envia o mesmo conteúdo via Resend (ver `supabase/functions/delete-account/README.md`).

Link do CTA: no web, `{APP_ORIGIN}/auth/confirm-delete?token=…`. No app, o e-mail usa `{APP_ORIGIN}/open.html?to=cheery://auth/confirm-delete&token=…` para reabrir o Cheery.

## Site URL / Redirect

Em **Authentication → URL Configuration**, confira:

- Site URL: `https://app.usecheery.com`
- Redirect URLs incluindo:
  - `cheery://auth-callback`
  - `https://app.usecheery.com/open.html`
  - `https://app.usecheery.com/open.html?to=cheery://auth-callback`
  - `https://app.usecheery.com/auth/callback`
  - `https://app.usecheery.com/auth/reset-password`
  - `https://app.usecheery.com/auth/confirm-delete`
  - `https://app.usecheery.com/**` (se usar wildcard)
