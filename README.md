# Cheery

Cheery is a Flutter app for small businesses that want to keep customer relationships warm: store clients, remember birthdays, send WhatsApp messages from templates, and get reminders when it is time to reach out.

It runs on **iOS**, **Android**, and **Web**, with the same product surface and a backend on **Supabase** (Auth, Postgres, Edge Functions). **Firebase Cloud Messaging** delivers push notifications. **Stripe** handles Pro billing. **PostHog** is used for product analytics.

## What the product does

- **Clients** — CRM-style list of customers (name, phone, birthday, notes), with import from contacts, CSV, or Excel.
- **Calendar** — birthdays and relationship dates in one place.
- **Templates** — reusable WhatsApp messages, including an automatic birthday flow.
- **Reminders** — local notifications and FCM push when a birthday is coming up.
- **WhatsApp** — connect a Meta/WhatsApp Business account, sync approved templates, and send messages (manual or automatic).
- **Auth** — email/password, Google, and Sign in with Apple, plus password recovery and account deletion with email confirmation.
- **Billing** — free plan with client limits and a Pro waitlist / Stripe checkout for the paid plan.
- **Offline** — local Sembast cache and a sync queue so the app still works with a weak connection.

## Architecture

The app follows **clean architecture** per feature (`domain` / `data` / `presentation`). Shared infrastructure lives under `lib/core` (router, env, offline, widgets). Global state uses **Riverpod**. Navigation uses **go_router**.

```
lib/
  core/           shared config, routing, offline, UI shell
  features/       auth, clients, calendar, templates, messaging, billing, …
  services/       analytics
supabase/         migrations, Edge Functions, email templates
```

Backend pieces in this repo:

| Area | Location |
|------|----------|
| SQL migrations | `supabase/migrations/` |
| Edge Functions | `supabase/functions/` (billing, Stripe webhook, birthday reminders, WhatsApp, account deletion, …) |
| Auth email HTML | `supabase/email-templates/` |

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK `^3.11.5`, see `pubspec.yaml`)
- A [Supabase](https://supabase.com/) project
- Firebase project (FCM) if you need push on iOS/Android
- Optional: Stripe, PostHog, Meta WhatsApp, Resend (transactional email)

## Setup

1. Clone this repository (this folder **is** the Flutter project root).

2. Copy environment variables:

   ```bash
   cp assets/env/.env.example assets/env/.env
   ```

   Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY` (Dashboard → Project Settings → API). Use only the **anon** key in the app. The **service role** key stays in Edge Function secrets, never in the client.

3. Install packages and run:

   ```bash
   flutter pub get
   flutter run
   ```

4. **Web analytics:** replace `YOUR_POSTHOG_API_KEY` in `web/index.html` with your PostHog project API key (public client token). Keep the same value in `.env` for mobile.

5. **Supabase:** apply migrations and deploy functions from `supabase/` with the [Supabase CLI](https://supabase.com/docs/guides/cli). Configure Auth redirect URLs as described in `assets/env/.env.example`.

6. **iOS / Android signing and Firebase:** use your own upload keystore (`android/key.properties` is gitignored) and your Firebase/FlutterFire config if you are not using the bundled client files.

## Secrets that must never be committed

These are ignored by `.gitignore` (or must stay out of git):

| Item | Why |
|------|-----|
| `assets/env/.env` | Supabase URL/anon key and PostHog key for your environment |
| `android/key.properties`, `*.jks` / `*.keystore` | Play Store upload signing |
| `*.p8`, `utils_project/` | Apple Sign In private key, Team ID, Key ID |
| Firebase **service account** JSON | FCM from Edge Functions (`FCM_SERVICE_ACCOUNT_JSON`) |
| Stripe **secret** key, `CRON_SECRET`, `RESEND_API_KEY`, Meta app secret | Edge Function secrets only |

Firebase `google-services.json`, `GoogleService-Info.plist`, and `lib/firebase_options.dart` are **client** identifiers (restricted by bundle ID / SHA). They are not service-account credentials. Rotate any key that was ever committed by accident (Apple `.p8`, keystore passwords, service role, Stripe secret).

## License

All rights reserved.
