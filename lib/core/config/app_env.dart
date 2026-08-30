import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables loaded from `assets/env/.env`.
///
/// Fill in your Supabase Project URL and anon/publishable key manually.
abstract final class AppEnv {
  static const _placeholderUrl = 'YOUR_SUPABASE_URL';
  static const _placeholderKey = 'YOUR_SUPABASE_ANON_KEY';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL']?.trim() ?? '';

  /// Anon/public key (also accepts SUPABASE_PUBLISHABLE_KEY).
  static String get supabaseAnonKey {
    final anon = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    if (anon != null && anon.isNotEmpty) return anon;
    return dotenv.env['SUPABASE_PUBLISHABLE_KEY']?.trim() ?? '';
  }

  static bool get hasSupabaseConfig {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) return false;
    if (url == _placeholderUrl || key == _placeholderKey) return false;
    if (url.contains('your-project') || key == 'your-anon-key') return false;
    return true;
  }

  /// PostHog project API key (Project Settings → Project API Key).
  static String get posthogApiKey =>
      dotenv.env['POSTHOG_API_KEY']?.trim() ?? '';

  /// PostHog ingest host. Defaults to US cloud.
  static String get posthogHost {
    final host = dotenv.env['POSTHOG_HOST']?.trim();
    if (host != null && host.isNotEmpty) return host;
    return 'https://us.i.posthog.com';
  }

  static bool get hasPosthogConfig {
    final key = posthogApiKey;
    if (key.isEmpty) return false;
    if (key == 'YOUR_POSTHOG_API_KEY' || key == 'phc_xxx') return false;
    return true;
  }
}
