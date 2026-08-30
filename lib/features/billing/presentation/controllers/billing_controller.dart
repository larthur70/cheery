import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/features/billing/domain/billing_failure.dart';
import 'package:cheery/features/billing/presentation/controllers/billing_repository_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final billingControllerProvider =
    AsyncNotifierProvider<BillingController, void>(BillingController.new);

class BillingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startCheckout({
    AssinaturaOrigemGatilho origemGatilho =
        AssinaturaOrigemGatilho.menuConfiguracoes,
  }) async {
    if (StoreCompliance.hideExternalPayments) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(billingRepositoryProvider);
      if (repository == null) {
        throw const BillingNotReadyFailure();
      }
      ref.read(analyticsServiceProvider).trackAssinaturaProIniciada(
            origemGatilho: origemGatilho,
          );
      final url = await repository.createCheckoutSession();
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const BillingRemoteFailure(
          'Não foi possível abrir o checkout do Stripe.',
        );
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> openPortal() async {
    if (StoreCompliance.hideExternalPayments) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(billingRepositoryProvider);
      if (repository == null) {
        throw const BillingNotReadyFailure();
      }
      final url = await repository.createPortalSession();
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const BillingRemoteFailure(
          'Não foi possível abrir o portal de assinatura.',
        );
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
