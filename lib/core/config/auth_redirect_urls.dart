import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Platform-aware redirect URLs for Supabase Auth (email confirm + OAuth).
abstract final class AuthRedirectUrls {
  /// Deep link for iOS/Android. Must be listed in Supabase Redirect URLs.
  static const mobileCallback = 'cheery://auth-callback';

  /// Production web OAuth callback (GoRouter route `/auth/callback`).
  static const webOAuthCallback = 'https://app.usecheery.com/auth/callback';

  /// Production web password-reset landing (`/auth/reset-password`).
  static const webPasswordResetCallback =
      'https://app.usecheery.com/auth/reset-password';

  static String get emailRedirectTo {
    if (kIsWeb) {
      final base = Uri.base;
      if (base.scheme == 'http' || base.scheme == 'https') {
        return '${base.origin}/home';
      }
    }
    return mobileCallback;
  }

  /// Google/Apple OAuth redirect.
  /// Web uses the current origin (localhost in dev, usecheery.com in prod).
  /// Optional AUTH_OAUTH_REDIRECT overrides when origin is unavailable.
  /// Mobile always uses the deep link.
  static String get oauthRedirectTo {
    if (!kIsWeb) return mobileCallback;

    final base = Uri.base;
    if (base.scheme == 'http' || base.scheme == 'https') {
      return '${base.origin}/auth/callback';
    }

    final fromEnv = dotenv.env['AUTH_OAUTH_REDIRECT']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return webOAuthCallback;
  }

  /// Password reset email link.
  /// Web uses the current origin; AUTH_PASSWORD_RESET_REDIRECT is fallback.
  /// Mobile uses the deep link so the email reopens the app.
  static String get passwordResetRedirectTo {
    if (!kIsWeb) return mobileCallback;

    final base = Uri.base;
    if (base.scheme == 'http' || base.scheme == 'https') {
      return '${base.origin}/auth/reset-password';
    }

    final fromEnv = dotenv.env['AUTH_PASSWORD_RESET_REDIRECT']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return webPasswordResetCallback;
  }
}
