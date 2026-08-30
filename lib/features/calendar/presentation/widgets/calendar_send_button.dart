import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// WhatsApp send button, "Enviado (desfazer)" when already marked sent, or an
/// "Envio automático" badge when the client is handled by the cron.
class CalendarSendButton extends StatelessWidget {
  const CalendarSendButton({
    this.onPressed,
    this.messageSent = false,
    this.automaticEnabled = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool messageSent;
  final bool automaticEnabled;

  static const whatsappIconAsset = 'assets/images/svgs/whatsapp-white-icon.svg';
  static const whatsappGreen = Color(0xFF25D366);
  static const automaticBackground = Color(0xFFD4EDDA);
  static const automaticForeground = Color(0xFF155724);

  @override
  Widget build(BuildContext context) {
    if (messageSent) {
      return Material(
        color: AppColors.blushDeep,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 16, color: AppColors.cherry),
                const SizedBox(width: 8),
                Text(
                  'Enviado (desfazer)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (automaticEnabled) {
      return Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: automaticBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.autorenew, size: 16, color: automaticForeground),
            const SizedBox(width: 8),
            Text(
              'Envio automático',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: automaticForeground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: whatsappGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                whatsappIconAsset,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                placeholderBuilder: (_) =>
                    const SizedBox(width: 16, height: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Enviar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
