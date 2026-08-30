import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Handles Supabase OAuth return at `/auth/callback`.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _completeOAuth());
  }

  Future<void> _completeOAuth() async {
    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .recoverSessionFromCurrentUrl();

      if (!mounted) return;

      if (user != null) {
        context.go(AppRoutes.home);
        return;
      }

      // Wait briefly for auth stream if URL was already consumed.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final current = ref.read(authControllerProvider).valueOrNull;
      if (current != null) {
        await ref
            .read(authControllerProvider.notifier)
            .ensureProfileAfterConfirmation();
        if (mounted) context.go(AppRoutes.home);
        return;
      }

      setState(() {
        _errorMessage =
            'Não foi possível concluir o login. Tente novamente.';
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Não foi possível concluir o login. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null && _errorMessage == null && mounted) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _errorMessage == null
            ? const CheeryLoading(message: 'Finalizando login...')
            : Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
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
                        child: const Text('Voltar ao login'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
