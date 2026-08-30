import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:cheery/features/billing/domain/billing_failure.dart';
import 'package:cheery/features/billing/presentation/controllers/billing_controller.dart';
import 'package:cheery/features/billing/presentation/controllers/profile_form_controller.dart';
import 'package:cheery/features/billing/presentation/widgets/profile_subscription_section.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile + subscription screen (replaces billing placeholder).
class ProfileEntryScreen extends ConsumerStatefulWidget {
  const ProfileEntryScreen({super.key});

  @override
  ConsumerState<ProfileEntryScreen> createState() => _ProfileEntryScreenState();
}

class _ProfileEntryScreenState extends ConsumerState<ProfileEntryScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _plansSectionKey = GlobalKey();

  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;

  bool _hydrated = false;
  String? _checkoutQueryHandled;
  bool _didScrollToPlans = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _companyController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _hydrateFields(Profile profile, String email) {
    if (_hydrated) return;
    _nameController.text = profile.fullName ?? '';
    _companyController.text = profile.companyName ?? '';
    _emailController.text = email;
    _hydrated = true;
  }

  Future<void> _handleCheckoutQuery(BuildContext context) async {
    final uri = GoRouterState.of(context).uri;
    final checkout = uri.queryParameters['checkout'];
    if (checkout == null || checkout == _checkoutQueryHandled) return;
    _checkoutQueryHandled = checkout;

    if (checkout == 'success') {
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pagamento concluído! Seu plano será atualizado em instantes.',
          ),
        ),
      );
    } else if (checkout == 'cancel') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout cancelado.')),
      );
    }
  }

  AssinaturaOrigemGatilho _origemGatilho(BuildContext context) {
    return AssinaturaOrigemGatilho.tryParse(
          GoRouterState.of(context).uri.queryParameters['origem'],
        ) ??
        AssinaturaOrigemGatilho.menuConfiguracoes;
  }

  void _maybeScrollToPlans() {
    if (_didScrollToPlans || !mounted) return;
    final section =
        GoRouterState.of(context).uri.queryParameters['section'];
    if (section != 'plans') return;
    final target = _plansSectionKey.currentContext;
    if (target == null) return;
    _didScrollToPlans = true;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  Future<void> _runBilling(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on BillingFailure catch (failure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o Stripe. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text(
          'Tem certeza que deseja sair? Você precisará fazer login novamente '
          'para acessar o app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(authControllerProvider.notifier).signOut();
    ref.read(loginFormControllerProvider.notifier).clearError();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final formState = ref.watch(profileFormControllerProvider);
    final billingAsync = ref.watch(billingControllerProvider);
    final clientCount =
        ref.watch(clientsControllerProvider).valueOrNull?.length ??
            ref.read(clientsControllerProvider.notifier).clientCount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCheckoutQuery(context);
      _maybeScrollToPlans();
    });

    return profileAsync.when(
      loading: () => const ColoredBox(
        color: AppColors.background,
        child: CheeryLoading(message: 'Carregando perfil...'),
      ),
      error: (error, _) => ColoredBox(
        color: AppColors.background,
        child: Center(
          child: CheeryButton(
            label: 'Tentar novamente',
            onPressed: () => ref.invalidate(currentProfileProvider),
          ),
        ),
      ),
      data: (profile) {
        if (profile == null || user == null) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: Text('Faça login para ver o perfil.')),
          );
        }

        _hydrateFields(profile, user.email);
        final isPro = profile.isPro;
        final isBillingLoading = billingAsync.isLoading;

        return ResponsiveBuilder(
          mobile: (_) => _ProfileScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            showBack: true,
            isMobile: true,
            plansSectionKey: _plansSectionKey,
            accountFormKey: _accountFormKey,
            nameController: _nameController,
            companyController: _companyController,
            emailController: _emailController,
            canChangeEmail: user.canChangeEmail,
            canSetPassword: user.canSetPassword,
            oauthLabel: user.linkedOAuthLabel,
            formState: formState,
            isPro: isPro,
            clientCount: clientCount,
            currentPeriodEnd: profile.currentPeriodEnd,
            isBillingLoading: isBillingLoading,
            onSaveAccount: () {
              if (_accountFormKey.currentState?.validate() != true) return;
              ref.read(profileFormControllerProvider.notifier).saveAccount(
                    fullName: _nameController.text,
                    companyName: _companyController.text,
                    email: _emailController.text,
                  );
            },
            onSendPasswordReset: () => ref
                .read(profileFormControllerProvider.notifier)
                .sendPasswordResetEmail(),
            onUpgrade: () => _runBilling(
              context,
              () => ref.read(billingControllerProvider.notifier).startCheckout(
                    origemGatilho: _origemGatilho(context),
                  ),
            ),
            onManage: () => _runBilling(
              context,
              () => ref.read(billingControllerProvider.notifier).openPortal(),
            ),
            onLogout: () => _confirmLogout(context),
            onDeleteAccount: () => _confirmDeleteAccount(context),
            onOpenPrivacy: () => context.push(AppRoutes.privacy),
            onOpenTerms: () => context.push(AppRoutes.terms),
          ),
          desktop: (_) => _ProfileScrollBody(
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 48),
            showBack: true,
            isMobile: false,
            maxWidth: 960,
            plansSectionKey: _plansSectionKey,
            accountFormKey: _accountFormKey,
            nameController: _nameController,
            companyController: _companyController,
            emailController: _emailController,
            canChangeEmail: user.canChangeEmail,
            canSetPassword: user.canSetPassword,
            oauthLabel: user.linkedOAuthLabel,
            formState: formState,
            isPro: isPro,
            clientCount: clientCount,
            currentPeriodEnd: profile.currentPeriodEnd,
            isBillingLoading: isBillingLoading,
            onSaveAccount: () {
              if (_accountFormKey.currentState?.validate() != true) return;
              ref.read(profileFormControllerProvider.notifier).saveAccount(
                    fullName: _nameController.text,
                    companyName: _companyController.text,
                    email: _emailController.text,
                  );
            },
            onSendPasswordReset: () => ref
                .read(profileFormControllerProvider.notifier)
                .sendPasswordResetEmail(),
            onUpgrade: () => _runBilling(
              context,
              () => ref.read(billingControllerProvider.notifier).startCheckout(
                    origemGatilho: _origemGatilho(context),
                  ),
            ),
            onManage: () => _runBilling(
              context,
              () => ref.read(billingControllerProvider.notifier).openPortal(),
            ),
            onLogout: () => _confirmLogout(context),
            onDeleteAccount: () => _confirmDeleteAccount(context),
            onOpenPrivacy: () => context.push(AppRoutes.privacy),
            onOpenTerms: () => context.push(AppRoutes.terms),
          ),
        );
      },
    );
  }
}

