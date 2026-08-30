import 'package:cheery/core/constants/app_routes.dart';
import 'package:flutter/foundation.dart';

/// Custom-scheme URLs that reopen the native app after Stripe, email, or OAuth.
abstract final class AppDeepLinks {
  static const scheme = 'cheery';
  static const nativeOrigin = 'cheery://';

  static const profile = 'cheery://profile';
  static const confirmDelete = 'cheery://auth/confirm-delete';
  static const whatsappCallback = 'cheery://whatsapp/callback';
  static const authCallback = 'cheery://auth-callback';

  /// Sent to Edge Functions so HTTPS return URLs bounce back into the app.
  static Map<String, dynamic> nativeReturnBody([
    Map<String, dynamic>? extra,
  ]) {
    final body = <String, dynamic>{...?extra};
    if (!kIsWeb) {
      body['return_origin'] = nativeOrigin;
    }
    return body;
  }

  /// Maps `cheery://…` to a GoRouter location, or null to leave the URI alone
  /// (auth-callback is owned by supabase_flutter).
  static String? goLocationFrom(Uri uri) {
    if (uri.scheme != scheme) return null;

    final query = uri.hasQuery ? '?${uri.query}' : '';
    final host = uri.host;
    final path = uri.path;

    if (host == 'auth-callback') {
      return null;
    }
    if (host == 'profile') {
      return '${AppRoutes.profile}$query';
    }
    if (host == 'auth' &&
        (path == '/confirm-delete' || path.startsWith('/confirm-delete/'))) {
      return '${AppRoutes.confirmDelete}$query';
    }
    if (host == 'whatsapp') {
      final suffix = path.isEmpty ? '/callback' : path;
      return '/whatsapp$suffix$query';
    }
    return null;
  }
}
