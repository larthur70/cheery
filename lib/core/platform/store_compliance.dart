import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:flutter/foundation.dart';

/// App Store 3.1.1: iOS must not steer users to Stripe / external checkout.
abstract final class StoreCompliance {
  static bool get hideExternalPayments =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static const limitReached = 'Limite atingido';

  static String clientLimitMessage() => hideExternalPayments
      ? limitReached
      : 'Limite de ${PlanLimits.freeMaxClients} clientes do plano Free '
          'atingido. Faça upgrade para o Pro.';

  static String templateLimitMessage() => hideExternalPayments
      ? limitReached
      : 'No plano Free só é possível editar o template padrão. '
          'Faça upgrade para o Pro.';
}
