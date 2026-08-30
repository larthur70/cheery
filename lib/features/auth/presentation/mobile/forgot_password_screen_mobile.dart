import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/forgot_password_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreenMobile extends ConsumerStatefulWidget {
  const ForgotPasswordScreenMobile({super.key});

  @override
  ConsumerState<ForgotPasswordScreenMobile> createState() =>
      _ForgotPasswordScreenMobileState();
}

class _ForgotPasswordScreenMobileState
    extends ConsumerState<ForgotPasswordScreenMobile> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = ref.read(forgotPasswordFormControllerProvider);
    if (!form.canSubmit) return;
    if (!form.isValid) {
      ref
          .read(forgotPasswordFormControllerProvider.notifier)
          .setError('Informe um e-mail válido.');
      return;
    }

    final notifier = ref.read(forgotPasswordFormControllerProvider.notifier);
    notifier.setSubmitting(true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: form.email);
      if (!mounted) return;
      notifier.setSuccess(
        'Se existir uma conta com este e-mail, enviamos um link de redefinição.',
      );
      notifier.startCooldown();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      notifier.setError(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(forgotPasswordFormControllerProvider);
    final submitLabel = form.remainingSeconds > 0
        ? 'Enviar em ${form.remainingSeconds}s'
        : 'Enviar link';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Esqueceu a senha'),
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
              Text(
                'Informe seu e-mail e enviaremos um link para redefinir a senha.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !form.isSubmitting,
                onChanged: ref
                    .read(forgotPasswordFormControllerProvider.notifier)
                    .setEmail,
              ),
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
              if (form.successMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  form.successMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.success),
                ),
              ],
              const SizedBox(height: 24),
              CheeryButton(
                label: submitLabel,
                expanded: true,
                isLoading: form.isSubmitting,
                onPressed: form.canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
