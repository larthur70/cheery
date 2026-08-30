import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_pending_action.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_social_buttons.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:cheery/features/auth/presentation/widgets/auth_web_brand_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreenWeb extends ConsumerStatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  ConsumerState<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends ConsumerState<LoginScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthPendingAction? _pending;

  bool get _isBusy => _pending != null;

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
    await _run(action, () async {
      try {
        await body();
        if (mounted && ref.read(authControllerProvider).valueOrNull != null) {
          context.go(AppRoutes.home);
        }
      } on AuthFailure catch (failure) {
        ref.read(loginFormControllerProvider.notifier).setError(failure.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginFormControllerProvider);

    return Scaffold(
      body: Row(
        children: [
          const Expanded(child: AuthWebBrandPanel()),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Acesse sua conta',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Entre para gerenciar aniversários e mensagens.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 28),
                          AuthTextField(
                            label: 'E-mail',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            enabled: !_isBusy,
                            onChanged: ref
                                .read(loginFormControllerProvider.notifier)
                                .setEmail,
                          ),
                          const SizedBox(height: 14),
                          AuthPasswordField(
                            label: 'Senha',
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            enabled: !_isBusy,
                            onChanged: ref
                                .read(loginFormControllerProvider.notifier)
                                .setPassword,
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
                          const SizedBox(height: 16),
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
                            isGoogleLoading:
                                _pending == AuthPendingAction.google,
                            isAppleLoading:
                                _pending == AuthPendingAction.apple,
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
                          const SizedBox(height: 28),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Não tem conta?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              CheeryButton(
                                label: 'Criar conta',
                                variant: CheeryButtonVariant.text,
                                onPressed: _isBusy
                                    ? null
                                    : () => context.go(AppRoutes.signUp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
