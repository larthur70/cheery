import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_settings.freezed.dart';
part 'reminder_settings.g.dart';

@freezed
abstract class ReminderSettings with _$ReminderSettings {
  const factory ReminderSettings({
    @JsonKey(name: 'notifications_enabled')
    @Default(false)
    bool notificationsEnabled,
    /// Postgres `time` as `HH:mm:ss` (or `HH:mm`).
    @JsonKey(name: 'notification_time')
    @Default('08:00:00')
    String notificationTime,
    @Default('America/Sao_Paulo') String timezone,
  }) = _ReminderSettings;

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      _$ReminderSettingsFromJson(json);
}

extension ReminderSettingsTime on ReminderSettings {
  /// Display / TimeOfDay-friendly `HH:mm`.
  String get notificationTimeHm {
    final parts = notificationTime.split(':');
    if (parts.length < 2) return '08:00';
    final h = parts[0].padLeft(2, '0');
    final m = parts[1].padLeft(2, '0');
    return '$h:$m';
  }

  static String formatTimeOfDay(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
