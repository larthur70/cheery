import 'dart:async';

import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/offline_database.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_engine.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final offlineDatabaseProvider = Provider<OfflineDatabase>((ref) {
  return OfflineDatabase();
});

final offlineStoreProvider = Provider<OfflineStore>((ref) {
  return OfflineStore(ref.watch(offlineDatabaseProvider));
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.watch(offlineDatabaseProvider));
});

final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  unawaited(monitor.start());
  ref.onDispose(monitor.dispose);
  return monitor;
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final monitor = ref.watch(connectivityMonitorProvider);
  yield monitor.isOnline;
  yield* monitor.changes;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) async* {
  final queue = ref.watch(syncQueueProvider);
  yield await queue.length;
  yield* queue.pendingCount;
});

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    store: ref.watch(offlineStoreProvider),
    client: ref.watch(supabaseClientProvider),
  );
  ref.listen<AsyncValue<bool>>(isOnlineProvider, (_, next) {
    if (next.valueOrNull == true) {
      unawaited(engine.process());
    }
  });
  return engine;
});
