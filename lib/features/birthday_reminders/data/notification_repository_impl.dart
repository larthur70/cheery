import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_repository.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const NotificationUnknownFailure(
        'Usuário não autenticado.',
      );
    }
    return id;
  }

  @override
  Future<ReminderSettings> fetchSettings() async {
    try {
      final data = await _client
          .from('profiles')
          .select(
            'notifications_enabled, notification_time, timezone',
          )
          .eq('id', _userId)
          .single();
      return ReminderSettings.fromJson(Map<String, dynamic>.from(data));
    } on NotificationFailure {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.e(
        'fetchSettings failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationUnknownFailure(
        'Não foi possível carregar as configurações de lembrete.',
      );
    }
  }

  @override
  Future<ReminderSettings> updateSettings(ReminderSettings settings) async {
    try {
      final data = await _client
          .from('profiles')
          .update({
            'notifications_enabled': settings.notificationsEnabled,
            'notification_time': settings.notificationTime,
            'timezone': settings.timezone,
          })
          .eq('id', _userId)
          .select(
            'notifications_enabled, notification_time, timezone',
          )
          .single();
      return ReminderSettings.fromJson(Map<String, dynamic>.from(data));
    } on NotificationFailure {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.e(
        'updateSettings failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationUnknownFailure(
        'Não foi possível salvar as configurações de lembrete.',
      );
    }
  }

  @override
  Future<void> upsertPushToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _client.from('push_tokens').upsert(
        {
          'user_id': _userId,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'upsertPushToken failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationUnknownFailure(
        'Não foi possível registrar o dispositivo para notificações.',
      );
    }
  }

  @override
  Future<void> deletePushToken(String token) async {
    try {
      await _client
          .from('push_tokens')
          .delete()
          .eq('user_id', _userId)
          .eq('token', token);
    } catch (error, stackTrace) {
      AppLogger.e(
        'deletePushToken failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationUnknownFailure(
        'Não foi possível remover o token de notificação.',
      );
    }
  }

  @override
  Future<void> deleteAllPushTokens() async {
    try {
      await _client.from('push_tokens').delete().eq('user_id', _userId);
    } catch (error, stackTrace) {
      AppLogger.e(
        'deleteAllPushTokens failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationUnknownFailure(
        'Não foi possível remover os tokens de notificação.',
      );
    }
  }
}
