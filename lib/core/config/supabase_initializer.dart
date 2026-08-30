import 'package:cheery/core/config/app_env.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase when valid credentials are present in `.env`.
abstract final class SupabaseInitializer {
  static Future<bool> initialize() async {
    if (!AppEnv.hasSupabaseConfig) {
      AppLogger.w(
        'Supabase ainda com placeholder. '
        'Edite assets/env/.env com SUPABASE_URL e SUPABASE_ANON_KEY '
        '(Dashboard → Project Settings → API) e faça hot restart.',
      );
      return false;
    }

    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabaseAnonKey,
    );
    AppLogger.i('Supabase conectado em ${AppEnv.supabaseUrl}');
    return true;
  }
}
