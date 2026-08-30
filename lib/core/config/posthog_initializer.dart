import 'package:cheery/core/config/app_env.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Boots PostHog from env vars. Never throws — analytics must be optional.
///
/// On **web**, `posthog_flutter` only wraps `window.posthog`. The JS snippet
/// in `web/index.html` must call `posthog.init(...)` or captures are no-ops.
abstract final class PosthogInitializer {
  static Future<bool> initialize() async {
    if (!AppEnv.hasPosthogConfig) {
      AppLogger.i('PostHog skipped (missing POSTHOG_API_KEY)');
      return false;
    }

    try {
      final config = PostHogConfig(AppEnv.posthogApiKey)
        ..host = AppEnv.posthogHost
        // Custom `sessao_aberta` owns session analytics.
        ..captureApplicationLifecycleEvents = false
        ..debug = kDebugMode;
      await Posthog().setup(config);
      AppLogger.i(
        'PostHog ready (host=${AppEnv.posthogHost}'
        '${kIsWeb ? ', web=requires index.html snippet' : ''})',
      );
      return true;
    } catch (error, stackTrace) {
      AppLogger.e(
        'PostHog setup failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
