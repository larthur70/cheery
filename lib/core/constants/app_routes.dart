/// Central route path constants.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String confirmEmail = '/confirm-email';
  static const String authCallback = '/auth/callback';
  static const String resetPassword = '/auth/reset-password';
  static const String confirmDelete = '/auth/confirm-delete';
  static const String onboarding = '/onboarding';

  static const String home = '/home';
  static const String clients = '/clients';
  static const String clientsImport = '/clients/import';
  static const String clientsImportContacts = '/clients/import-contacts';
  static const String calendar = '/calendar';
  static const String templates = '/templates';
  static const String templatesNew = '/templates/new';
  static String templateEdit(String id) => '/templates/$id/edit';
  static const String billing = '/billing';
  static const String profile = '/profile';
  /// Profile screen focused on the subscription / plans block.
  static const String profilePlans = '/profile?section=plans';
  /// Profile plans with checkout attribution for PostHog.
  static String profilePlansFrom(String origemGatilho) =>
      '/profile?section=plans&origem=$origemGatilho';
  static const String reminderSettings = '/settings/reminders';
  static const String whatsappOnboarding = '/whatsapp/onboarding';
  static const String whatsappManage = '/whatsapp/manage';
  static const String whatsappCallback = '/whatsapp/callback';
  static const String privacy = '/privacidade';
  static const String terms = '/termos';

  static const Set<String> authRoutes = {
    login,
    signUp,
    forgotPassword,
    confirmEmail,
    authCallback,
    resetPassword,
    confirmDelete,
  };

  static bool isAuthRoute(String location) {
    return authRoutes.any(
      (route) => location == route || location.startsWith('$route?'),
    );
  }

  static bool isProtectedRoute(String location) {
    return location.startsWith(home) ||
        location.startsWith(clients) ||
        location.startsWith(calendar) ||
        location.startsWith(templates) ||
        location.startsWith(billing) ||
        location.startsWith(profile) ||
        location.startsWith(onboarding) ||
        location.startsWith(reminderSettings) ||
        location.startsWith('/whatsapp') ||
        location.startsWith('/settings');
  }

  static String confirmEmailWithEmail(String email) {
    return '$confirmEmail?email=${Uri.encodeComponent(email)}';
  }
}
