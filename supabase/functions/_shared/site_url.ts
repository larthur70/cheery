const DEFAULT_APP_ORIGIN = "https://app.usecheery.com";

/** Strip quotes/whitespace and trailing slash from an origin secret. */
function normalizeOrigin(raw: string | undefined | null): string | null {
  if (!raw) return null;
  let value = raw.trim();
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    value = value.slice(1, -1).trim();
  }
  value = value.replace(/\/$/, "");
  return value || null;
}

/**
 * App origin for Stripe redirects / OAuth.
 * Prefers SITE_URL, then APP_ORIGIN, then production default.
 * Adds https:// when the scheme is missing (e.g. app.usecheery.com).
 */
export function resolveSiteUrl(): string | null {
  const candidates = [
    Deno.env.get("SITE_URL"),
    Deno.env.get("APP_ORIGIN"),
    DEFAULT_APP_ORIGIN,
  ];

  for (const candidate of candidates) {
    const normalized = normalizeOrigin(candidate);
    if (!normalized) continue;

    let withScheme = normalized;
    if (!/^https?:\/\//i.test(withScheme)) {
      withScheme = `https://${withScheme}`;
    }

    try {
      const parsed = new URL(withScheme);
      if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
        continue;
      }
      if (!parsed.hostname) continue;
      // Origin only (no path/query) — Stripe success_url appends /profile…
      return `${parsed.protocol}//${parsed.host}`;
    } catch {
      continue;
    }
  }

  return null;
}
