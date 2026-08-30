// Submits a Cheery template to Meta for approval (or local pending in dev).
// Auth: user JWT.
// Body: { template_id }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import {
  AuthError,
  createServiceClient,
  requireUser,
} from "../_shared/supabase.ts";
import {
  graphPost,
  isMetaConfigured,
  sampleValuesForVariables,
  toMetaTemplateName,
} from "../_shared/whatsapp.ts";

type Body = { template_id?: string };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { userId } = await requireUser(req.headers.get("Authorization"));
    const body = (await req.json().catch(() => ({}))) as Body;
    const templateId = body.template_id?.trim();
    if (!templateId) {
      return jsonResponse({ error: "template_id is required" }, 400);
    }

    const admin = createServiceClient();

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select(
        "id, plan, whatsapp_connected, whatsapp_business_account_id, whatsapp_access_token",
      )
      .eq("id", userId)
      .single();

    if (profileError || !profile) {
      return jsonResponse({ error: "Profile not found" }, 404);
    }

    if (profile.plan !== "pro") {
      return jsonResponse(
        { error: "Envio para aprovação requer o plano Pro." },
        403,
      );
    }

    if (!profile.whatsapp_connected) {
      return jsonResponse(
        { error: "Conecte o WhatsApp Business antes de enviar o template." },
        400,
      );
    }

    const { data: template, error: templateError } = await admin
      .from("templates")
      .select(
        "id, user_id, name, message, variables, approval_status, meta_category, meta_language, meta_template_name",
      )
      .eq("id", templateId)
      .eq("user_id", userId)
      .single();

    if (templateError || !template) {
      return jsonResponse({ error: "Template not found" }, 404);
    }

    if (
      template.approval_status === "pending_approval" ||
      template.approval_status === "approved"
    ) {
      return jsonResponse(
        { error: "Este template já foi enviado ou aprovado." },
        400,
      );
    }

    const variables = Array.isArray(template.variables)
      ? (template.variables as string[])
      : [];
    const shortId = String(template.id).replace(/-/g, "").slice(0, 8);
    const metaName =
      template.meta_template_name ??
      toMetaTemplateName(template.name as string, shortId);
    const now = new Date().toISOString();

    const wabaId = profile.whatsapp_business_account_id as string | null;
    const accessToken = profile.whatsapp_access_token as string | null;
    const canCallMeta =
      isMetaConfigured() &&
      wabaId &&
      wabaId !== "dev" &&
      accessToken &&
      accessToken !== "dev_token";

    if (canCallMeta) {
      const samples = sampleValuesForVariables(variables);
      const components: Record<string, unknown>[] = [
        {
          type: "BODY",
          text: template.message,
          ...(variables.length > 0
            ? { example: { body_text: [samples] } }
            : {}),
        },
      ];

      const result = await graphPost(
        `/${wabaId}/message_templates`,
        accessToken!,
        {
          name: metaName,
          language: template.meta_language ?? "pt_BR",
          category: template.meta_category ?? "UTILITY",
          components,
        },
      );

      const metaTemplateId =
        typeof result.id === "string" ? result.id : null;

      const { error: updateError } = await admin
        .from("templates")
        .update({
          approval_status: "pending_approval",
          meta_template_name: metaName,
          meta_template_id: metaTemplateId,
          submitted_at: now,
          approved_at: null,
          rejected_reason: null,
        })
        .eq("id", templateId)
        .eq("user_id", userId);

      if (updateError) {
        return jsonResponse({ error: updateError.message }, 500);
      }

      await admin.from("whatsapp_template_events").insert({
        user_id: userId,
        template_id: templateId,
        event_type: "submitted",
        previous_status: template.approval_status,
        new_status: "pending_approval",
        payload: { meta_template_name: metaName, graph: result },
      });

      return jsonResponse({ ok: true });
    }

    // Dev mode: Meta not configured — mark pending locally so the UI works.
    const { error: updateError } = await admin
      .from("templates")
      .update({
        approval_status: "pending_approval",
        meta_template_name: metaName,
        submitted_at: now,
        approved_at: null,
        rejected_reason: null,
      })
      .eq("id", templateId)
      .eq("user_id", userId);

    if (updateError) {
      return jsonResponse({ error: updateError.message }, 500);
    }

    await admin.from("whatsapp_template_events").insert({
      user_id: userId,
      template_id: templateId,
      event_type: "submitted_dev",
      previous_status: template.approval_status,
      new_status: "pending_approval",
      payload: { meta_template_name: metaName, mock: true },
    });

    return jsonResponse({ ok: true, mock: true });
  } catch (error) {
    if (error instanceof AuthError) {
      return unauthorized();
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    return jsonResponse({ error: message }, 500);
  }
});
