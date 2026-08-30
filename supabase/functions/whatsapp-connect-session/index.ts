// Starts Meta Embedded Signup (or a local-dev mock callback URL).
// Auth: user JWT. Requires Pro plan.
// Secrets: META_APP_ID, WHATSAPP_CONFIG_ID, SITE_URL (see README).

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import {
  AuthError,
  createServiceClient,
  requireUser,
} from "../_shared/supabase.ts";
import {
  buildDevCallbackUrl,
  buildEmbeddedSignupUrl,
  siteUrl,
} from "../_shared/whatsapp.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { userId } = await requireUser(req.headers.get("Authorization"));
    const admin = createServiceClient();

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("id, plan")
      .eq("id", userId)
      .single();

    if (profileError || !profile) {
      return jsonResponse({ error: "Profile not found" }, 404);
    }

    if (profile.plan !== "pro") {
      return jsonResponse(
        { error: "A integração WhatsApp está disponível no plano Pro." },
        403,
      );
    }

    const { error: updateError } = await admin
      .from("profiles")
      .update({
        whatsapp_integration_status: "connecting",
        whatsapp_last_error: null,
      })
      .eq("id", userId);

    if (updateError) {
      return jsonResponse({ error: updateError.message }, 500);
    }

    const base = siteUrl();
    const appId = Deno.env.get("META_APP_ID");
    const configId = Deno.env.get("WHATSAPP_CONFIG_ID");

    if (appId && configId && base) {
      const redirectUri = `${base}/whatsapp/callback`;
      const url = buildEmbeddedSignupUrl({
        appId,
        configId,
        redirectUri,
        state: userId,
      });
      return jsonResponse({ url });
    }

    // Local / missing Meta secrets: mock redirect so the app can finish connect.
    if (base) {
      return jsonResponse({
        url: buildDevCallbackUrl(base),
        mock: true,
      });
    }

    return jsonResponse(
      {
        error:
          "WhatsApp OAuth is not configured. Set META_APP_ID, WHATSAPP_CONFIG_ID, and SITE_URL.",
      },
      500,
    );
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    return jsonResponse({ error: message }, 500);
  }
});
