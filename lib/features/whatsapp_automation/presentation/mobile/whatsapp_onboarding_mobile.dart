import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_onboarding_controller.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WhatsAppOnboardingMobile extends ConsumerWidget {
  const WhatsAppOnboardingMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: WhatsAppOnboardingBody(
          onFinish: () => finishWhatsAppOnboarding(context, ref),
          onClose: () {
            ref.invalidate(whatsappOnboardingControllerProvider);
            context.pop();
          },
        ),
      ),
    );
  }
}
