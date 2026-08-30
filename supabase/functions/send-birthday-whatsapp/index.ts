// Cron: send approved WhatsApp birthday templates via Cloud API.
// Auth: Bearer CRON_SECRET
// Secrets: CRON_SECRET (+ Meta tokens on each connected profile)

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse, unauthorized } from "../_shared/cors.ts";
import {
  AuthError,
  createServiceClient,
  requireCronAuth,
} from "../_shared/supabase.ts";
import {
  graphPost,
  inNotificationWindow,
  isLiveWhatsAppToken,
  localParts,
  normalizeBrazilPhone,
  resolveVariableValue,
} from "../_shared/whatsapp.ts";

const MAX_SENDS_PER_RUN = 40;

type ProfileRow = {
  id: string;
  company_name: string | null;
  notification_time: string;
  timezone: string;
  whatsapp_phone_number_id: string | null;
  whatsapp_access_token: string | null;
};

type ClientRow = {
  id: string;
  name: string;
  phone: string;
  birth_date: string;
  template_id: string;
  automatic_enabled: boolean;
};

type TemplateRow = {
  id: string;
  name: string;
  message: string;
  variables: string[] | null;
  approval_status: string;
  meta_template_name: string | null;
  meta_language: string | null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    requireCronAuth(req.headers.get("Authorization"));
  } catch (error) {
    if (error instanceof AuthError) return unauthorized();
    throw error;
  }

  const admin = createServiceClient();

  const { data: profiles, error: profilesError } = await admin
    .from("profiles")
    .select(
      "id, company_name, notification_time, timezone, whatsapp_phone_number_id, whatsapp_access_token",
    )
    .eq("whatsapp_connected", true)
    .eq("plan", "pro");

  if (profilesError) {
    return jsonResponse({ error: profilesError.message }, 500);
  }

  const dueProfiles = ((profiles ?? []) as ProfileRow[]).filter((p) =>
    inNotificationWindow(
      p.notification_time,
      p.timezone || "America/Sao_Paulo",
    )
  );

  let attempted = 0;
  let sent = 0;
  let failed = 0;
  let skipped = 0;
  const details: Array<Record<string, unknown>> = [];

  for (const profile of dueProfiles) {
    const tz = profile.timezone || "America/Sao_Paulo";
    const local = localParts(tz);
    const phoneNumberId = profile.whatsapp_phone_number_id;
    const accessToken = profile.whatsapp_access_token;

    if (
      !accessToken ||
      !phoneNumberId ||
      !isLiveWhatsAppToken(accessToken, phoneNumberId)
    ) {
      details.push({ userId: profile.id, skipped: "no_live_whatsapp_token" });
      continue;
    }

    const { data: clients, error: clientsError } = await admin
      .from("clients")
      .select(
        "id, name, phone, birth_date, template_id, automatic_enabled",
      )
      .eq("user_id", profile.id)
      .eq("automatic_enabled", true)
      .eq("birth_month", local.month)
      .eq("birth_day", local.day);

    if (clientsError) {
      details.push({ userId: profile.id, error: clientsError.message });
      continue;
    }

    const birthdayClients = (clients ?? []) as ClientRow[];

    if (birthdayClients.length === 0) {
      details.push({ userId: profile.id, birthdays: 0 });
      continue;
    }

    const templateIds = [...new Set(birthdayClients.map((c) => c.template_id))];
    const { data: templates, error: templatesError } = await admin
      .from("templates")
      .select(
        "id, name, message, variables, approval_status, meta_template_name, meta_language",
      )
      .eq("user_id", profile.id)
      .in("id", templateIds);

    if (templatesError) {
      details.push({ userId: profile.id, error: templatesError.message });
      continue;
    }

    const templateById = new Map(
      ((templates ?? []) as TemplateRow[]).map((t) => [t.id, t]),
    );

    const clientIds = birthdayClients.map((c) => c.id);
    const { data: existingLogs } = await admin
      .from("whatsapp_message_logs")
      .select("client_id")
      .eq("user_id", profile.id)
      .eq("sent_for_year", local.year)
      .in("client_id", clientIds)
      .neq("status", "failed");
    const alreadySent = new Set(
      ((existingLogs ?? []) as Array<{ client_id: string }>).map(
        (row) => row.client_id,
      ),
    );

    for (const client of birthdayClients) {
      if (attempted >= MAX_SENDS_PER_RUN) {
        details.push({
          userId: profile.id,
          capped: true,
          remaining: true,
        });
        break;
      }

      const template = templateById.get(client.template_id);
      if (
        !template ||
        template.approval_status !== "approved" ||
        !template.meta_template_name
      ) {
        skipped += 1;
        continue;
      }

      if (alreadySent.has(client.id)) {
        skipped += 1;
        continue;
      }

      const to = normalizeBrazilPhone(client.phone);
      if (!to) {
        failed += 1;
        await admin.from("whatsapp_message_logs").insert({
          user_id: profile.id,
          client_id: client.id,
          template_id: template.id,
          status: "failed",
          error: "Invalid phone number",
          sent_for_year: local.year,
        });
        continue;
      }

      const variables = Array.isArray(template.variables)
        ? template.variables
        : [];
      const companyName = profile.company_name ?? "Cheery";
      const parameters = variables.map((key) => ({
        type: "text",
        text: resolveVariableValue(key, client.name, companyName) || " ",
      }));

      const components =
        parameters.length > 0
          ? [{ type: "body", parameters }]
          : [];

      attempted += 1;
      try {
        const result = await graphPost(
          `/${phoneNumberId}/messages`,
          accessToken,
          {
            messaging_product: "whatsapp",
            to,
            type: "template",
            template: {
              name: template.meta_template_name,
              language: { code: template.meta_language ?? "pt_BR" },
              ...(components.length > 0 ? { components } : {}),
            },
          },
        );

        const messages =
          (result.messages as Array<{ id?: string }> | undefined) ?? [];
        const metaMessageId = messages[0]?.id ?? null;

        await admin.from("whatsapp_message_logs").insert({
          user_id: profile.id,
          client_id: client.id,
          template_id: template.id,
          meta_message_id: metaMessageId,
          status: "sent",
          sent_for_year: local.year,
        });

        await admin
          .from("clients")
          .update({ message_sent_year: local.year })
          .eq("id", client.id);

        sent += 1;
      } catch (err) {
        const message = err instanceof Error ? err.message : "Send failed";
        failed += 1;
        await admin.from("whatsapp_message_logs").insert({
          user_id: profile.id,
          client_id: client.id,
          template_id: template.id,
          status: "failed",
          error: message,
          sent_for_year: local.year,
        });
        details.push({
          userId: profile.id,
          ok: false,
          error: message,
        });
      }
    }

    if (attempted >= MAX_SENDS_PER_RUN) break;
  }

  return jsonResponse({
    ok: true,
    due: dueProfiles.length,
    attempted,
    sent,
    failed,
    skipped,
    capped: attempted >= MAX_SENDS_PER_RUN,
    details,
  });
});