class _ProfileScrollBody extends StatelessWidget {
  const _ProfileScrollBody({
    required this.padding,
    required this.showBack,
    required this.isMobile,
    required this.plansSectionKey,
    required this.accountFormKey,
    required this.nameController,
    required this.companyController,
    required this.emailController,
    required this.canChangeEmail,
    required this.canSetPassword,
    this.oauthLabel,
    required this.formState,
    required this.isPro,
    required this.clientCount,
    required this.isBillingLoading,
    required this.onSaveAccount,
    required this.onSendPasswordReset,
    required this.onUpgrade,
    required this.onManage,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onOpenPrivacy,
    required this.onOpenTerms,
    this.currentPeriodEnd,
    this.maxWidth,
  });

  final EdgeInsets padding;
  final bool showBack;
  final bool isMobile;
  final GlobalKey plansSectionKey;
  final double? maxWidth;
  final GlobalKey<FormState> accountFormKey;
  final TextEditingController nameController;
  final TextEditingController companyController;
  final TextEditingController emailController;
  final bool canChangeEmail;
  final bool canSetPassword;
  final String? oauthLabel;
  final ProfileFormState formState;
  final bool isPro;
  final int clientCount;
  final DateTime? currentPeriodEnd;
  final bool isBillingLoading;
  final VoidCallback onSaveAccount;
  final VoidCallback onSendPasswordReset;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: showBack
            ? AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.cherry),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  tooltip: 'Voltar',
                ),
                title: Text(
                  'Meu perfil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            : null,
        body: SingleChildScrollView(
          padding: padding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth ?? 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da Assinatura',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.cherry,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ProfilePlanSummaryCard(
                    isPro: isPro,
                    currentPeriodEnd: currentPeriodEnd,
                  ),
                  if (!isPro) ...[
                    const SizedBox(height: 16),
                    ProfileClientsUsageBar(clientCount: clientCount),
                  ],
                  const SizedBox(height: 28),
                  KeyedSubtree(
                    key: plansSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StoreCompliance.hideExternalPayments
                              ? 'Plano atual'
                              : 'Planos disponíveis',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 14),
                        ProfilePlanCards(
                          isPro: isPro,
                          isBillingLoading: isBillingLoading,
                          onUpgrade: onUpgrade,
                          onManage: onManage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Dados da conta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.cherry,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canChangeEmail
                        ? 'Atualize seu nome, empresa e e-mail.'
                        : 'Atualize seu nome e empresa. O e-mail vem da conta '
                            '${oauthLabel ?? 'Google ou Apple'} e não pode ser '
                            'alterado aqui.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Form(
                      key: accountFormKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            label: 'Nome',
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe seu nome';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            label: 'Nome da empresa',
                            controller: companyController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o nome da empresa';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            label: 'E-mail',
                            controller: emailController,
                            enabled: canChangeEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (!canChangeEmail) return null;
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o e-mail';
                              }
                              if (!value.contains('@')) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          if (canChangeEmail) ...[
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Para trocar o e-mail, você precisa confirmar o '
                                'link no endereço novo e também no atual. '
                                'Enquanto isso, a conta continua com o e-mail de agora.',
                                style: TextStyle(
                                  color: AppColors.inkMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (!canChangeEmail) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Para mudar o e-mail, altere-o na conta '
                                '${oauthLabel ?? 'Google ou Apple'} e entre de novo.',
                                style: const TextStyle(
                                  color: AppColors.inkMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (formState.accountError != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formState.accountError!,
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                          if (formState.accountMessage != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formState.accountMessage!,
                                style: const TextStyle(color: AppColors.success),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CheeryButton(
                              label: 'Salvar dados',
                              isLoading: formState.isSavingAccount,
                              onPressed: onSaveAccount,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (canSetPassword) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alterar senha',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Por segurança, enviamos um link para o seu e-mail. '
                          'Nele você define a nova senha.',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                        if (formState.passwordError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            formState.passwordError!,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ],
                        if (formState.passwordMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            formState.passwordMessage!,
                            style: const TextStyle(color: AppColors.success),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CheeryButton(
                            label: formState.passwordResetRemainingSeconds > 0
                                ? 'Enviar em ${formState.passwordResetRemainingSeconds}s'
                                : 'Alterar senha',
                            isLoading: formState.isSendingPasswordReset,
                            onPressed: formState.canSendPasswordReset
                                ? onSendPasswordReset
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Leia os termos de uso e como tratamos os dados da '
                          'sua conta e dos contatos importados.',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheeryButton(
                                label: 'Termos de uso',
                                variant: CheeryButtonVariant.outlined,
                                icon: Icons.description_outlined,
                                onPressed: onOpenTerms,
                              ),
                              const SizedBox(height: 12),
                              CheeryButton(
                                label: 'Política de privacidade',
                                variant: CheeryButtonVariant.outlined,
                                icon: Icons.policy_outlined,
                                onPressed: onOpenPrivacy,
                              ),
                            ],
                          )
                        else
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              CheeryButton(
                                label: 'Termos de uso',
                                variant: CheeryButtonVariant.outlined,
                                icon: Icons.description_outlined,
                                onPressed: onOpenTerms,
                              ),
                              CheeryButton(
                                label: 'Política de privacidade',
                                variant: CheeryButtonVariant.outlined,
                                icon: Icons.policy_outlined,
                                onPressed: onOpenPrivacy,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessão',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Encerre sua sessão neste dispositivo.',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CheeryButton(
                            label: 'Sair da conta',
                            variant: CheeryButtonVariant.outlined,
                            icon: Icons.logout,
                            onPressed: onLogout,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zona de perigo',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Excluir sua conta remove permanentemente clientes, '
                          'templates e dados da assinatura. Enviaremos um e-mail '
                          'para você confirmar antes de apagar tudo.',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CheeryButton(
                            label: 'Excluir conta',
                            icon: Icons.delete_forever_outlined,
                            onPressed: onDeleteAccount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _isSending = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendConfirmationEmail() async {
    if (_isSending || _emailSent) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).requestAccountDeletion();
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _emailSent = true;
      });
    } on AuthDeleteAccountEmailSentFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = failure.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = const AuthDeleteAccountEmailSentFailure().message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir conta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _emailSent
                ? 'Enviamos um e-mail de confirmação. Abra o link para excluir '
                    'a conta de forma permanente.'
                : 'Vamos enviar um e-mail de confirmação para você. Só depois '
                    'de abrir o link a conta e todos os dados serão apagados '
                    'de forma permanente.',
            style: TextStyle(
              color: _emailSent ? AppColors.success : null,
              height: 1.4,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.danger, height: 1.4),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: Text(_emailSent ? 'Fechar' : 'Cancelar'),
        ),
        if (!_emailSent)
          FilledButton(
            onPressed: _isSending ? null : _sendConfirmationEmail,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: _isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enviar e-mail de confirmação'),
          ),
      ],
    );
  }
}
