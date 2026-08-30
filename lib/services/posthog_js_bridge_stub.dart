/// Non-web stub — PostHog goes through [posthog_flutter] native SDKs.
abstract final class PosthogJsBridge {
  static bool get isAvailable => false;

  static void identify(String userId) {}

  static void reset() {}

  static void capture(
    String eventName,
    Map<String, Object> properties,
  ) {}
}
