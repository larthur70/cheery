import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection_repository.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_failure.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WhatsAppConnectionRepositoryImpl
    implements WhatsAppConnectionRepository {
  WhatsAppConnectionRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _profileSelect =
      'whatsapp_connected, whatsapp_integration_status, '
      'whatsapp_display_phone, whatsapp_connected_at, whatsapp_last_error';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const WhatsAppRemoteFailure('Usuário não autenticado.');
    }
    return id;
  }

  @override
  Future<Uri> startConnect() async {
    final map = await _invoke('whatsapp-connect-session');
    final url = map['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const WhatsAppOAuthFailure(
        'Não foi possível iniciar a conexão com o WhatsApp.',
      );
    }
    return Uri.parse(url);
  }

  @override
  Future<WhatsAppConnection> completeConnect({
    String? code,
    String? phoneNumberId,
    String? wabaId,
    String? displayPhone,
  }) async {
    await _invoke(
      'whatsapp-oauth-callback',
      body: {
        if (code != null) 'code': code,
        if (phoneNumberId != null) 'phone_number_id': phoneNumberId,
        if (wabaId != null) 'waba_id': wabaId,
        if (displayPhone != null) 'display_phone': displayPhone,
      },
    );
    return refreshStatus();
  }

  @override
  Future<WhatsAppConnection> disconnect() async {
    await _invoke('whatsapp-disconnect');
    return refreshStatus();
  }

  @override
  Future<WhatsAppConnection> refreshStatus() async {
    try {
      final row = await _client
          .from('profiles_app')
          .select(_profileSelect)
          .eq('id', _userId)
          .maybeSingle();

      if (row == null) {
        return WhatsAppConnection.disconnected;
      }

      return WhatsAppConnection(
        connected: row['whatsapp_connected'] as bool? ?? false,
        status: WhatsAppIntegrationStatus.fromJson(
          row['whatsapp_integration_status'] as String?,
        ),
        displayPhone: row['whatsapp_display_phone'] as String?,
        connectedAt: row['whatsapp_connected_at'] != null
            ? DateTime.tryParse(row['whatsapp_connected_at'] as String)
            : null,
        lastError: row['whatsapp_last_error'] as String?,
      );
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e(
        'refreshStatus failed',
        error: error,
        stackTrace: stackTrace,
      );
      // Fallback to base table without token column if view missing.
      return _refreshFromProfilesTable();
    } catch (error, stackTrace) {
      if (error is WhatsAppFailure) rethrow;
      AppLogger.e(
        'refreshStatus unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const WhatsAppNetworkFailure();
    }
  }

  Future<WhatsAppConnection> _refreshFromProfilesTable() async {
    final row = await _client
        .from('profiles')
        .select(_profileSelect)
        .eq('id', _userId)
        .maybeSingle();

    if (row == null) return WhatsAppConnection.disconnected;

    return WhatsAppConnection(
      connected: row['whatsapp_connected'] as bool? ?? false,
      status: WhatsAppIntegrationStatus.fromJson(
        row['whatsapp_integration_status'] as String?,
      ),
      displayPhone: row['whatsapp_display_phone'] as String?,
      connectedAt: row['whatsapp_connected_at'] != null
          ? DateTime.tryParse(row['whatsapp_connected_at'] as String)
          : null,
      lastError: row['whatsapp_last_error'] as String?,
    );
  }

  Future<Map<String, dynamic>> _invoke(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );
      final data = response.data;
      if (data is! Map) {
        throw const WhatsAppRemoteFailure();
      }
      final map = Map<String, dynamic>.from(data);
      final error = map['error'] as String?;
      if (error != null && error.isNotEmpty) {
        throw WhatsAppRemoteFailure(error);
      }
      return map;
    } on WhatsAppFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'WhatsApp function $functionName failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw WhatsAppRemoteFailure(details['error'] as String);
      }
      throw WhatsAppRemoteFailure(
        error.reasonPhrase ?? 'Não foi possível concluir a operação.',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'WhatsApp function $functionName unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      if (error is WhatsAppFailure) rethrow;
      throw const WhatsAppNetworkFailure();
    }
  }
}
