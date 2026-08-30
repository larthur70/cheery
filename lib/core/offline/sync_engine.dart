import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Replays queued writes against Supabase in insertion order.
class SyncEngine {
  SyncEngine({
    required this.queue,
    required this.store,
    required this.client,
  });

  final SyncQueue queue;
  final OfflineStore store;
  final SupabaseClient client;

  var _running = false;

  String? get _userId => client.auth.currentUser?.id;

  Future<void> process() async {
    if (_running) return;
    _running = true;
    try {
      while (true) {
        final op = await queue.peek();
        if (op == null) return;
        try {
          await _execute(op);
          await queue.remove(op.id);
        } catch (error, stackTrace) {
          AppLogger.e(
            'sync op ${op.action.name} ${op.entity.name} failed',
            error: error,
            stackTrace: stackTrace,
          );
          if (isLikelyNetworkError(error)) return;
          // Drop unrecoverable ops so the rest of the queue can move.
          await queue.remove(op.id);
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _execute(SyncOperation op) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('Not signed in');
    }
    switch (op.entity) {
      case SyncEntity.client:
        await _executeClient(userId, op);
      case SyncEntity.template:
        await _executeTemplate(userId, op);
      case SyncEntity.profile:
        await _executeProfile(userId, op);
      case SyncEntity.reminder:
        await _executeReminder(userId, op);
    }
  }

  Future<void> _executeClient(String userId, SyncOperation op) async {
    switch (op.action) {
      case SyncAction.create:
        await client.from('clients').upsert(_clientRow(op.payload));
      case SyncAction.update:
      case SyncAction.setMessageSent:
        await client
            .from('clients')
            .update(_clientUpdate(op.payload))
            .eq('id', op.entityId)
            .eq('user_id', userId);
      case SyncAction.delete:
        await client
            .from('clients')
            .delete()
            .eq('id', op.entityId)
            .eq('user_id', userId);
    }
  }

  Future<void> _executeTemplate(String userId, SyncOperation op) async {
    switch (op.action) {
      case SyncAction.create:
        await client.from('templates').upsert(_templateRow(op.payload));
      case SyncAction.update:
        await client.from('templates').update({
          'name': op.payload['name'],
          'message': op.payload['message'],
          'variables': op.payload['variables'],
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', op.entityId).eq('user_id', userId);
      case SyncAction.delete:
        await client
            .from('templates')
            .delete()
            .eq('id', op.entityId)
            .eq('user_id', userId);
      case SyncAction.setMessageSent:
        break;
    }
  }

  Future<void> _executeProfile(String userId, SyncOperation op) async {
    await client.from('profiles').update({
      if (op.payload['full_name'] != null) 'full_name': op.payload['full_name'],
      if (op.payload['company_name'] != null)
        'company_name': op.payload['company_name'],
      if (op.payload['onboarding_completed'] != null)
        'onboarding_completed': op.payload['onboarding_completed'],
    }).eq('id', userId);
  }

  Future<void> _executeReminder(String userId, SyncOperation op) async {
    await client.from('profiles').update({
      'notifications_enabled': op.payload['notifications_enabled'],
      'notification_time': op.payload['notification_time'],
      'timezone': op.payload['timezone'],
    }).eq('id', userId);
  }

  Map<String, dynamic> _clientRow(Map<String, dynamic> payload) {
    final client = Client.fromJson(payload);
    final birth = client.birthDate;
    final y = birth.year.toString().padLeft(4, '0');
    final m = birth.month.toString().padLeft(2, '0');
    final d = birth.day.toString().padLeft(2, '0');
    return {
      'id': client.id,
      'user_id': client.userId,
      'name': client.name,
      'phone': client.phone,
      'birth_date': '$y-$m-$d',
      'template_id': client.templateId,
      'automatic_enabled': client.automaticEnabled,
      'message_sent_year': client.messageSentYear,
    };
  }

  Map<String, dynamic> _clientUpdate(Map<String, dynamic> payload) {
    final row = Map<String, dynamic>.from(payload);
    if (row['birth_date'] is String &&
        (row['birth_date'] as String).contains('T')) {
      final date = DateTime.parse(row['birth_date'] as String);
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      row['birth_date'] = '$y-$m-$d';
    }
    row.remove('template_name');
    row.remove('created_at');
    row['updated_at'] = DateTime.now().toUtc().toIso8601String();
    return row;
  }

  Map<String, dynamic> _templateRow(Map<String, dynamic> payload) {
    final template = Template.fromJson(payload);
    return {
      'id': template.id,
      'user_id': template.userId,
      'name': template.name,
      'message': template.message,
      'variables': template.variables,
      'is_default': template.isDefault,
    };
  }

}
