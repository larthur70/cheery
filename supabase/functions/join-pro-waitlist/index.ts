// Captures Pro interest emails (app + landing). No Stripe.
// verify_jwt = false (landing is anonymous); validates email in-handler.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return json({ error: "Method not allowed." }, 405);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!supabaseUrl || !serviceKey || !anonKey) {
      return json({ error: "Waitlist is not configured." }, 500);
    }

    const body = await req.json().catch(() => null);
    if (body == null || typeof body !== "object") {
      return json({ error: "Invalid body." }, 400);
    }

    const rawEmail = String((body as { email?: unknown }).email ?? "")
      .trim()
      .toLowerCase();
    const rawSource = String((body as { source?: unknown }).source ?? "app")
      .trim()
      .toLowerCase();
    const source = rawSource === "landing" ? "landing" : "app";

    if (!emailRegex.test(rawEmail)) {
      return json({ error: "Informe um e-mail válido." }, 400);
    }

    let userId: string | null = null;
    const authHeader = req.headers.get("Authorization");
    if (authHeader?.startsWith("Bearer ")) {
      const userClient = createClient(supabaseUrl, anonKey, {
        global: { headers: { Authorization: authHeader } },
      });
      const {
        data: { user },
      } = await userClient.auth.getUser();
      userId = user?.id ?? null;
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const { error } = await admin.from("pro_waitlist").insert({
      email: rawEmail,
      source,
      user_id: userId,
    });

    if (error) {
      if (error.code === "23505") {
        return json({ ok: true });
      }
      console.error("pro_waitlist insert failed", error);
      return json({ error: "Não foi possível salvar seu interesse." }, 500);
    }

    return json({ ok: true });
  } catch (error) {
    console.error("join-pro-waitlist unexpected", error);
    return json({ error: "Erro inesperado. Tente novamente." }, 500);
  }
});

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
