import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Full-width birthday card for the mobile home list.
class HomeMobileBirthdayCard extends StatelessWidget {
  const HomeMobileBirthdayCard({
    required this.birthday,
    this.onSendMessage,
    this.onUndoSent,
    super.key,
  });

  final TodayBirthdayUiModel birthday;
  final VoidCallback? onSendMessage;
  final VoidCallback? onUndoSent;

  @override
  Widget build(BuildContext context) {
    final initial =
        birthday.name.isNotEmpty ? birthday.name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.cherrySoft,
                backgroundImage: birthday.avatarUrl != null
                    ? NetworkImage(birthday.avatarUrl!)
                    : null,
                child: birthday.avatarUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.cherry,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      birthday.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blushDeep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Hoje, ${birthday.age} anos',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.cherry,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (birthday.messageSent)
            _SentButton(onPressed: onUndoSent)
          else if (birthday.automaticEnabled)
            Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDDA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Envio automático',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF155724),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          else
            _SendButton(onPressed: onSendMessage),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({this.onPressed});

  final VoidCallback? onPressed;

  static const _whatsappIconAsset =
      'assets/images/svgs/whatsapp-white-icon.svg';
  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _whatsappGreen,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _whatsappIconAsset,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                placeholderBuilder: (_) =>
                    const SizedBox(width: 18, height: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Enviar mensagem',
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

class _SentButton extends StatelessWidget {
  const _SentButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blushDeep,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check, size: 18, color: AppColors.cherry),
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
}
