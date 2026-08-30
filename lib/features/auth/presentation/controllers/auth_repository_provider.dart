import 'package:cheery/core/offline/offline_aware_auth_repository.dart';
import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/auth/data/auth_repository_impl.dart';
import 'package:cheery/features/auth/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final remote = AuthRepositoryImpl(ref.watch(supabaseClientProvider));
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) return remote;
  return OfflineAwareAuthRepository(
    remote: remote,
    store: ref.watch(offlineStoreProvider),
    queue: ref.watch(syncQueueProvider),
    engine: engine,
    connectivity: ref.watch(connectivityMonitorProvider),
  );
});
