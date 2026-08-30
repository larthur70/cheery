import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/domain/templates_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  TemplatesRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const defaultTemplateName = 'Mensagem padrão';
  static const defaultTemplateMessage =
      'Olá {{1}}! Passando para desejar um feliz aniversário. — Equipe {{2}}';
  static const defaultTemplateVariables = ['client_name', 'company_name'];

  static const _selectFull =
      'id, user_id, name, message, variables, is_default, '
      'approval_status, meta_template_name, meta_template_id, '
      'submitted_at, approved_at, rejected_reason, meta_category, '
      'meta_language, created_at, updated_at';
  static const _selectSummary = 'id, name, is_default, approval_status';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const TemplatesUnknownFailure('Usuário não autenticado.');
    }
    return id;
  }

  @override
  Future<List<Template>> listTemplates() async {
    try {
      final rows = await _client
          .from('templates')
          .select(_selectFull)
          .eq('user_id', _userId)
          .order('is_default', ascending: false)
          .order('name');

      return rows
          .map((row) => _mapTemplate(Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('listTemplates failed', error: error, stackTrace: stackTrace);
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'listTemplates unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<List<TemplateSummary>> listSummaries() async {
    try {
      final rows = await _client
          .from('templates')
          .select(_selectSummary)
          .eq('user_id', _userId)
          .order('is_default', ascending: false)
          .order('name');

      return rows
          .map(
            (row) => TemplateSummary.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('listSummaries failed', error: error, stackTrace: stackTrace);
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'listSummaries unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<Template> getById(String id) async {
    try {
      final row = await _client
          .from('templates')
          .select(_selectFull)
          .eq('id', id)
          .eq('user_id', _userId)
          .maybeSingle();

      if (row == null) {
        throw const TemplatesNotFoundFailure();
      }

      return _mapTemplate(Map<String, dynamic>.from(row));
    } on TemplatesFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('getById failed', error: error, stackTrace: stackTrace);
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e('getById unexpected', error: error, stackTrace: stackTrace);
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<TemplateSummary> getDefaultTemplate() async {
    try {
      final row = await _client
          .from('templates')
          .select(_selectSummary)
          .eq('user_id', _userId)
          .eq('is_default', true)
          .maybeSingle();

      if (row == null) {
        throw const TemplatesDefaultMissingFailure();
      }

      return TemplateSummary.fromJson(Map<String, dynamic>.from(row));
    } on TemplatesFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e(
        'getDefaultTemplate failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'getDefaultTemplate unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<TemplateSummary> ensureDefaultTemplate() async {
    try {
      return await getDefaultTemplate();
    } on TemplatesDefaultMissingFailure {
      try {
        final data = await _client
            .from('templates')
            .insert({
              'user_id': _userId,
              'name': defaultTemplateName,
              'message': defaultTemplateMessage,
              'variables': defaultTemplateVariables,
              'is_default': true,
            })
            .select(_selectSummary)
            .single();

        return TemplateSummary.fromJson(Map<String, dynamic>.from(data));
      } on PostgrestException catch (error, stackTrace) {
        AppLogger.e(
          'ensureDefaultTemplate insert failed',
          error: error,
          stackTrace: stackTrace,
        );
        throw TemplatesUnknownFailure(error.message);
      }
    }
  }

  @override
  Future<Template> createTemplate({
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    try {
      final data = await _client
          .from('templates')
          .insert({
            'user_id': _userId,
            'name': name.trim(),
            'message': message,
            'variables': variables,
            'is_default': false,
          })
          .select(_selectFull)
          .single();

      return _mapTemplate(Map<String, dynamic>.from(data));
    } on TemplatesFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('createTemplate failed', error: error, stackTrace: stackTrace);
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'createTemplate unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<Template> updateTemplate({
    required String id,
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    try {
      // Content change resets Meta approval via protect_template_meta_columns.
      final data = await _client
          .from('templates')
          .update({
            'name': name.trim(),
            'message': message,
            'variables': variables,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId)
          .select(_selectFull)
          .maybeSingle();

      if (data == null) {
        throw const TemplatesNotFoundFailure();
      }

      return _mapTemplate(Map<String, dynamic>.from(data));
    } on TemplatesFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('updateTemplate failed', error: error, stackTrace: stackTrace);
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'updateTemplate unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<Template> submitForApproval(String id) async {
    try {
      final response = await _client.functions.invoke(
        'whatsapp-submit-template',
        body: {'template_id': id},
      );
      final data = response.data;
      if (data is Map && data['error'] is String) {
        throw TemplatesSubmitFailure(data['error'] as String);
      }
      return getById(id);
    } on TemplatesFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'submitForApproval failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw TemplatesSubmitFailure(details['error'] as String);
      }
      throw const TemplatesSubmitFailure();
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'submitForApproval unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<Template> syncApprovalStatus(String id) async {
    try {
      final response = await _client.functions.invoke(
        'whatsapp-sync-templates',
        body: {'template_id': id},
      );
      final data = response.data;
      if (data is Map && data['error'] is String) {
        throw TemplatesUnknownFailure(data['error'] as String);
      }
      return getById(id);
    } on TemplatesFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'syncApprovalStatus failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw TemplatesUnknownFailure(details['error'] as String);
      }
      throw const TemplatesNetworkFailure();
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'syncApprovalStatus unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    try {
      final row = await _client
          .from('templates')
          .select('id, is_default')
          .eq('id', id)
          .eq('user_id', _userId)
          .maybeSingle();

      if (row == null) {
        throw const TemplatesNotFoundFailure();
      }

      if (row['is_default'] == true) {
        throw const TemplatesCannotDeleteDefaultFailure();
      }

      final inUse = await _client
          .from('clients')
          .select('id')
          .eq('user_id', _userId)
          .eq('template_id', id)
          .limit(1)
          .maybeSingle();

      if (inUse != null) {
        throw const TemplatesInUseFailure();
      }

      await _client
          .from('templates')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } on TemplatesFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e('deleteTemplate failed', error: error, stackTrace: stackTrace);
      if (error.code == '23503') {
        throw const TemplatesInUseFailure();
      }
      throw TemplatesUnknownFailure(error.message);
    } catch (error, stackTrace) {
      if (error is TemplatesFailure) rethrow;
      AppLogger.e(
        'deleteTemplate unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const TemplatesNetworkFailure();
    }
  }

  Template _mapTemplate(Map<String, dynamic> row) {
    final rawVariables = row['variables'];
    final variables = <String>[];
    if (rawVariables is List) {
      for (final item in rawVariables) {
        if (item is String) variables.add(item);
      }
    }

    final flat = Map<String, dynamic>.from(row)..['variables'] = variables;
    return Template.fromJson(flat);
  }
}
