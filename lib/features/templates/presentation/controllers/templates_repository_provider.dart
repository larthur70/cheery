import 'package:cheery/core/offline/offline_aware_templates_repository.dart';
import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/templates/data/templates_repository_impl.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/domain/templates_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templatesRepositoryProvider = Provider<TemplatesRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final supabase = ref.watch(supabaseClientProvider);
  final remote = TemplatesRepositoryImpl(supabase);
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) return remote;
  return OfflineAwareTemplatesRepository(
    remote: remote,
    store: ref.watch(offlineStoreProvider),
    queue: ref.watch(syncQueueProvider),
    engine: engine,
    connectivity: ref.watch(connectivityMonitorProvider),
    userId: () {
      final id = supabase.auth.currentUser?.id;
      if (id == null) {
        throw const TemplatesUnknownFailure('Usuário não autenticado.');
      }
      return id;
    },
  );
});
