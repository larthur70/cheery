export const GRAPH_API_VERSION = "v21.0";
export const GRAPH_BASE = `https://graph.facebook.com/${GRAPH_API_VERSION}`;

export function isMetaConfigured(): boolean {
  return Boolean(
    Deno.env.get("META_APP_ID") && Deno.env.get("META_APP_SECRET"),
  );
}

export { resolveSiteUrl as siteUrl } from "./site_url.ts";

/** Brazilian WhatsApp digits: 55 + DDD + number, or null if invalid. */
export function normalizeBrazilPhone(raw: string): string | null {
  const digits = raw.replace(/\D/g, "");
  if (!digits) return null;
  if (
    digits.startsWith("55") &&
    (digits.length === 12 || digits.length === 13)
  ) {
    return digits;
  }
  if (digits.length === 10 || digits.length === 11) {
    return `55${digits}`;
  }
  return null;
}

/** Meta template names: lowercase snake_case, alphanumeric + underscore. */
export function toMetaTemplateName(name: string, suffix?: string): string {
  const base = name
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 40);
  const safe = base || "template";
  if (!suffix) return safe;
  return `${safe}_${suffix}`.slice(0, 512);
}

export function buildEmbeddedSignupUrl(options: {
  appId: string;
  configId: string;
  redirectUri: string;
  state?: string;
}): string {
  const url = new URL(`https://www.facebook.com/${GRAPH_API_VERSION}/dialog/oauth`);
  url.searchParams.set("client_id", options.appId);
  url.searchParams.set("config_id", options.configId);
  url.searchParams.set("response_type", "code");
  url.searchParams.set("override_default_response_type", "true");
  url.searchParams.set("redirect_uri", options.redirectUri);
  if (options.state) {
    url.searchParams.set("state", options.state);
  }
  return url.toString();
}

export function buildDevCallbackUrl(base: string): string {
  const url = new URL(`${base}/whatsapp/callback`);
  url.searchParams.set("phone_number_id", "dev");
  url.searchParams.set("waba_id", "dev");
  url.searchParams.set("display_phone", "+5511999999999");
  return url.toString();
}

export async function exchangeCodeForToken(options: {
  code: string;
  redirectUri: string;
}): Promise<{
  accessToken: string;
  expiresIn?: number;
}> {
  const appId = Deno.env.get("META_APP_ID");
  const appSecret = Deno.env.get("META_APP_SECRET");
  if (!appId || !appSecret) {
    throw new Error("Meta is not configured");
  }

  const url = new URL(`${GRAPH_BASE}/oauth/access_token`);
  url.searchParams.set("client_id", appId);
  url.searchParams.set("client_secret", appSecret);
  url.searchParams.set("redirect_uri", options.redirectUri);
  url.searchParams.set("code", options.code);

  const res = await fetch(url);
  const json = await res.json();
  if (!res.ok || !json.access_token) {
    throw new Error(
      json.error?.message ?? `OAuth exchange failed (${res.status})`,
    );
  }
  return {
    accessToken: json.access_token as string,
    expiresIn: typeof json.expires_in === "number" ? json.expires_in : undefined,
  };
}

export async function graphGet(
  path: string,
  accessToken: string,
  query: Record<string, string> = {},
): Promise<Record<string, unknown>> {
  const url = new URL(`${GRAPH_BASE}${path.startsWith("/") ? path : `/${path}`}`);
  for (const [k, v] of Object.entries(query)) {
    url.searchParams.set(k, v);
  }
  url.searchParams.set("access_token", accessToken);
  const res = await fetch(url);
  const json = await res.json();
  if (!res.ok) {
    throw new Error(
      (json as { error?: { message?: string } }).error?.message ??
        `Graph GET failed (${res.status})`,
    );
  }
  return json as Record<string, unknown>;
}

export async function graphPost(
  path: string,
  accessToken: string,
  body: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const url = `${GRAPH_BASE}${path.startsWith("/") ? path : `/${path}`}`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const json = await res.json();
  if (!res.ok) {
    throw new Error(
      (json as { error?: { message?: string } }).error?.message ??
        `Graph POST failed (${res.status})`,
    );
  }
  return json as Record<string, unknown>;
}

export function mapMetaTemplateStatus(
  event: string,
): "approved" | "rejected" | "pending_approval" | null {
  const upper = event.toUpperCase();
  if (upper === "APPROVED") return "approved";
  if (upper === "REJECTED" || upper === "DISABLED") return "rejected";
  if (
    upper === "PENDING" ||
    upper === "IN_APPEAL" ||
    upper === "PENDING_DELETION"
  ) {
    return "pending_approval";
  }
  return null;
}

export function sampleValuesForVariables(variables: string[]): string[] {
  return variables.map((key) => {
    if (key === "client_name") return "Maria";
    if (key === "company_name") return "Cheery";
    return "exemplo";
  });
}

export function resolveVariableValue(
  key: string,
  clientName: string,
  companyName: string,
): string {
  if (key === "client_name") return clientName;
  if (key === "company_name") return companyName;
  return "";
}

/** True when the stored token can be sent to Graph (not a local/dev placeholder). */
export function isLiveWhatsAppToken(
  accessToken: string | null,
  phoneNumberId: string | null,
): boolean {
  if (!accessToken || !phoneNumberId) return false;
  if (phoneNumberId === "dev") return false;
  if (
    accessToken === "dev_token" ||
    accessToken === "embedded_signup_token"
  ) {
    return false;
  }
  return accessToken.length > 20;
}

export async function verifyMetaSignature(
  rawBody: string,
  signatureHeader: string | null,
): Promise<boolean> {
  const appSecret = Deno.env.get("META_APP_SECRET");
  if (!appSecret) {
    // Fail closed: missing secret must not accept unsigned production webhooks.
    return false;
  }
  if (!signatureHeader?.startsWith("sha256=")) return false;
  const expectedHex = signatureHeader.slice("sha256=".length);
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(appSecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(rawBody),
  );
  const actualHex = [...new Uint8Array(sig)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  if (actualHex.length !== expectedHex.length) return false;
  let mismatch = 0;
  for (let i = 0; i < actualHex.length; i++) {
    mismatch |= actualHex.charCodeAt(i) ^ expectedHex.charCodeAt(i);
  }
  return mismatch === 0;
}

export function localParts(timeZone: string, date = new Date()) {
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

export function inNotificationWindow(
  notificationTime: string,
  timeZone: string,
  windowMinutes = 15,
): boolean {
  const local = localParts(timeZone);
  const nowMinutes = local.hour * 60 + local.minute;
  const bits = notificationTime.split(":");
  const target = Number(bits[0] ?? 0) * 60 + Number(bits[1] ?? 0);
  return nowMinutes >= target && nowMinutes < target + windowMinutes;
}
