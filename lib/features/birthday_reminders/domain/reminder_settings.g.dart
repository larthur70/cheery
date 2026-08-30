// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReminderSettings _$ReminderSettingsFromJson(Map<String, dynamic> json) =>
    _ReminderSettings(
      notificationsEnabled: json['notifications_enabled'] as bool? ?? false,
      notificationTime: json['notification_time'] as String? ?? '08:00:00',
      timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
    );

Map<String, dynamic> _$ReminderSettingsToJson(_ReminderSettings instance) =>
    <String, dynamic>{
      'notifications_enabled': instance.notificationsEnabled,
      'notification_time': instance.notificationTime,
      'timezone': instance.timezone,
    };
