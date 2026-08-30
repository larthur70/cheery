// Disconnects WhatsApp Business integration for the current user.
// Auth: user JWT.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import {
  AuthError,
  createServiceClient,
  requireUser,
} from "../_shared/supabase.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { userId } = await requireUser(req.headers.get("Authorization"));
    const admin = createServiceClient();

    const { error: updateError } = await admin
      .from("profiles")
      .update({
        whatsapp_connected: false,
        whatsapp_integration_status: "disconnected",
        whatsapp_phone_number_id: null,
        // Keep whatsapp_business_account_id so a later connect to a
        // different WABA can detect the change and reset templates.
        whatsapp_display_phone: null,
        whatsapp_access_token: null,
        whatsapp_token_expires_at: null,
        whatsapp_connected_at: null,
        whatsapp_last_error: null,
      })
      .eq("id", userId);

    if (updateError) {
      return jsonResponse({ error: updateError.message }, 500);
    }

    // Turn off per-client automation when the account disconnects.
    const { error: clientsError } = await admin
      .from("clients")
      .update({ automatic_enabled: false })
      .eq("user_id", userId)
      .eq("automatic_enabled", true);

    if (clientsError) {
      console.error("Failed to disable client automation", clientsError.message);
    }

    return jsonResponse({ ok: true });
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    return jsonResponse({ error: message }, 500);
  }
});
