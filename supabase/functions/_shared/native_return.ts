const NATIVE_SCHEME_PREFIX = "cheery://";

export function wantsNativeReturn(body: unknown): boolean {
  if (!body || typeof body !== "object") return false;
  const origin = (body as Record<string, unknown>).return_origin;
  return typeof origin === "string" && origin.startsWith(NATIVE_SCHEME_PREFIX);
}

/** HTTPS page that redirects into the native app. Stripe requires http(s). */
export function appHandoffUrl(
  siteUrl: string,
  deepLink: string,
  extraQuery?: Record<string, string>,
): string {
  const url = new URL(`${siteUrl}/open.html`);
  url.searchParams.set("to", deepLink);
  if (extraQuery) {
    for (const [key, value] of Object.entries(extraQuery)) {
      url.searchParams.set(key, value);
    }
  }
  return url.toString();
}
