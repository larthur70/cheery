import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/reset_password_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_web_brand_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreenWeb extends ConsumerStatefulWidget {
  const ResetPasswordScreenWeb({super.key});

  @override
  ConsumerState<ResetPasswordScreenWeb> createState() =>
      _ResetPasswordScreenWebState();
}

class _ResetPasswordScreenWebState
    extends ConsumerState<ResetPasswordScreenWeb> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverSession());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _recoverSession() async {
    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .recoverSessionFromCurrentUrl();
      final current = user ?? ref.read(authControllerProvider).valueOrNull;
      ref.read(resetPasswordFormControllerProvider.notifier).setRecovering(
            recovering: false,
            hasSession: current != null,
          );
      if (current == null) {
        ref.read(resetPasswordFormControllerProvider.notifier).setError(
              'Link inválido ou expirado. Solicite um novo e-mail de redefinição.',
            );
      }
    } on AuthFailure catch (failure) {
      ref
          .read(resetPasswordFormControllerProvider.notifier)
          .setError(failure.message);
    } catch (_) {
      ref.read(resetPasswordFormControllerProvider.notifier).setError(
            'Link inválido ou expirado. Solicite um novo e-mail de redefinição.',
          );
    }
  }

  Future<void> _submit() async {
    final form = ref.read(resetPasswordFormControllerProvider);
    final validation = form.validationMessage;
    if (validation != null) {
      ref.read(resetPasswordFormControllerProvider.notifier).setError(validation);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(newPassword: form.password);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AuthFailure catch (failure) {
      ref
          .read(resetPasswordFormControllerProvider.notifier)
          .setError(failure.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(resetPasswordFormControllerProvider);

    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: AuthWebBrandPanel(
              headline: 'Escolha uma nova senha para continuar usando o Cheery.',
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: form.isRecoveringSession
                      ? const CheeryLoading(
                          message: 'Validando link de redefinição...',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Redefinir senha',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              form.hasRecoverySession
                                  ? 'Digite e confirme sua nova senha.'
                                  : 'Não foi possível validar o link de redefinição.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (form.hasRecoverySession) ...[
                              const SizedBox(height: 24),
                              AuthPasswordField(
                                label: 'Nova senha',
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                enabled: !_isSubmitting,
                                onChanged: ref
                                    .read(
                                      resetPasswordFormControllerProvider
                                          .notifier,
                                    )
                                    .setPassword,
                              ),
                              const SizedBox(height: 12),
                              AuthPasswordField(
                                label: 'Confirmar nova senha',
                                controller: _confirmController,
                                textInputAction: TextInputAction.done,
                                enabled: !_isSubmitting,
                                onChanged: ref
                                    .read(
                                      resetPasswordFormControllerProvider
                                          .notifier,
                                    )
                                    .setConfirmPassword,
                              ),
                            ],
                            if (form.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                form.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.danger),
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (form.hasRecoverySession)
                              CheeryButton(
                                label: 'Salvar nova senha',
                                expanded: true,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _submit,
                              )
                            else
                              CheeryButton(
                                label: 'Solicitar novo link',
                                expanded: true,
                                onPressed: () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .cancelPasswordRecovery();
                                  if (!context.mounted) return;
                                  context.go(AppRoutes.forgotPassword);
                                },
                              ),
                            const SizedBox(height: 12),
                            CheeryButton(
                              label: 'Voltar ao login',
                              variant: CheeryButtonVariant.text,
                              onPressed: _cancelRecovery,
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

  Future<void> _cancelRecovery() async {
    await ref.read(authControllerProvider.notifier).cancelPasswordRecovery();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }
}
