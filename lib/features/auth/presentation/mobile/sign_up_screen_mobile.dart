import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/sign_up_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_pending_action.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_social_buttons.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:cheery/features/legal/presentation/widgets/privacy_policy_link_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreenMobile extends ConsumerStatefulWidget {
  const SignUpScreenMobile({super.key});

  @override
  ConsumerState<SignUpScreenMobile> createState() => _SignUpScreenMobileState();
}

class _SignUpScreenMobileState extends ConsumerState<SignUpScreenMobile> {
  final _fullNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  AuthPendingAction? _pending;

  bool get _isBusy => _pending != null;

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _run(
    AuthPendingAction action,
    Future<void> Function() body,
  ) async {
    setState(() => _pending = action);
    try {
      await body();
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  Future<void> _submit() async {
    final form = ref.read(signUpFormControllerProvider);
    final validation = form.validationMessage;
    if (validation != null) {
      ref.read(signUpFormControllerProvider.notifier).setError(validation);
      return;
    }

    await _run(AuthPendingAction.email, () async {
      try {
        final result =
            await ref.read(authControllerProvider.notifier).signUpWithEmail(
                  email: form.email,
                  password: form.password,
                  fullName: form.fullName,
                  companyName: form.companyName,
                );
        if (!mounted) return;
        if (result.needsEmailConfirmation) {
          context.go(AppRoutes.confirmEmailWithEmail(result.email));
        } else {
          context.go(AppRoutes.home);
        }
      } on AuthFailure catch (failure) {
        ref
            .read(signUpFormControllerProvider.notifier)
            .setError(failure.message);
      }
    });
  }

  Future<void> _social(
    AuthPendingAction action,
    Future<void> Function() body,
  ) async {
    ref.read(signUpFormControllerProvider.notifier).clearError();
    await _run(action, () async {
      try {
        await body();
        if (mounted && ref.read(authControllerProvider).valueOrNull != null) {
          context.go(AppRoutes.home);
        }
      } on AuthCancelledFailure {
        // User closed the browser / cancelled — no error banner.
      } on AuthFailure catch (failure) {
        ref
            .read(signUpFormControllerProvider.notifier)
            .setError(failure.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signUpFormControllerProvider);
    final formNotifier = ref.read(signUpFormControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isBusy ? null : () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Nome',
                controller: _fullNameController,
                enabled: !_isBusy,
                onChanged: formNotifier.setFullName,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Nome da sua empresa',
                controller: _companyController,
                enabled: !_isBusy,
                onChanged: formNotifier.setCompanyName,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isBusy,
                onChanged: formNotifier.setEmail,
              ),
              const SizedBox(height: 12),
              AuthPasswordField(
                label: 'Senha',
                controller: _passwordController,
                enabled: !_isBusy,
                onChanged: formNotifier.setPassword,
              ),
              const SizedBox(height: 12),
              AuthPasswordField(
                label: 'Confirmar senha',
                controller: _confirmController,
                enabled: !_isBusy,
                onChanged: formNotifier.setConfirmPassword,
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
              const SizedBox(height: 20),
              const PrivacyPolicyLinkText(),
              const SizedBox(height: 16),
              CheeryButton(
                label: 'Continuar',
                expanded: true,
                isLoading: _pending == AuthPendingAction.email,
                onPressed: _isBusy ? null : _submit,
              ),
              const SizedBox(height: 20),
              const AuthOrDivider(),
              const SizedBox(height: 20),
              AuthSocialButtons(
                isGoogleLoading: _pending == AuthPendingAction.google,
                isAppleLoading: _pending == AuthPendingAction.apple,
                onGooglePressed: _isBusy
                    ? null
                    : () => _social(
                          AuthPendingAction.google,
                          ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle,
                        ),
                onApplePressed: _isBusy
                    ? null
                    : () => _social(
                          AuthPendingAction.apple,
                          ref
                              .read(authControllerProvider.notifier)
                              .signInWithApple,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
