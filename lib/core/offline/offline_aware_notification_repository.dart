import 'dart:async';

import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_engine.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_repository.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';

class OfflineAwareNotificationRepository implements NotificationRepository {
  OfflineAwareNotificationRepository({
    required NotificationRepository remote,
    required OfflineStore store,
    required SyncQueue queue,
    required SyncEngine engine,
    required ConnectivityMonitor connectivity,
    required String Function() userId,
  })  : _remote = remote,
        _store = store,
        _queue = queue,
        _engine = engine,
        _connectivity = connectivity,
        _userId = userId;

  final NotificationRepository _remote;
  final OfflineStore _store;
  final SyncQueue _queue;
  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  final String Function() _userId;

  @override
  Future<ReminderSettings> fetchSettings() async {
    if (_connectivity.isOnline) {
      try {
        final settings = await _remote.fetchSettings();
        await _store.saveReminders(_userId(), settings);
        return settings;
      } catch (_) {
        final cached = await _store.loadReminders(_userId());
        if (cached != null) return cached;
        rethrow;
      }
    }
    return await _store.loadReminders(_userId()) ?? const ReminderSettings();
  }

  @override
  Future<ReminderSettings> updateSettings(ReminderSettings settings) async {
    await _store.saveReminders(_userId(), settings);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.reminder,
        action: SyncAction.update,
        entityId: _userId(),
        payload: settings.toJson(),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
    return settings;
  }

  @override
  Future<void> upsertPushToken({
    required String token,
    required String platform,
  }) async {
    if (!_connectivity.isOnline) return;
    await _remote.upsertPushToken(token: token, platform: platform);
  }

  @override
  Future<void> deletePushToken(String token) {
    return _remote.deletePushToken(token);
  }

  @override
  Future<void> deleteAllPushTokens() {
    return _remote.deleteAllPushTokens();
  }
}
