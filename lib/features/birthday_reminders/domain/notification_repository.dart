import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';

/// Contract for push token persistence and reminder settings.
abstract class NotificationRepository {
  Future<ReminderSettings> fetchSettings();

  Future<ReminderSettings> updateSettings(ReminderSettings settings);

  Future<void> upsertPushToken({
    required String token,
    required String platform,
  });

  Future<void> deletePushToken(String token);

  Future<void> deleteAllPushTokens();
}
