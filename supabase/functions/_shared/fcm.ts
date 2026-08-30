import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

export async function getFcmAccessToken(
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

export async function sendFcm(options: {
  accessToken: string;
  projectId: string;
  deviceToken: string;
  title: string;
  body: string;
  route?: string;
}): Promise<{ ok: boolean; status: number }> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${options.projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${options.accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: options.deviceToken,
          notification: { title: options.title, body: options.body },
          data: { route: options.route ?? "/home" },
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

export function loadFcmConfig(): {
  serviceAccount: Record<string, string>;
  projectId: string;
} | null {
  const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!saRaw) return null;
  const serviceAccount = JSON.parse(saRaw) as Record<string, string>;
  const projectId =
    Deno.env.get("FIREBASE_PROJECT_ID") ?? serviceAccount.project_id;
  if (!projectId) return null;
  return { serviceAccount, projectId };
}

/** Push all registered tokens for a user. Failures are logged, not thrown. */
export async function notifyUser(options: {
  admin: SupabaseClient;
  userId: string;
  title: string;
  body: string;
  route: string;
}): Promise<number> {
  const config = loadFcmConfig();
  if (!config) {
    console.warn("FCM not configured; skipping push");
    return 0;
  }

  const { data: tokens, error } = await options.admin
    .from("push_tokens")
    .select("token")
    .eq("user_id", options.userId);

  if (error) {
    console.error("push_tokens query failed", error);
    return 0;
  }

  const rows = (tokens ?? []) as Array<{ token: string }>;
  if (rows.length === 0) return 0;

  const accessToken = await getFcmAccessToken(config.serviceAccount);
  let sent = 0;
  for (const row of rows) {
    const result = await sendFcm({
      accessToken,
      projectId: config.projectId,
      deviceToken: row.token,
      title: options.title,
      body: options.body,
      route: options.route,
    });
    if (result.ok) sent += 1;
  }
  return sent;
}
