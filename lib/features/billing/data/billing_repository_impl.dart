import 'package:cheery/core/config/app_deep_links.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/billing/domain/billing_failure.dart';
import 'package:cheery/features/billing/domain/billing_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Uri> createCheckoutSession() =>
      _invokeUrl('create-checkout-session');

  @override
  Future<Uri> createPortalSession() => _invokeUrl('create-portal-session');

  Future<Uri> _invokeUrl(String functionName) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: AppDeepLinks.nativeReturnBody(),
      );
      final data = response.data;
      if (data is! Map) {
        throw const BillingRemoteFailure();
      }
      final map = Map<String, dynamic>.from(data);
      final error = map['error'] as String?;
      if (error != null && error.isNotEmpty) {
        throw BillingRemoteFailure(error);
      }
      final url = map['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const BillingRemoteFailure();
      }
      return Uri.parse(url);
    } on BillingFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'Billing function $functionName failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw BillingRemoteFailure(details['error'] as String);
      }
      throw BillingRemoteFailure(
        error.reasonPhrase ?? 'Não foi possível iniciar o pagamento.',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Billing function $functionName unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      if (error is BillingFailure) rethrow;
      throw const BillingRemoteFailure();
    }
  }
}
