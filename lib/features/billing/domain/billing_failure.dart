/// Failures from Stripe checkout / portal flows.
sealed class BillingFailure implements Exception {
  const BillingFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class BillingNotReadyFailure extends BillingFailure {
  const BillingNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

class BillingRemoteFailure extends BillingFailure {
  const BillingRemoteFailure([
    super.message = 'Não foi possível iniciar o pagamento. Tente novamente.',
  ]);
}
