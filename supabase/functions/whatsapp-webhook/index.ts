// Meta WhatsApp Cloud API webhook.
// verify_jwt must be false — Meta signs with X-Hub-Signature-256.
// GET: hub challenge. POST: template status + message status updates.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { notifyUser } from "../_shared/fcm.ts";
import { createServiceClient } from "../_shared/supabase.ts";
import {
  mapMetaTemplateStatus,
  verifyMetaSignature,
} from "../_shared/whatsapp.ts";

type TemplateRow = {
  id: string;
  user_id: string;
  name: string;
  approval_status: string;
  meta_template_name: string | null;
};

async function handleTemplateStatus(
  admin: SupabaseClient,
  event: Record<string, unknown>,
): Promise<void> {
  const metaName = String(
    event.message_template_name ?? event.message_template_id ?? "",
  );
  const eventStatus = String(event.event ?? event.message_template_status ?? "");
  const mapped = mapMetaTemplateStatus(eventStatus);
  if (!mapped || !metaName) return;

  const { data: templates, error: templatesError } = await admin
    .from("templates")
    .select("id, user_id, name, approval_status, meta_template_name")
    .eq("meta_template_name", metaName);

  if (templatesError) {
    throw new Error(templatesError.message);
  }

  const rows = (templates ?? []) as TemplateRow[];
  for (const template of rows) {
    if (template.approval_status === mapped) {
      await admin.from("whatsapp_template_events").insert({
        user_id: template.user_id,
        template_id: template.id,
        event_type: "webhook_duplicate",
        previous_status: template.approval_status,
        new_status: mapped,
        payload: event,
      });
      continue;
    }

    const patch: Record<string, unknown> = { approval_status: mapped };
    if (mapped === "approved") {
      patch.approved_at = new Date().toISOString();
      patch.rejected_reason = null;
    }
    if (mapped === "rejected") {
      patch.rejected_reason =
        typeof event.reason === "string"
          ? event.reason
          : typeof event.rejected_reason === "string"
          ? event.rejected_reason
          : "Rejected by Meta";
    }

    const { error: updateError } = await admin
      .from("templates")
      .update(patch)
      .eq("id", template.id);
    if (updateError) {
      throw new Error(updateError.message);
    }

    await admin.from("whatsapp_template_events").insert({
      user_id: template.user_id,
      template_id: template.id,
      event_type: "message_template_status_update",
      previous_status: template.approval_status,
      new_status: mapped,
      payload: event,
    });

    if (mapped === "approved") {
      await notifyUser({
        admin,
        userId: template.user_id,
        title: "Template aprovado!",
        body: `Seu template "${template.name}" foi aprovado pela Meta.`,
        route: "/templates",
      });
    }
  }
}

async function handleMessageStatuses(
  admin: SupabaseClient,
  statuses: Array<Record<string, unknown>>,
): Promise<void> {
  for (const status of statuses) {
    const metaMessageId = typeof status.id === "string" ? status.id : null;
    const statusValue = typeof status.status === "string"
      ? status.status.toLowerCase()
      : null;
    if (!metaMessageId || !statusValue) continue;

    const mapped =
      statusValue === "sent" ||
        statusValue === "delivered" ||
        statusValue === "read" ||
        statusValue === "failed"
        ? statusValue
        : null;
    if (!mapped) continue;

    const errorText =
      mapped === "failed"
        ? JSON.stringify(status.errors ?? status.error ?? status)
        : null;

    const { data: existing, error: lookupError } = await admin
      .from("whatsapp_message_logs")
      .select("id")
      .eq("meta_message_id", metaMessageId)
      .maybeSingle();
    if (lookupError) {
      throw new Error(lookupError.message);
    }

    if (existing?.id) {
      await admin
        .from("whatsapp_message_logs")
        .update({
          status: mapped,
          error: errorText,
          updated_at: new Date().toISOString(),
        })
        .eq("id", existing.id);
    }
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Meta webhook verification
  if (req.method === "GET") {
    const url = new URL(req.url);
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token")?.trim();
    const challenge = url.searchParams.get("hub.challenge");
    const verifyToken = Deno.env.get("META_WEBHOOK_VERIFY_TOKEN")?.trim();

    if (mode === "subscribe" && verifyToken && token === verifyToken && challenge) {
      return new Response(challenge, {
        status: 200,
        headers: { "Content-Type": "text/plain" },
      });
    }
    return jsonResponse({ error: "Verification failed" }, 403);
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const rawBody = await req.text();
  const signature = req.headers.get("X-Hub-Signature-256");
  const valid = await verifyMetaSignature(rawBody, signature);
  if (!valid) {
    return jsonResponse({ error: "Invalid signature" }, 401);
  }

  let payload: Record<string, unknown>;
  try {
    payload = JSON.parse(rawBody) as Record<string, unknown>;
  } catch {
    return jsonResponse({ error: "Invalid JSON" }, 400);
  }

  const admin = createServiceClient();
  const entries = (payload.entry as Array<Record<string, unknown>> | undefined) ??
    [];

  try {
    for (const entry of entries) {
      const changes =
        (entry.changes as Array<Record<string, unknown>> | undefined) ?? [];
      for (const change of changes) {
        const field = String(change.field ?? "");
        const value = (change.value ?? {}) as Record<string, unknown>;

        if (
          field === "message_template_status_update" ||
          field === "message_template_quality_update"
        ) {
          await handleTemplateStatus(admin, value);
        }

        if (field === "messages") {
          const statuses =
            (value.statuses as Array<Record<string, unknown>> | undefined) ?? [];
          if (statuses.length > 0) {
            await handleMessageStatuses(admin, statuses);
          }
        }
      }
    }

    // Some payloads put template events at the top-level object.
    if (payload.message_template_name || payload.event) {
      await handleTemplateStatus(admin, payload);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "Webhook handler failed";
    console.error("whatsapp-webhook handler failed", message);
    return jsonResponse({ error: message }, 500);
  }

  return jsonResponse({ received: true });
});
