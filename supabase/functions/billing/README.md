# Stripe billing

## Edge functions

| Function | Auth | Purpose |
|----------|------|---------|
| `create-checkout-session` | yes | Opens Stripe Checkout for Pro (R$ 49,90/mês) |
| `create-portal-session` | yes | Opens Stripe Customer Portal |
| `stripe-webhook` | Stripe signature | Syncs `profiles.plan` from subscription events |

## Secrets

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `SITE_URL` — app origin for success/cancel redirects (must include scheme, e.g. `https://app.usecheery.com`). Falls back to `APP_ORIGIN`, then production default.
  Mobile checkout/portal pass `return_origin: cheery://` so Stripe returns via `/open.html` into the native app.
- `STRIPE_PRICE_ID_PRO` — optional; overrides hardcoded live price

## Pro price

Current Stripe Price ID (Live fallback in `create-checkout-session`):

`price_1U4ldoKCeWtlJSTVWPBnCPsF` — Cheery Pro monthly (R$ 49,90)

## Setup

1. Create Product **Cheery Pro** with recurring Price **R$ 49,90 / month**.
2. Keep `DEFAULT_PRO_PRICE_ID` in `create-checkout-session/index.ts` in sync with Stripe.
3. Deploy the edge functions and configure the webhook endpoint.
