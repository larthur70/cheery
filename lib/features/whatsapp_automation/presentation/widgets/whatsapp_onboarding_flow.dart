import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_failure.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_onboarding_copy.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_connection_controller.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_onboarding_controller.dart';
import 'package:cheery/features/whatsapp_automation/presentation/mobile/whatsapp_onboarding_mobile.dart';
import 'package:cheery/features/whatsapp_automation/presentation/web/whatsapp_onboarding_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Adaptive entry used by GoRouter `/whatsapp/onboarding`.
class WhatsAppOnboardingEntryScreen extends StatelessWidget {
  const WhatsAppOnboardingEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const WhatsAppOnboardingMobile(),
      desktop: (_) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Card(
              margin: EdgeInsets.all(24),
              child: WhatsAppOnboardingWeb(),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> finishWhatsAppOnboarding(
  BuildContext context,
  WidgetRef ref,
) async {
  final onboarding = ref.read(whatsappOnboardingControllerProvider.notifier);
  onboarding.setStartingOAuth(true);
  try {
    await ref.read(whatsappConnectionControllerProvider.notifier).startConnect();
    if (!context.mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.pop();
    }
  } on WhatsAppFailure catch (failure) {
    onboarding.setError(failure.message);
  } catch (_) {
    onboarding.setError(const WhatsAppOAuthFailure().message);
  }
}

class WhatsAppOnboardingBody extends ConsumerWidget {
  const WhatsAppOnboardingBody({
    required this.onFinish,
    required this.onClose,
    super.key,
  });

  final VoidCallback onFinish;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(whatsappOnboardingControllerProvider);
    final step = WhatsAppOnboardingCopy.steps[state.stepIndex];
    final notifier = ref.read(whatsappOnboardingControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Integrar WhatsApp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: state.isStartingOAuth ? null : onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Passo ${state.stepIndex + 1} de ${WhatsAppOnboardingState.stepCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            step.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.45,
                ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              if (state.stepIndex > 0)
                CheeryButton(
                  label: 'Voltar',
                  variant: CheeryButtonVariant.outlined,
                  onPressed:
                      state.isStartingOAuth ? null : notifier.previousStep,
                ),
              const Spacer(),
              CheeryButton(
                label: state.isLastStep ? 'Conectar WhatsApp' : 'Continuar',
                isLoading: state.isStartingOAuth,
                onPressed: state.isStartingOAuth
                    ? null
                    : () {
                        if (state.isLastStep) {
                          onFinish();
                        } else {
                          notifier.nextStep();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
