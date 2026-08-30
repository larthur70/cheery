import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_onboarding_controller.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhatsAppOnboardingWeb extends ConsumerWidget {
  const WhatsAppOnboardingWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WhatsAppOnboardingBody(
      onFinish: () => finishWhatsAppOnboarding(context, ref),
      onClose: () {
        ref.invalidate(whatsappOnboardingControllerProvider);
        Navigator.of(context).pop();
      },
    );
  }
}
