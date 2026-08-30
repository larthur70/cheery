/** Builds the Cheery-branded account-deletion confirmation email HTML. */
export function buildAccountDeletionEmailHtml(confirmationUrl: string): string {
  const safeUrl = escapeHtml(confirmationUrl);
  return `<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="color-scheme" content="light" />
    <title>Confirme a exclusão da conta — Cheery</title>
  </head>
  <body
    style="
      margin: 0;
      padding: 0;
      background-color: #fef2f2;
      font-family:
        -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial,
        sans-serif;
      color: #1c1212;
      -webkit-font-smoothing: antialiased;
    "
  >
    <table
      role="presentation"
      width="100%"
      cellpadding="0"
      cellspacing="0"
      border="0"
      style="background-color: #fef2f2; margin: 0; padding: 0"
    >
      <tr>
        <td align="center" style="padding: 40px 16px">
          <table
            role="presentation"
            width="100%"
            cellpadding="0"
            cellspacing="0"
            border="0"
            style="
              max-width: 520px;
              background-color: #ffffff;
              border-radius: 16px;
              border: 1px solid #fee2e2;
              overflow: hidden;
            "
          >
            <tr>
              <td align="center" style="padding: 32px 32px 8px; background-color: #ffffff">
                <img
                  src="https://usecheery.com/logo.png"
                  alt="Cheery"
                  width="56"
                  height="56"
                  style="display: block; border: 0; outline: none; text-decoration: none; width: 56px; height: 56px"
                />
                <p style="margin: 12px 0 0; font-size: 22px; font-weight: 800; letter-spacing: -0.02em; color: #ef4444; line-height: 1">
                  Cheery
                </p>
              </td>
            </tr>
            <tr>
              <td style="padding: 24px 32px 8px">
                <h1 style="margin: 0 0 12px; font-size: 22px; font-weight: 700; line-height: 1.3; color: #1c1212; letter-spacing: -0.02em">
                  Confirme a exclusão da conta
                </h1>
                <p style="margin: 0 0 16px; font-size: 15px; line-height: 1.6; color: #1c1212; opacity: 0.75">
                  Recebemos um pedido para excluir permanentemente a sua conta
                  no Cheery. Se foi você, clique no botão abaixo para confirmar.
                </p>
                <p style="margin: 0 0 28px; font-size: 15px; line-height: 1.6; color: #1c1212; opacity: 0.75">
                  Esta ação apaga clientes, templates e dados da conta de forma
                  irreversível. O link expira em 1 hora. Se você não solicitou
                  a exclusão, ignore este e-mail — nada será alterado.
                </p>
                <table role="presentation" cellpadding="0" cellspacing="0" border="0" align="center" style="margin: 0 auto 28px">
                  <tr>
                    <td align="center" bgcolor="#ef4444" style="border-radius: 999px; background-color: #ef4444">
                      <a
                        href="${safeUrl}"
                        target="_blank"
                        style="display: inline-block; padding: 14px 28px; font-size: 15px; font-weight: 600; color: #ffffff; text-decoration: none; border-radius: 999px; background-color: #ef4444; line-height: 1"
                      >
                        Excluir minha conta
                      </a>
                    </td>
                  </tr>
                </table>
                <p style="margin: 0 0 8px; font-size: 13px; line-height: 1.55; color: #1c1212; opacity: 0.55">
                  Se o botão não funcionar, copie e cole este link no navegador:
                </p>
                <p style="margin: 0 0 24px; font-size: 12px; line-height: 1.5; word-break: break-all; color: #dc2626">
                  <a href="${safeUrl}" target="_blank" style="color: #dc2626; text-decoration: underline">${safeUrl}</a>
                </p>
                <p style="margin: 0; font-size: 13px; line-height: 1.55; color: #1c1212; opacity: 0.55">
                  Nunca compartilhe este link. A equipe do Cheery nunca pede sua
                  senha por e-mail.
                </p>
              </td>
            </tr>
            <tr>
              <td style="padding: 28px 32px 32px; border-top: 1px solid #fee2e2">
                <p style="margin: 0 0 6px; font-size: 13px; font-weight: 700; color: #ef4444">Cheery</p>
                <p style="margin: 0; font-size: 12px; line-height: 1.5; color: #1c1212; opacity: 0.5">
                  Lembretes de aniversário e mensagens de relacionamento para o
                  seu negócio.
                  <br />
                  <a href="https://usecheery.com" target="_blank" style="color: #dc2626; text-decoration: none">usecheery.com</a>
                </p>
              </td>
            </tr>
          </table>
          <p style="margin: 20px 0 0; font-size: 11px; line-height: 1.5; color: #1c1212; opacity: 0.4; max-width: 520px">
            © Cheery. Este é um e-mail automático — não responda.
          </p>
        </td>
      </tr>
    </table>
  </body>
</html>`;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

const DEFAULT_EMAIL_FROM = "Cheery <noreply@usecheery.com>";

/** Resend accepts `email@domain` or `Name <email@domain>`. */
function resolveEmailFrom(): string {
  const raw = Deno.env.get("EMAIL_FROM")?.trim();
  if (!raw) return DEFAULT_EMAIL_FROM;

  // Secrets set via shell/dashboard often keep wrapping quotes.
  const unquoted = raw.replace(/^(['"])(.*)\1$/, "$2").trim();
  const isPlainEmail = /^[^\s<>]+@[^\s<>]+$/.test(unquoted);
  const isNamedEmail = /^[^<>]+<[^\s<>]+@[^\s<>]+>$/.test(unquoted);
  if (isPlainEmail || isNamedEmail) return unquoted;

  console.error("Invalid EMAIL_FROM secret; using default", raw);
  return DEFAULT_EMAIL_FROM;
}

/** Sends transactional email via Resend (HTTP API). */
export async function sendResendEmail(params: {
  to: string;
  subject: string;
  html: string;
}): Promise<void> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    throw new Error("Missing env: RESEND_API_KEY");
  }
  const from = resolveEmailFrom();

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: [params.to],
      subject: params.subject,
      html: params.html,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    console.error("Resend error", response.status, body);
    throw new Error("Não foi possível enviar o e-mail de confirmação");
  }
}
