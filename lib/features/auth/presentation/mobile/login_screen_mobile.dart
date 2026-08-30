import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_pending_action.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_social_buttons.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreenMobile extends ConsumerStatefulWidget {
  const LoginScreenMobile({super.key});

  @override
  ConsumerState<LoginScreenMobile> createState() => _LoginScreenMobileState();
}

class _LoginScreenMobileState extends ConsumerState<LoginScreenMobile> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthPendingAction? _pending;

  bool get _isBusy => _pending != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginFormControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    final form = ref.read(loginFormControllerProvider);
    if (!form.isValid) {
      ref
          .read(loginFormControllerProvider.notifier)
          .setError('Informe e-mail e senha válidos.');
      return;
    }

    await _run(AuthPendingAction.email, () async {
      try {
        await ref.read(authControllerProvider.notifier).signInWithEmail(
              email: form.email,
              password: form.password,
            );
        if (mounted) context.go(AppRoutes.home);
      } on AuthEmailNotConfirmedFailure {
        if (mounted) {
          context.go(AppRoutes.confirmEmailWithEmail(form.email));
        }
      } on AuthFailure catch (failure) {
        ref.read(loginFormControllerProvider.notifier).setError(failure.message);
      }
    });
  }

  Future<void> _social(
    AuthPendingAction action,
    Future<void> Function() body,
  ) async {
    ref.read(loginFormControllerProvider.notifier).clearError();
    await _run(action, () async {
      try {
        await body();
        if (mounted && ref.read(authControllerProvider).valueOrNull != null) {
          context.go(AppRoutes.home);
        }
      } on AuthCancelledFailure {
        // User closed the browser / cancelled — no error banner.
      } on AuthFailure catch (failure) {
        ref.read(loginFormControllerProvider.notifier).setError(failure.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginFormControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(
                child: CheeryLogo(size: 48, wordmarkSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                'Entre na sua conta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 28),
              AuthTextField(
                label: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isBusy,
                onChanged:
                    ref.read(loginFormControllerProvider.notifier).setEmail,
              ),
              const SizedBox(height: 12),
              AuthPasswordField(
                label: 'Senha',
                controller: _passwordController,
                enabled: !_isBusy,
                onChanged:
                    ref.read(loginFormControllerProvider.notifier).setPassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CheeryButton(
                  label: 'Esqueceu a senha?',
                  variant: CheeryButtonVariant.text,
                  onPressed: _isBusy
                      ? null
                      : () => context.go(AppRoutes.forgotPassword),
                ),
              ),
              if (form.errorMessage != null)
                Text(
                  form.errorMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.danger),
                ),
              const SizedBox(height: 12),
              CheeryButton(
                label: 'Entrar',
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
              const SizedBox(height: 20),
              CheeryButton(
                label: 'Criar conta',
                variant: CheeryButtonVariant.outlined,
                expanded: true,
                onPressed:
                    _isBusy ? null : () => context.go(AppRoutes.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
