// Supabase Edge Function: daily birthday reminder pushes via FCM HTTP v1.
// Secrets (Dashboard → Edge Functions → Secrets):
//   CRON_SECRET
//   FCM_SERVICE_ACCOUNT_JSON  (full Firebase service account JSON)
//   FIREBASE_PROJECT_ID       optional if present in the service account JSON

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

type ProfileRow = {
  id: string;
  notification_time: string;
  timezone: string;
};

type TokenRow = {
  user_id: string;
  token: string;
};

type ClientRow = {
  id: string;
  name: string;
  birth_date: string;
};

function firstName(fullName: string): string {
  const trimmed = fullName.trim();
  if (!trimmed) return "Cliente";
  const parts = trimmed.split(" ").filter((part) => part.length > 0);
  return parts[0] ?? "Cliente";
}

function buildBirthdayCopy(names: string[]): { title: string; body: string } {
  const count = names.length;
  if (count === 1) {
    return {
      title: `🎉 Hoje é aniversário do ${names[0]}!`,
      body:
        "Envie uma mensagem de parabéns agora e fortaleça o relacionamento com seu cliente.",
    };
  }
  if (count === 2) {
    return {
      title: `🎉 ${names[0]} e ${names[1]} fazem aniversário hoje!`,
      body:
        "Aproveite para enviar os parabéns e manter seus clientes engajados.",
    };
  }
  return {
    title: `🎉 Você tem ${count} aniversariantes hoje!`,
    body:
      "Não perca a chance de fortalecer o relacionamento com seus clientes. Abra o Cheery e envie as mensagens.",
  };
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function unauthorized(): Response {
  return new Response(JSON.stringify({ error: "Unauthorized" }), {
    status: 401,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function parseTimeToMinutes(time: string): number {
  const parts = time.split(":");
  const h = Number(parts[0] ?? 0);
  const m = Number(parts[1] ?? 0);
  return h * 60 + m;
}

function localParts(timeZone: string, date = new Date()) {
  const fmt = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  });
  const parts = Object.fromEntries(
    fmt.formatToParts(date).map((p) => [p.type, p.value]),
  );
  return {
    year: Number(parts.year),
    month: Number(parts.month),
    day: Number(parts.day),
    hour: Number(parts.hour),
    minute: Number(parts.minute),
  };
}

function inNotificationWindow(
  notificationTime: string,
  timeZone: string,
  windowMinutes = 15,
): boolean {
  const local = localParts(timeZone);
  const nowMinutes = local.hour * 60 + local.minute;
  const target = parseTimeToMinutes(notificationTime);
  return nowMinutes >= target && nowMinutes < target + windowMinutes;
}

async function getFcmAccessToken(
  serviceAccount: Record<string, string>,
): Promise<string> {
  const privateKey = await importPKCS8(serviceAccount.private_key, "RS256");
  const now = Math.floor(Date.now() / 1000);
  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setSubject(serviceAccount.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!tokenRes.ok) {
    const text = await tokenRes.text();
    throw new Error(`OAuth token failed: ${tokenRes.status} ${text}`);
  }
  const json = await tokenRes.json();
  return json.access_token as string;
}

async function sendFcm(
  accessToken: string,
  projectId: string,
  deviceToken: string,
  title: string,
  body: string,
): Promise<{ ok: boolean; status: number }> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          notification: { title, body },
          data: { route: "/home" },
          android: { priority: "HIGH" },
          apns: {
            payload: {
              aps: { sound: "default" },
            },
          },
        },
      }),
    },
  );
  return { ok: res.ok, status: res.status };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const cronSecret = Deno.env.get("CRON_SECRET");
  const auth = req.headers.get("Authorization") ?? "";
  if (!cronSecret || auth !== `Bearer ${cronSecret}`) {
    return unauthorized();
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!supabaseUrl || !serviceRole || !saRaw) {
    return new Response(
      JSON.stringify({
        error:
          "Missing SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, or FCM_SERVICE_ACCOUNT_JSON",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const serviceAccount = JSON.parse(saRaw) as Record<string, string>;
  const projectId =
    Deno.env.get("FIREBASE_PROJECT_ID") ?? serviceAccount.project_id;
  if (!projectId) {
    return new Response(
      JSON.stringify({ error: "FIREBASE_PROJECT_ID missing" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const supabase = createClient(supabaseUrl, serviceRole);

  const { data: profiles, error: profilesError } = await supabase
    .from("profiles")
    .select("id, notification_time, timezone")
    .eq("notifications_enabled", true);

  if (profilesError) {
    return new Response(JSON.stringify({ error: profilesError.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const dueProfiles = ((profiles ?? []) as ProfileRow[]).filter((p) =>
    inNotificationWindow(
      p.notification_time,
      p.timezone || "America/Sao_Paulo",
    )
  );

  if (dueProfiles.length === 0) {
    return new Response(JSON.stringify({ ok: true, due: 0, sent: 0 }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const accessToken = await getFcmAccessToken(serviceAccount);
  let sent = 0;
  const details: Array<Record<string, unknown>> = [];

  for (const profile of dueProfiles) {
    const local = localParts(profile.timezone || "America/Sao_Paulo");

    const { data: clients, error: clientsError } = await supabase
      .from("clients")
      .select("id, name, birth_date")
      .eq("user_id", profile.id)
      .eq("birth_month", local.month)
      .eq("birth_day", local.day);

    if (clientsError) {
      details.push({ userId: profile.id, error: clientsError.message });
      continue;
    }

    const birthdayNames = ((clients ?? []) as ClientRow[])
      .map((c) => firstName(c.name))
      .sort((a, b) => a.localeCompare(b, "pt-BR"));

    const birthdayCount = birthdayNames.length;

    if (birthdayCount === 0) {
      details.push({ userId: profile.id, birthdays: 0 });
      continue;
    }

    const { data: tokens, error: tokensError } = await supabase
      .from("push_tokens")
      .select("user_id, token")
      .eq("user_id", profile.id);

    if (tokensError) {
      details.push({ userId: profile.id, error: tokensError.message });
      continue;
    }

    const { title, body } = buildBirthdayCopy(birthdayNames);

    for (const row of (tokens ?? []) as TokenRow[]) {
      const result = await sendFcm(
        accessToken,
        projectId,
        row.token,
        title,
        body,
      );
      if (result.ok) sent += 1;
      details.push({
        userId: profile.id,
        birthdays: birthdayCount,
        tokenOk: result.ok,
        status: result.status,
      });
    }
  }

  return new Response(
    JSON.stringify({ ok: true, due: dueProfiles.length, sent, details }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
