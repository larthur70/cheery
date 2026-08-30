import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Completes account deletion after the user opens the confirmation email link.
class ConfirmAccountDeletionScreen extends ConsumerStatefulWidget {
  const ConfirmAccountDeletionScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ConfirmAccountDeletionScreen> createState() =>
      _ConfirmAccountDeletionScreenState();
}

class _ConfirmAccountDeletionScreenState
    extends ConsumerState<ConfirmAccountDeletionScreen> {
  String? _errorMessage;
  var _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirm());
  }

  Future<void> _confirm() async {
    final token = widget.token.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Link de confirmação inválido ou expirado.';
      });
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .confirmAccountDeletion(token: token);
      ref.read(loginFormControllerProvider.notifier).clearError();
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      setState(() => _done = true);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Não foi possível excluir a conta. Tente solicitar um novo e-mail.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Ir para o login'),
          ),
        ],
      );
    }

    if (_done) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.cherry,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Conta excluída',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os dados associados a esta conta foram removidos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Voltar ao login'),
          ),
        ],
      );
    }

    return const CheeryLoading(message: 'Excluindo sua conta...');
  }
}
