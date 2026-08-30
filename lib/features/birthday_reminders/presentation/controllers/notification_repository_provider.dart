import 'package:cheery/core/offline/offline_aware_notification_repository.dart';
import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/birthday_reminders/data/notification_repository_impl.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<NotificationRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final supabase = ref.watch(supabaseClientProvider);
  final remote = NotificationRepositoryImpl(supabase);
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) return remote;
  return OfflineAwareNotificationRepository(
    remote: remote,
    store: ref.watch(offlineStoreProvider),
    queue: ref.watch(syncQueueProvider),
    engine: engine,
    connectivity: ref.watch(connectivityMonitorProvider),
    userId: () {
      final id = supabase.auth.currentUser?.id;
      if (id == null) {
        throw const NotificationUnknownFailure('Usuário não autenticado.');
      }
      return id;
    },
  );
});
