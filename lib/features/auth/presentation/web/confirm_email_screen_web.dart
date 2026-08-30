import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/resend_confirmation_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_web_brand_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConfirmEmailScreenWeb extends ConsumerStatefulWidget {
  const ConfirmEmailScreenWeb({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ConfirmEmailScreenWeb> createState() =>
      _ConfirmEmailScreenWebState();
}

class _ConfirmEmailScreenWebState extends ConsumerState<ConfirmEmailScreenWeb> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfConfirmed());
  }

  Future<void> _redirectIfConfirmed() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    await ref
        .read(authControllerProvider.notifier)
        .ensureProfileAfterConfirmation();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _resend() async {
    final cooldown = ref.read(resendConfirmationControllerProvider);
    if (!cooldown.canResend) return;

    final notifier = ref.read(resendConfirmationControllerProvider.notifier);
    notifier.setResending(true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendSignupConfirmationEmail(email: widget.email);
      if (!mounted) return;
      notifier.setSuccess(
        'Enviamos um novo e-mail de confirmação para ${widget.email}.',
      );
      notifier.startCooldown();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      notifier.setError(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cooldown = ref.watch(resendConfirmationControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.valueOrNull != null) {
        _redirectIfConfirmed();
      }
    });

    final resendLabel = cooldown.remainingSeconds > 0
        ? 'Reenviar em ${cooldown.remainingSeconds}s'
        : 'Reenviar e-mail';

    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: AuthWebBrandPanel(
              headline:
                  'Quase lá! Confirme seu e-mail para liberar o dashboard Cheery.',
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 56,
                        color: AppColors.cherry,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Confirme seu e-mail',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enviamos um link de confirmação para',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.cherry,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Abra o e-mail (e a pasta de spam) e clique no link. '
                        'Depois disso, você será redirecionado automaticamente para o início.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (cooldown.feedbackMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          cooldown.feedbackMessage!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cooldown.feedbackIsError
                                    ? AppColors.danger
                                    : AppColors.success,
                              ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      CheeryButton(
                        label: resendLabel,
                        expanded: true,
                        isLoading: cooldown.isResending,
                        onPressed: cooldown.canResend ? _resend : null,
                      ),
                      const SizedBox(height: 12),
                      CheeryButton(
                        label: 'Voltar ao login',
                        variant: CheeryButtonVariant.text,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
