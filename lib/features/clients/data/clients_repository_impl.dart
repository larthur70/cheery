import 'dart:math';

import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/domain/clients_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  ClientsRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _pageSize = 200;
  static const _maxRows = 2000;
  static const _insertChunkSize = 150;
  static const _clientSelect = '*, templates(id, name, is_default)';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const ClientsUnknownFailure('Usuário não autenticado.');
    }
    return id;
  }

  @override
  Future<List<Client>> listClients({String? query}) async {
    try {
      final trimmed = query?.trim();
      final safeQuery = trimmed
          ?.replaceAll(RegExp(r'[%_,]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final rows = <Map<String, dynamic>>[];
      var from = 0;
      while (rows.length < _maxRows) {
        PostgrestFilterBuilder<PostgrestList> pageQuery = _client
            .from('clients')
            .select(_clientSelect)
            .eq('user_id', _userId);
        if (safeQuery != null && safeQuery.isNotEmpty) {
          final pattern = '%$safeQuery%';
          pageQuery = pageQuery.or('name.ilike.$pattern,phone.ilike.$pattern');
        }
        final page = await pageQuery
            .order('birth_date')
            .range(from, from + _pageSize - 1);
        for (final row in page) {
          rows.add(Map<String, dynamic>.from(row as Map));
        }
        if (page.length < _pageSize) break;
        from += _pageSize;
      }
      return rows.map(_mapClient).toList();
    } on ClientsFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('listClients failed', error: error, stackTrace: stackTrace);
      throw ClientsUnknownFailure(error.message);
    } catch (error, stackTrace) {
      AppLogger.e('listClients unexpected', error: error, stackTrace: stackTrace);
      throw const ClientsNetworkFailure();
    }
  }

  @override
  Future<Client> createClient({
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    try {
      final data = await _client
          .from('clients')
          .insert({
            'user_id': _userId,
            'name': name.trim(),
            'phone': phone.trim(),
            'birth_date': _dateOnly(birthDate),
            'template_id': templateId,
            'automatic_enabled': automaticEnabled,
          })
          .select(_clientSelect)
          .single();

      return _mapClient(Map<String, dynamic>.from(data));
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('createClient failed', error: error, stackTrace: stackTrace);
      throw _mapClientPostgrest(error);
    } catch (error, stackTrace) {
      if (error is ClientsFailure) rethrow;
      AppLogger.e(
        'createClient unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ClientsNetworkFailure();
    }
  }

  @override
  Future<List<Client>> createClientsBatch(
    List<
        ({
          String name,
          String phone,
          DateTime birthDate,
          String templateId,
          bool automaticEnabled,
        })> rows,
  ) async {
    if (rows.isEmpty) return const [];

    try {
      final payload = rows
          .map(
            (row) => {
              'user_id': _userId,
              'name': row.name.trim(),
              'phone': row.phone.trim(),
              'birth_date': _dateOnly(row.birthDate),
              'template_id': row.templateId,
              'automatic_enabled': row.automaticEnabled,
            },
          )
          .toList();

      final created = <Client>[];
      for (var i = 0; i < payload.length; i += _insertChunkSize) {
        final end = min(i + _insertChunkSize, payload.length);
        final chunk = payload.sublist(i, end);
        final data = await _client
            .from('clients')
            .insert(chunk)
            .select(_clientSelect);
        created.addAll(
          (data as List).map(
            (row) => _mapClient(Map<String, dynamic>.from(row as Map)),
          ),
        );
      }
      return created;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e(
        'createClientsBatch failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapClientPostgrest(error);
    } catch (error, stackTrace) {
      if (error is ClientsFailure) rethrow;
      AppLogger.e(
        'createClientsBatch unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ClientsNetworkFailure();
    }
  }

  @override
  Future<Client> updateClient({
    required String id,
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    try {
      final data = await _client
          .from('clients')
          .update({
            'name': name.trim(),
            'phone': phone.trim(),
            'birth_date': _dateOnly(birthDate),
            'template_id': templateId,
            'automatic_enabled': automaticEnabled,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId)
          .select(_clientSelect)
          .maybeSingle();

      if (data == null) {
        throw const ClientsNotFoundFailure();
      }

      return _mapClient(Map<String, dynamic>.from(data));
    } on ClientsFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('updateClient failed', error: error, stackTrace: stackTrace);
      throw _mapClientPostgrest(error);
    } catch (error, stackTrace) {
      if (error is ClientsFailure) rethrow;
      AppLogger.e(
        'updateClient unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ClientsNetworkFailure();
    }
  }

  @override
  Future<Client> setBirthdayMessageSent({
    required String id,
    required bool sent,
  }) async {
    try {
      final data = await _client
          .from('clients')
          .update({
            'message_sent_year': sent ? DateTime.now().year : null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId)
          .select(_clientSelect)
          .maybeSingle();

      if (data == null) {
        throw const ClientsNotFoundFailure();
      }

      return _mapClient(Map<String, dynamic>.from(data));
    } on ClientsFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e(
        'setBirthdayMessageSent failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ClientsUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is ClientsFailure) rethrow;
      AppLogger.e(
        'setBirthdayMessageSent unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ClientsNetworkFailure();
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    await deleteClients([id]);
  }

  @override
  Future<void> deleteClients(List<String> ids) async {
    final uniqueIds = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (uniqueIds.isEmpty) return;

    try {
      await _client
          .from('clients')
          .delete()
          .inFilter('id', uniqueIds)
          .eq('user_id', _userId);
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('deleteClients failed', error: error, stackTrace: stackTrace);
      throw ClientsUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is ClientsFailure) rethrow;
      AppLogger.e(
        'deleteClients unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ClientsNetworkFailure();
    }
  }

  Client _mapClient(Map<String, dynamic> row) {
    final embedded = row['templates'];
    String? templateName;
    if (embedded is Map) {
      templateName = embedded['name'] as String?;
    }

    final flat = Map<String, dynamic>.from(row)
      ..remove('templates')
      ..remove('notes')
      ..remove('birth_month')
      ..remove('birth_day')
      ..['template_name'] = templateName
      ..['phone'] = (row['phone'] as String?) ?? '';

    return Client.fromJson(flat);
  }

  ClientsFailure _mapClientPostgrest(PostgrestException error) {
    final message = error.message;
    final code = error.code;
    if (code == '23505' ||
        message.contains('clients_user_phone_digits_key') ||
        message.contains('duplicate key') ||
        message.toLowerCase().contains('unique')) {
      return const ClientsDuplicatePhoneFailure();
    }
    if (code == 'P0001' ||
        message.contains('Limite de') ||
        message.toLowerCase().contains('plano free')) {
      return ClientsPlanLimitFailure();
    }
    if (message.contains('template aprovado')) {
      return const ClientsAutomaticRequiresApprovedTemplateFailure();
    }
    if (message.contains('integração WhatsApp') ||
        message.contains('WhatsApp')) {
      return const ClientsAutomaticRequiresWhatsAppFailure();
    }
    return ClientsUnknownFailure(message);
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
