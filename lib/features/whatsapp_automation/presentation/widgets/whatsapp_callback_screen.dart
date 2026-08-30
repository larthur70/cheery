import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_failure.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_connection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Handles `/whatsapp/callback` after Meta Embedded Signup redirect.
class WhatsAppCallbackScreen extends ConsumerStatefulWidget {
  const WhatsAppCallbackScreen({super.key});

  @override
  ConsumerState<WhatsAppCallbackScreen> createState() =>
      _WhatsAppCallbackScreenState();
}

class _WhatsAppCallbackScreenState
    extends ConsumerState<WhatsAppCallbackScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    final uri = GoRouterState.of(context).uri;
    final code = uri.queryParameters['code'];
    final phoneNumberId = uri.queryParameters['phone_number_id'];
    final wabaId = uri.queryParameters['waba_id'];
    final displayPhone = uri.queryParameters['display_phone'];
    final error = uri.queryParameters['error'];

    if (error != null && error.isNotEmpty) {
      setState(() => _error = error);
      return;
    }

    try {
      await ref.read(whatsappConnectionControllerProvider.notifier).completeConnect(
            code: code,
            phoneNumberId: phoneNumberId,
            wabaId: wabaId,
            displayPhone: displayPhone,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on WhatsAppFailure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = const WhatsAppOAuthFailure().message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Voltar à Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: CheeryLoading(message: 'Finalizando conexão com WhatsApp…'),
    );
  }
}
