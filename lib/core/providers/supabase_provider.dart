import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Whether Supabase was successfully initialized at startup.
final supabaseReadyProvider = Provider<bool>((ref) {
  throw UnimplementedError(
    'supabaseReadyProvider must be overridden in ProviderScope',
  );
});

/// Supabase client. Only resolve when [supabaseReadyProvider] is true.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) {
    throw StateError(
      'Supabase is not configured. Update assets/env/.env with real credentials.',
    );
  }
  return Supabase.instance.client;
});
