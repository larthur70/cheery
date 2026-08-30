import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

export function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`Missing env: ${name}`);
  }
  return value;
}

export function createUserClient(authHeader: string): SupabaseClient {
  const supabaseUrl = requireEnv("SUPABASE_URL");
  const anonKey = requireEnv("SUPABASE_ANON_KEY");
  return createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
}

export function createServiceClient(): SupabaseClient {
  const supabaseUrl = requireEnv("SUPABASE_URL");
  const serviceKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  return createClient(supabaseUrl, serviceKey);
}

export async function requireUser(
  authHeader: string | null,
): Promise<{ userId: string; email: string | null; userClient: SupabaseClient }> {
  if (!authHeader) {
    throw new AuthError("Unauthorized");
  }
  const userClient = createUserClient(authHeader);
  const {
    data: { user },
    error,
  } = await userClient.auth.getUser();
  if (error || !user) {
    throw new AuthError("Unauthorized");
  }
  return { userId: user.id, email: user.email ?? null, userClient };
}

/** Timing-safe compare so cron secret length is not leaked via short-circuit. */
function timingSafeEqual(left: string, right: string): boolean {
  const max = Math.max(left.length, right.length);
  let mismatch = left.length ^ right.length;
  for (let i = 0; i < max; i++) {
    const a = i < left.length ? left.charCodeAt(i) : 0;
    const b = i < right.length ? right.charCodeAt(i) : 0;
    mismatch |= a ^ b;
  }
  return mismatch === 0;
}

export function isCronRequest(authHeader: string | null): boolean {
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!cronSecret) return false;
  return timingSafeEqual(authHeader ?? "", `Bearer ${cronSecret}`);
}

export function requireCronAuth(authHeader: string | null): void {
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!cronSecret || !isCronRequest(authHeader)) {
    throw new AuthError("Unauthorized");
  }
}

export class AuthError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "AuthError";
  }
}
