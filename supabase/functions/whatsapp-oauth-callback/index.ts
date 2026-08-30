// Completes WhatsApp connection after Embedded Signup / mock callback.
// Auth: user JWT.
// Body: code?, phone_number_id?, waba_id?, display_phone?
// When WABA changes, templates reset to draft and client automation is turned off.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import {
  AuthError,
  createServiceClient,
  requireUser,
} from "../_shared/supabase.ts";
import {
  exchangeCodeForToken,
  graphGet,
  isMetaConfigured,
  siteUrl,
} from "../_shared/whatsapp.ts";

type Body = {
  code?: string;
  phone_number_id?: string;
  waba_id?: string;
  display_phone?: string;
};

/** Best-effort: first WABA + phone number reachable with the user token. */
async function discoverWhatsAppIds(accessToken: string): Promise<{
  phoneNumberId: string | null;
  wabaId: string | null;
  displayPhone: string | null;
}> {
  try {
    const appId = Deno.env.get("META_APP_ID");
    const appSecret = Deno.env.get("META_APP_SECRET");
    if (!appId || !appSecret) {
      return { phoneNumberId: null, wabaId: null, displayPhone: null };
    }
    const appToken = `${appId}|${appSecret}`;
    const debug = await graphGet("/debug_token", appToken, {
      input_token: accessToken,
    });
    const data = (debug.data ?? {}) as Record<string, unknown>;
    const granular =
      (data.granular_scopes as Array<Record<string, unknown>> | undefined) ??
      [];
    for (const scope of granular) {
      const targetIds = (scope.target_ids as string[] | undefined) ?? [];
      for (const wabaId of targetIds) {
        try {
          const phones = await graphGet(`/${wabaId}/phone_numbers`, accessToken, {
            fields: "id,display_phone_number,verified_name",
          });
          const list =
            (phones.data as Array<Record<string, unknown>> | undefined) ?? [];
          const first = list[0];
          if (first?.id) {
            return {
              wabaId,
              phoneNumberId: String(first.id),
              displayPhone:
                typeof first.display_phone_number === "string"
                  ? first.display_phone_number
                  : null,
            };
          }
        } catch {
          // try next target
        }
      }
    }
  } catch {
    // discovery optional
  }
  return { phoneNumberId: null, wabaId: null, displayPhone: null };
}

/**
 * Meta templates are scoped to a WABA. When the account switches WABA,
 * previous approvals no longer apply — reset to draft and disable automation.
 */
