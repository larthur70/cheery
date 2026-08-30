// Polls Meta for pending template approval status (or no-ops without Meta).
// Auth: user JWT OR Bearer CRON_SECRET.
// Body optional: { template_id }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import { notifyUser } from "../_shared/fcm.ts";
import {
  AuthError,
  createServiceClient,
  isCronRequest,
  requireUser,
} from "../_shared/supabase.ts";
import {
  graphGet,
  isLiveWhatsAppToken,
  isMetaConfigured,
  mapMetaTemplateStatus,
} from "../_shared/whatsapp.ts";

type Body = { template_id?: string };

type TemplateRow = {
  id: string;
  user_id: string;
  name: string;
  approval_status: string;
  meta_template_name: string | null;
  meta_template_id: string | null;
};

type ProfileWa = {
  id: string;
  whatsapp_business_account_id: string | null;
  whatsapp_access_token: string | null;
};

async function applyStatusUpdate(
  admin: SupabaseClient,
  template: TemplateRow,
  nextStatus: "approved" | "rejected" | "pending_approval",
  rejectedReason: string | null,
  payload: unknown,
): Promise<boolean> {
  if (template.approval_status === nextStatus) return false;

  const patch: Record<string, unknown> = {
    approval_status: nextStatus,
  };
  if (nextStatus === "approved") {
    patch.approved_at = new Date().toISOString();
    patch.rejected_reason = null;
  }
  if (nextStatus === "rejected") {
    patch.rejected_reason = rejectedReason ?? "Rejected by Meta";
  }

  const { error } = await admin
    .from("templates")
    .update(patch)
    .eq("id", template.id);

  if (error) {
    console.error("template update failed", error.message);
    return false;
  }

  await admin.from("whatsapp_template_events").insert({
    user_id: template.user_id,
    template_id: template.id,
    event_type: "status_sync",
    previous_status: template.approval_status,
    new_status: nextStatus,
    payload,
  });

  if (nextStatus === "approved") {
    await notifyUser({
      admin,
      userId: template.user_id,
      title: "Template aprovado!",
      body: `Seu template "${template.name}" foi aprovado pela Meta.`,
      route: "/templates",
    });
  }

  return true;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const cronSecret = Deno.env.get("CRON_SECRET");
    const auth = req.headers.get("Authorization") ?? "";
    const isCron = isCronRequest(auth);

    let scopedUserId: string | null = null;
    if (!isCron) {
      const { userId } = await requireUser(auth || null);
      scopedUserId = userId;
    } else if (!cronSecret) {
      return unauthorized();
    }

    const body = (await req.json().catch(() => ({}))) as Body;
    const admin = createServiceClient();

    let query = admin
      .from("templates")
      .select(
        "id, user_id, name, approval_status, meta_template_name, meta_template_id",
      )
      .eq("approval_status", "pending_approval");

    if (scopedUserId) {
      query = query.eq("user_id", scopedUserId);
    }
    if (body.template_id) {
      query = query.eq("id", body.template_id);
    }

    const { data: templates, error: templatesError } = await query;
    if (templatesError) {
      return jsonResponse({ error: templatesError.message }, 500);
    }

    const rows = (templates ?? []) as TemplateRow[];
    if (rows.length === 0) {
      return jsonResponse({ updated: 0 });
    }

    if (!isMetaConfigured()) {
      // Without Meta, leave pending as-is (dev can approve via webhook mock or DB).
      return jsonResponse({ updated: 0, skipped: "meta_not_configured" });
    }

    let updated = 0;
    const profileCache = new Map<string, ProfileWa | null>();

    for (const template of rows) {
      if (!template.meta_template_name) continue;

      let profile = profileCache.get(template.user_id);
      if (profile === undefined) {
        const { data } = await admin
          .from("profiles")
          .select("id, whatsapp_business_account_id, whatsapp_access_token")
          .eq("id", template.user_id)
          .maybeSingle();
        profile = (data as ProfileWa | null) ?? null;
        profileCache.set(template.user_id, profile);
      }

      if (
        !profile ||
        !isLiveWhatsAppToken(
          profile.whatsapp_access_token,
          profile.whatsapp_business_account_id,
        )
      ) {
        continue;
      }

      try {
        const result = await graphGet(
          `/${profile.whatsapp_business_account_id}/message_templates`,
          profile.whatsapp_access_token,
          {
            name: template.meta_template_name,
            fields: "name,status,id,rejected_reason",
          },
        );

        const data = (result.data as Array<Record<string, unknown>> | undefined) ??
          [];
        const match =
          data.find((t) => t.name === template.meta_template_name) ?? data[0];
        if (!match) continue;

        const mapped = mapMetaTemplateStatus(String(match.status ?? ""));
        if (!mapped || mapped === "pending_approval") continue;

        const reason =
          typeof match.rejected_reason === "string"
            ? match.rejected_reason
            : null;

        if (typeof match.id === "string") {
          await admin
            .from("templates")
            .update({ meta_template_id: match.id })
            .eq("id", template.id);
        }

        const changed = await applyStatusUpdate(
          admin,
          template,
          mapped,
          reason,
          match,
        );
        if (changed) updated += 1;
      } catch (err) {
        console.error(
          "sync template failed",
          template.id,
          err instanceof Error ? err.message : err,
        );
      }
    }

    return jsonResponse({ updated });
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    return jsonResponse({ error: message }, 500);
  }
});
