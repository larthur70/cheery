import 'package:cheery/core/config/app_deep_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDeepLinks.goLocationFrom', () {
    test('maps profile checkout return', () {
      expect(
        AppDeepLinks.goLocationFrom(
          Uri.parse('cheery://profile?checkout=success'),
        ),
        '/profile?checkout=success',
      );
    });

    test('maps confirm-delete with token', () {
      expect(
        AppDeepLinks.goLocationFrom(
          Uri.parse('cheery://auth/confirm-delete?token=abc'),
        ),
        '/auth/confirm-delete?token=abc',
      );
    });

    test('maps WhatsApp callback', () {
      expect(
        AppDeepLinks.goLocationFrom(
          Uri.parse('cheery://whatsapp/callback?code=xyz'),
        ),
        '/whatsapp/callback?code=xyz',
      );
    });

    test('leaves auth-callback to supabase_flutter', () {
      expect(
        AppDeepLinks.goLocationFrom(
          Uri.parse('cheery://auth-callback?code=pkce'),
        ),
        isNull,
      );
    });

    test('ignores https URLs', () {
      expect(
        AppDeepLinks.goLocationFrom(
          Uri.parse('https://app.usecheery.com/profile?checkout=success'),
        ),
        isNull,
      );
    });
  });
}