async function resetTemplatesForWabaChange(
  admin: SupabaseClient,
  userId: string,
  previousWabaId: string,
  newWabaId: string,
): Promise<number> {
  const { data: templates, error: listError } = await admin
    .from("templates")
    .select("id, approval_status")
    .eq("user_id", userId)
    .neq("approval_status", "draft");

  if (listError) {
    console.error("Failed to list templates for WABA reset", listError.message);
    return 0;
  }

  const rows = (templates ?? []) as Array<{
    id: string;
    approval_status: string;
  }>;

  let resetCount = 0;
  if (rows.length > 0) {
    const { error: updateError } = await admin
      .from("templates")
      .update({
        approval_status: "draft",
        meta_template_name: null,
        meta_template_id: null,
        submitted_at: null,
        approved_at: null,
        rejected_reason: null,
      })
      .eq("user_id", userId)
      .neq("approval_status", "draft");

    if (updateError) {
      console.error("Failed to reset templates on WABA change", updateError.message);
    } else {
      resetCount = rows.length;
      await admin.from("whatsapp_template_events").insert(
        rows.map((template) => ({
          user_id: userId,
          template_id: template.id,
          event_type: "waba_changed_reset",
          previous_status: template.approval_status,
          new_status: "draft",
          payload: {
            previous_waba_id: previousWabaId,
            new_waba_id: newWabaId,
          },
        })),
      );
    }
  }

  const { error: clientsError } = await admin
    .from("clients")
    .update({ automatic_enabled: false })
    .eq("user_id", userId)
    .eq("automatic_enabled", true);

  if (clientsError) {
    console.error(
      "Failed to disable automation on WABA change",
      clientsError.message,
    );
  }

  return resetCount;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { userId } = await requireUser(req.headers.get("Authorization"));
    const body = (await req.json().catch(() => ({}))) as Body;

    let accessToken: string | null = null;
    let expiresAt: string | null = null;
    let phoneNumberId = body.phone_number_id?.trim() || null;
    let wabaId = body.waba_id?.trim() || null;
    let displayPhone = body.display_phone?.trim() || null;

    if (isMetaConfigured()) {
      const code = body.code?.trim();
      if (!code) {
        return jsonResponse(
          { error: "OAuth code is required to connect WhatsApp." },
          400,
        );
      }
      const base = siteUrl();
      if (!base) {
        return jsonResponse({ error: "SITE_URL is not configured." }, 500);
      }
      const token = await exchangeCodeForToken({
        code,
        redirectUri: `${base}/whatsapp/callback`,
      });
      accessToken = token.accessToken;
      if (token.expiresIn) {
        expiresAt = new Date(Date.now() + token.expiresIn * 1000).toISOString();
      }

      const discovered = await discoverWhatsAppIds(accessToken);
      phoneNumberId = discovered.phoneNumberId ?? phoneNumberId;
      wabaId = discovered.wabaId ?? wabaId;
      displayPhone = discovered.displayPhone ?? displayPhone;
    } else if (phoneNumberId && wabaId) {
      // Local-only: Meta secrets are not set.
      accessToken = "dev_token";
    } else if (body.code) {
      return jsonResponse(
        {
          error:
            "Meta is not configured. Pass phone_number_id, waba_id, and display_phone for local connect.",
        },
        400,
      );
    } else {
      return jsonResponse(
        {
          error:
            "Informe code (OAuth) ou phone_number_id + waba_id para conectar.",
        },
        400,
      );
    }

    if (!phoneNumberId || !wabaId) {
      return jsonResponse(
        {
          error:
            "phone_number_id e waba_id são obrigatórios para concluir a conexão.",
        },
        400,
      );
    }

    const admin = createServiceClient();

    const { data: existingProfile } = await admin
      .from("profiles")
      .select("whatsapp_business_account_id")
      .eq("id", userId)
      .maybeSingle();

    const previousWabaId =
      (existingProfile?.whatsapp_business_account_id as string | null) ?? null;
    // First connect (null → id) does not reset. Same WABA reconnect keeps approvals.
    const wabaChanged = Boolean(previousWabaId && previousWabaId !== wabaId);

    const { error: updateError } = await admin
      .from("profiles")
      .update({
        whatsapp_connected: true,
        whatsapp_integration_status: "connected",
        whatsapp_phone_number_id: phoneNumberId,
        whatsapp_business_account_id: wabaId,
        whatsapp_display_phone: displayPhone,
        whatsapp_access_token: accessToken,
        whatsapp_token_expires_at: expiresAt,
        whatsapp_connected_at: new Date().toISOString(),
        whatsapp_last_error: null,
      })
      .eq("id", userId);

    if (updateError) {
      return jsonResponse({ error: updateError.message }, 500);
    }

    let templatesReset = 0;
    if (wabaChanged && previousWabaId) {
      templatesReset = await resetTemplatesForWabaChange(
        admin,
        userId,
        previousWabaId,
        wabaId,
      );
    }

    return jsonResponse({
      ok: true,
      waba_changed: wabaChanged,
      templates_reset: templatesReset,
    });
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";

    try {
      const auth = req.headers.get("Authorization");
      if (auth) {
        const { userId } = await requireUser(auth);
        const admin = createServiceClient();
        await admin
          .from("profiles")
          .update({
            whatsapp_integration_status: "error",
            whatsapp_last_error: message,
          })
          .eq("id", userId);
      }
    } catch {
      // ignore secondary failure
    }

    return jsonResponse({ error: message }, 500);
  }
});
