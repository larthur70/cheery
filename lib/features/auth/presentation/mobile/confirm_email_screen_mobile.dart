import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/resend_confirmation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConfirmEmailScreenMobile extends ConsumerStatefulWidget {
  const ConfirmEmailScreenMobile({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ConfirmEmailScreenMobile> createState() =>
      _ConfirmEmailScreenMobileState();
}

class _ConfirmEmailScreenMobileState
    extends ConsumerState<ConfirmEmailScreenMobile> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmar e-mail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Enviamos um link de confirmação para ${widget.email}. '
                'Confira também a pasta de spam. Após confirmar, você será '
                'redirecionado automaticamente.',
                style: Theme.of(context).textTheme.bodyLarge,
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
              const Spacer(),
              CheeryButton(
                label: resendLabel,
                expanded: true,
                isLoading: cooldown.isResending,
                onPressed: cooldown.canResend ? _resend : null,
              ),
              const SizedBox(height: 12),
              CheeryButton(
                label: 'Voltar ao login',
                variant: CheeryButtonVariant.outlined,
                expanded: true,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
