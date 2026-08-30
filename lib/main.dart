import 'package:cheery/app.dart';
import 'package:cheery/core/config/posthog_initializer.dart';
import 'package:cheery/core/config/supabase_initializer.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/auth/presentation/controllers/password_recovery_pending_provider.dart';
import 'package:cheery/firebase_options.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are delivered by the OS; keep handler registered.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required so Supabase redirects like /auth/reset-password work on web
  // (default hash URLs ignore the path and bounce recovery users to /home).
  usePathUrlStrategy();

  // Capture BEFORE Supabase.initialize clears auth params from the URL.
  final passwordRecoveryBootstrap = detectPasswordRecoveryFromUri(Uri.base);

  await dotenv.load(fileName: 'assets/env/.env');
  await initializeDateFormatting('pt_BR');

  final mobileFirebase = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  if (mobileFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final supabaseReady = await SupabaseInitializer.initialize();
  final posthogReady = await PosthogInitializer.initialize();
  AppLogger.i(
    'Starting Cheery (supabaseReady=$supabaseReady, posthogReady=$posthogReady)',
  );

  final analytics = AnalyticsService();
  if (posthogReady) {
    analytics.markEnabled();
  }

  runApp(
    ProviderScope(
      overrides: [
        supabaseReadyProvider.overrideWithValue(supabaseReady),
        passwordRecoveryBootstrapProvider.overrideWithValue(
          passwordRecoveryBootstrap,
        ),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
      child: const CheeryApp(),
    ),
  );
}
