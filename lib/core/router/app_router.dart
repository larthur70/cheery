import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/router/cheery_page_transitions.dart';
import 'package:cheery/core/widgets/adaptive_shell.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/password_recovery_pending_provider.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_callback_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_entry_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/confirm_account_deletion_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/confirm_email_entry_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/forgot_password_entry_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/reset_password_entry_screen.dart';
import 'package:cheery/features/auth/presentation/widgets/sign_up_entry_screen.dart';
import 'package:cheery/features/billing/presentation/widgets/profile_entry_screen.dart';
import 'package:cheery/features/birthday_reminders/presentation/widgets/reminder_settings_entry_screen.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_entry_screen.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_entry_screen.dart';
import 'package:cheery/features/home/presentation/widgets/home_entry_screen.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_clients_entry_screen.dart';
import 'package:cheery/features/import_contacts/presentation/widgets/import_contacts_entry_screen.dart';
import 'package:cheery/features/legal/presentation/privacy_policy_screen.dart';
import 'package:cheery/features/legal/presentation/terms_of_use_screen.dart';
import 'package:cheery/features/templates/presentation/widgets/template_form_entry_screen.dart';
import 'package:cheery/features/templates/presentation/widgets/templates_entry_screen.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_callback_screen.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_onboarding_flow.dart';
import 'package:cheery/features/whatsapp_automation/presentation/web/whatsapp_manage_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Notifies [GoRouter] when auth changes without recreating the router instance.
class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.onDispose(refresh.dispose);

  ref.listen(authControllerProvider, (_, _) => refresh.ping());
  ref.listen(passwordRecoveryPendingProvider, (_, _) => refresh.ping());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      // Session restore is async — don't send protected deep links to /login.
      if (auth.isLoading) return null;

      final authUserId = auth.valueOrNull?.id;
      final passwordRecoveryPending = ref.read(passwordRecoveryPendingProvider);
      final location = state.matchedLocation;
      final isLoggedIn = authUserId != null;
      final loggingIn = AppRoutes.isAuthRoute(location);
      final isConfirmEmail = location == AppRoutes.confirmEmail;
      final isAuthCallback = location == AppRoutes.authCallback;
      final isResetPassword = location == AppRoutes.resetPassword;
      final isConfirmDelete = location == AppRoutes.confirmDelete;

      // Path URL strategy serves `/` — send users to login.
      if (location == '/' || location.isEmpty) {
        return passwordRecoveryPending
            ? AppRoutes.resetPassword
            : AppRoutes.login;
      }

      // Recovery link opens a session — keep the user on reset-password.
      if (passwordRecoveryPending) {
        return isResetPassword ? null : AppRoutes.resetPassword;
      }

      // OAuth return URL — screen recovers the session itself.
      // Confirm-delete uses a token (no session required).
      if (isAuthCallback || isResetPassword || isConfirmDelete) return null;

      if (!isLoggedIn && AppRoutes.isProtectedRoute(location)) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isConfirmEmail) {
        return AppRoutes.home;
      }

      if (isLoggedIn && loggingIn && !isConfirmEmail) {
        return AppRoutes.home;
      }

      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Rota não encontrada: ${state.uri}'),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Entrar',
          child: const AuthEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'sign-up',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Criar conta',
          child: const SignUpEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Esqueceu a senha',
          child: const ForgotPasswordEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.confirmEmail,
        name: 'confirm-email',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return cheeryLoadingPage(
            key: state.pageKey,
            name: state.name,
            documentTitle: 'Confirmar e-mail',
            child: ConfirmEmailEntryScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        name: 'auth-callback',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Autenticando',
          child: const AuthCallbackScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Redefinir senha',
          child: const ResetPasswordEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.confirmDelete,
        name: 'confirm-delete',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return cheeryLoadingPage(
            key: state.pageKey,
            name: state.name,
            documentTitle: 'Excluir conta',
            child: ConfirmAccountDeletionScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Política de privacidade',
          child: const PrivacyPolicyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Termos de uso',
          child: const TermsOfUseScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        // Product tour is an overlay on the shell after first signup.
        redirect: (context, state) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.billing,
        name: 'billing',
        redirect: (context, state) => AppRoutes.profile,
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Meu perfil',
          child: const ProfileEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reminderSettings,
        name: 'reminder-settings',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'Lembretes',
          child: const ReminderSettingsEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.whatsappOnboarding,
        name: 'whatsapp-onboarding',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'WhatsApp',
          child: const WhatsAppOnboardingEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.whatsappManage,
        name: 'whatsapp-manage',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'WhatsApp',
          child: const WhatsAppManageEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.whatsappCallback,
        name: 'whatsapp-callback',
        pageBuilder: (context, state) => cheeryLoadingPage(
          key: state.pageKey,
          name: state.name,
          documentTitle: 'WhatsApp',
          child: const WhatsAppCallbackScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) {
          return cheeryLoadingPage(
            key: state.pageKey,
            name: state.name,
            child: AdaptiveShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => cheeryLoadingPage(
                  key: state.pageKey,
                  name: state.name,
                  documentTitle: 'Home',
                  child: const HomeEntryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clients,
                name: 'clients',
                pageBuilder: (context, state) => cheeryLoadingPage(
                  key: state.pageKey,
                  name: state.name,
                  documentTitle: 'Clientes',
                  child: const ClientsEntryScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'import',
                    name: 'clients-import',
                    pageBuilder: (context, state) => cheeryLoadingPage(
                      key: state.pageKey,
                      name: state.name,
                      documentTitle: 'Importar clientes',
                      child: const ImportClientsEntryScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'import-contacts',
                    name: 'clients-import-contacts',
                    pageBuilder: (context, state) => cheeryLoadingPage(
                      key: state.pageKey,
                      name: state.name,
                      documentTitle: 'Importar contatos',
                      child: const ImportContactsEntryScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                name: 'calendar',
                pageBuilder: (context, state) => cheeryLoadingPage(
                  key: state.pageKey,
                  name: state.name,
                  documentTitle: 'Calendário',
                  child: const CalendarEntryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.templates,
                name: 'templates',
                pageBuilder: (context, state) => cheeryLoadingPage(
                  key: state.pageKey,
                  name: state.name,
                  documentTitle: 'Templates',
                  child: const TemplatesEntryScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'templates-new',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => cheeryLoadingPage(
                      key: state.pageKey,
                      name: state.name,
                      documentTitle: 'Novo template',
                      child: const TemplateFormEntryScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    name: 'templates-edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return cheeryLoadingPage(
                        key: state.pageKey,
                        name: state.name,
                        documentTitle: 'Editar template',
                        child: TemplateFormEntryScreen(templateId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
