abstract class BillingRepository {
  /// Returns a Stripe Checkout URL for upgrading to Pro.
  Future<Uri> createCheckoutSession();

  /// Returns a Stripe Customer Portal URL for managing the subscription.
  Future<Uri> createPortalSession();
}
