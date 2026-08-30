// Creates a Stripe Checkout Session for the Pro subscription.
// Secrets: STRIPE_SECRET_KEY, SITE_URL
// Optional: STRIPE_PRICE_ID_PRO (overrides hardcoded live price)
// Requires Authorization: Bearer <user JWT>

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17";
import { appHandoffUrl, wantsNativeReturn } from "../_shared/native_return.ts";
import { resolveSiteUrl } from "../_shared/site_url.ts";

/** Cheery Pro monthly — R$ 49,90 (Live) */
const DEFAULT_PRO_PRICE_ID = "price_1U4ldoKCeWtlJSTVWPBnCPsF";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    const priceId =
      Deno.env.get("STRIPE_PRICE_ID_PRO")?.trim() || DEFAULT_PRO_PRICE_ID;
    const siteUrl = resolveSiteUrl();
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!stripeKey || !priceId || !siteUrl || !supabaseUrl || !supabaseAnonKey) {
      return new Response(
        JSON.stringify({
          error:
            "Billing is not configured. Set STRIPE_SECRET_KEY and a valid SITE_URL (e.g. https://app.usecheery.com).",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("id, full_name, company_name, plan, stripe_customer_id")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      return new Response(JSON.stringify({ error: "Profile not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (profile.plan === "pro") {
      return new Response(
        JSON.stringify({ error: "Você já está no plano Pro." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const stripe = new Stripe(stripeKey, {
      apiVersion: "2024-06-20",
      httpClient: Stripe.createFetchHttpClient(),
    });

    let customerId = profile.stripe_customer_id as string | null;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        name: profile.full_name ?? undefined,
        metadata: {
          supabase_user_id: user.id,
          company_name: profile.company_name ?? "",
        },
      });
      customerId = customer.id;

      const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
      if (!serviceKey) {
        return new Response(
          JSON.stringify({ error: "Service role not configured." }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      const admin = createClient(supabaseUrl, serviceKey);
      const { error: updateError } = await admin
        .from("profiles")
        .update({ stripe_customer_id: customerId })
        .eq("id", user.id);

      if (updateError) {
        return new Response(JSON.stringify({ error: updateError.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    const body = await req.json().catch(() => ({}));
    const native = wantsNativeReturn(body);
    const successUrl = native
      ? appHandoffUrl(siteUrl, "cheery://profile", { checkout: "success" })
      : `${siteUrl}/profile?checkout=success`;
    const cancelUrl = native
      ? appHandoffUrl(siteUrl, "cheery://profile", { checkout: "cancel" })
      : `${siteUrl}/profile?checkout=cancel`;

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      allow_promotion_codes: true,
      metadata: { supabase_user_id: user.id },
      subscription_data: {
        metadata: { supabase_user_id: user.id },
      },
    });

    return new Response(JSON.stringify({ url: session.url }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
