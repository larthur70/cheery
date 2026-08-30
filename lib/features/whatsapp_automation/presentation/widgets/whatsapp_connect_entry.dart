import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home CTA for WhatsApp automation — currently marked as coming soon.
///
/// [compact] renders icon-only actions, so it fits narrow mobile app bars.
class WhatsAppConnectEntry extends ConsumerWidget {
  const WhatsAppConnectEntry({this.compact = false, super.key});

  final bool compact;

  static const _whatsappIconAsset =
      'assets/images/svgs/whatsapp-white-icon.svg';

  static Widget _whatsappIcon({required double size, Color? color}) {
    return SvgPicture.asset(
      _whatsappIconAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile == null) return const SizedBox.shrink();

    if (compact) {
      return IconButton(
        onPressed: () => showWhatsAppComingSoonDialog(context),
        tooltip: 'Automatizar com WhatsApp (em breve)',
        icon: _whatsappIcon(size: 22, color: AppColors.cherry),
      );
    }

    return CheeryButton(
      label: 'Automatizar com WhatsApp (em breve)',
      variant: CheeryButtonVariant.outlined,
      leading: _whatsappIcon(size: 18, color: AppColors.cherry),
      onPressed: () => showWhatsAppComingSoonDialog(context),
    );
  }
}

Future<void> showWhatsAppComingSoonDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('WhatsApp em breve'),
      content: const Text(
        'A integração com WhatsApp Business está quase pronta. '
        'Em breve você poderá conectar seu número e automatizar as '
        'mensagens de aniversário pelo Cheery.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}

/// Home notice that WhatsApp Business automation is coming soon.
class WhatsAppFreeUpgradeHint extends StatelessWidget {
  const WhatsAppFreeUpgradeHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blushDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.cherry),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Automação via WhatsApp Business em breve.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
