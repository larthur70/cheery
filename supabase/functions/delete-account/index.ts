// Account deletion via email confirmation (works for Google/Apple and password users).
// verify_jwt = false: confirm step uses a one-time token from the email link.
// Request step still requires a valid user JWT (checked in-handler).

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import { appHandoffUrl, wantsNativeReturn } from "../_shared/native_return.ts";
import { resolveSiteUrl } from "../_shared/site_url.ts";
import {
  buildAccountDeletionEmailHtml,
  sendResendEmail,
} from "../_shared/email.ts";
import {
  AuthError,
  createServiceClient,
  requireUser,
} from "../_shared/supabase.ts";

const TOKEN_TTL_MS = 60 * 60 * 1000; // 1 hour

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const body = (await req.json().catch(() => ({}))) as {
      action?: unknown;
      token?: unknown;
      return_origin?: unknown;
    };
    const action = typeof body.action === "string" ? body.action : "request";
    const token = typeof body.token === "string" ? body.token.trim() : "";

    if (action === "confirm") {
      return await confirmDeletion(token);
    }

    if (action !== "request") {
      return jsonResponse({ error: "Invalid action" }, 400);
    }

    return await requestDeletion(
      req.headers.get("Authorization"),
      wantsNativeReturn(body),
    );
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    console.error("delete-account failed", message);
    return jsonResponse({ error: message }, 500);
  }
});

async function requestDeletion(
  authHeader: string | null,
  nativeReturn: boolean,
): Promise<Response> {
  const { userId, email } = await requireUser(authHeader);
  if (!email) {
    return jsonResponse({ error: "E-mail da conta é obrigatório" }, 400);
  }

  const admin = createServiceClient();
  const rawToken = cryptoRandomToken();
  const tokenHash = await sha256Hex(rawToken);
  const expiresAt = new Date(Date.now() + TOKEN_TTL_MS).toISOString();

  // Invalidate previous unused tokens for this user.
  await admin
    .from("account_deletion_requests")
    .update({ consumed_at: new Date().toISOString() })
    .eq("user_id", userId)
    .is("consumed_at", null);

  const { error: insertError } = await admin
    .from("account_deletion_requests")
    .insert({
      user_id: userId,
      token_hash: tokenHash,
      expires_at: expiresAt,
    });
  if (insertError) {
    console.error("insert deletion token failed", insertError.message);
    return jsonResponse({ error: insertError.message }, 500);
  }

  const appOrigin = resolveSiteUrl() || "https://app.usecheery.com";
  const confirmationUrl = nativeReturn
    ? appHandoffUrl(appOrigin, "cheery://auth/confirm-delete", {
      token: rawToken,
    })
    : `${appOrigin}/auth/confirm-delete?token=${encodeURIComponent(rawToken)}`;

  await sendResendEmail({
    to: email,
    subject: "Confirme a exclusão da sua conta no Cheery",
    html: buildAccountDeletionEmailHtml(confirmationUrl),
  });

  return jsonResponse({ ok: true, email_sent: true });
}

async function confirmDeletion(token: string): Promise<Response> {
  if (!token) {
    return jsonResponse({ error: "Token de confirmação obrigatório" }, 400);
  }

  const admin = createServiceClient();
  const tokenHash = await sha256Hex(token);
  const nowIso = new Date().toISOString();

  const { data: request, error: lookupError } = await admin
    .from("account_deletion_requests")
    .select("id, user_id, expires_at, consumed_at")
    .eq("token_hash", tokenHash)
    .maybeSingle();

  if (lookupError) {
    console.error("lookup deletion token failed", lookupError.message);
    return jsonResponse({ error: lookupError.message }, 500);
  }
  if (!request || request.consumed_at) {
    return jsonResponse(
      { error: "Link de confirmação inválido ou expirado" },
      400,
    );
  }
  if (request.expires_at <= nowIso) {
    return jsonResponse(
      { error: "Link de confirmação inválido ou expirado" },
      400,
    );
  }

  const { data: consumed, error: consumeError } = await admin
    .from("account_deletion_requests")
    .update({ consumed_at: nowIso })
    .eq("id", request.id)
    .is("consumed_at", null)
    .select("id")
    .maybeSingle();

  if (consumeError) {
    console.error("consume deletion token failed", consumeError.message);
    return jsonResponse({ error: consumeError.message }, 500);
  }
  if (!consumed) {
    return jsonResponse(
      { error: "Link de confirmação inválido ou expirado" },
      400,
    );
  }

  const userId = request.user_id as string;

  const { error: clientsError } = await admin
    .from("clients")
    .delete()
    .eq("user_id", userId);
  if (clientsError) {
    console.error("delete clients failed", clientsError.message);
    return jsonResponse({ error: clientsError.message }, 500);
  }

  const { error: templatesError } = await admin
    .from("templates")
    .delete()
    .eq("user_id", userId);
  if (templatesError) {
    console.error("delete templates failed", templatesError.message);
    return jsonResponse({ error: templatesError.message }, 500);
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    console.error("deleteUser failed", deleteError.message);
    return jsonResponse({ error: deleteError.message }, 500);
  }

  return jsonResponse({ ok: true });
}

function cryptoRandomToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

async function sha256Hex(value: string): Promise<string> {
  const data = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(digest), (b) =>
    b.toString(16).padStart(2, "0")
  ).join("");
}
