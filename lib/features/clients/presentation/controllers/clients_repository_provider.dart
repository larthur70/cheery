import 'package:cheery/core/offline/offline_aware_clients_repository.dart';
import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/clients/data/clients_repository_impl.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/domain/clients_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientsRepositoryProvider = Provider<ClientsRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final supabase = ref.watch(supabaseClientProvider);
  final remote = ClientsRepositoryImpl(supabase);
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) return remote;
  return OfflineAwareClientsRepository(
    remote: remote,
    store: ref.watch(offlineStoreProvider),
    queue: ref.watch(syncQueueProvider),
    engine: engine,
    connectivity: ref.watch(connectivityMonitorProvider),
    userId: () {
      final id = supabase.auth.currentUser?.id;
      if (id == null) {
        throw const ClientsUnknownFailure('Usuário não autenticado.');
      }
      return id;
    },
  );
});
