import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_repository.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/fcm_service_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/notification_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reminderControllerProvider =
    AsyncNotifierProvider<ReminderController, ReminderSettings>(
  ReminderController.new,
);

class ReminderController extends AsyncNotifier<ReminderSettings> {
  NotificationRepository get _repository {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository == null) {
      throw const NotificationNotReadyFailure();
    }
    return repository;
  }

  @override
  Future<ReminderSettings> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    if (repository == null) {
      throw const NotificationNotReadyFailure();
    }
    return repository.fetchSettings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchSettings());
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const ReminderSettings();
    final fcm = ref.read(fcmServiceProvider);

    if (enabled && fcm.isSupported) {
      final alreadyGranted = await fcm.isPermissionGranted();
      final granted =
          alreadyGranted ? true : await fcm.requestPermission();
      if (!granted) {
        throw const NotificationPermissionFailure();
      }
      final token = await fcm.getToken();
      final platform = fcm.platformName;
      if (token == null || platform == null) {
        throw const NotificationUnknownFailure(
          'Não foi possível obter o token de notificação.',
        );
      }
      await _repository.upsertPushToken(token: token, platform: platform);
    }

    final next = current.copyWith(notificationsEnabled: enabled);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.updateSettings(next));
    if (state.hasError) {
      final error = state.error;
      if (error is NotificationFailure) throw error;
      throw NotificationUnknownFailure(error.toString());
    }
  }

  Future<void> updateTime(String notificationTime) async {
    final current = state.valueOrNull ?? const ReminderSettings();
    final next = current.copyWith(notificationTime: notificationTime);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.updateSettings(next));
    _rethrowIfError();
  }

  Future<void> updateTimezone(String timezone) async {
    final current = state.valueOrNull ?? const ReminderSettings();
    final next = current.copyWith(timezone: timezone);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.updateSettings(next));
    _rethrowIfError();
  }

  Future<void> syncTokenIfEnabled() async {
    final settings = state.valueOrNull;
    if (settings == null || !settings.notificationsEnabled) return;

    final fcm = ref.read(fcmServiceProvider);
    if (!fcm.isSupported) return;

    final token = await fcm.getToken();
    final platform = fcm.platformName;
    if (token == null || platform == null) return;

    await _repository.upsertPushToken(token: token, platform: platform);
  }

  void _rethrowIfError() {
    if (!state.hasError) return;
    final error = state.error;
    if (error is NotificationFailure) throw error;
    throw NotificationUnknownFailure(error.toString());
  }
}
