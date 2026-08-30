import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TodayBirthdayCard extends StatelessWidget {
  const TodayBirthdayCard({
    required this.birthday,
    this.onSendMessage,
    this.onUndoSent,
    super.key,
  });

  final TodayBirthdayUiModel birthday;
  final VoidCallback? onSendMessage;
  final VoidCallback? onUndoSent;

  static const whatsappIconAsset = 'assets/images/svgs/whatsapp-white-icon.svg';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.cherrySoft,
                backgroundImage: birthday.avatarUrl != null
                    ? NetworkImage(birthday.avatarUrl!)
                    : null,
                child: birthday.avatarUrl == null
                    ? Text(
                        birthday.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.cherry,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 2),
                    Text(
                      'Hoje, ${birthday.age} anos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (birthday.messageSent)
            _SentButton(onPressed: onUndoSent)
          else if (birthday.automaticEnabled)
            const _AutomaticBadge()
          else
            _SendMessageButton(onPressed: onSendMessage),
        ],
      ),
    );
  }
}

class _AutomaticBadge extends StatelessWidget {
  const _AutomaticBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.autorenew, size: 18, color: Color(0xFF155724)),
          const SizedBox(width: 8),
          Text(
            'Envio automático',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF155724),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
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

class _SendMessageButton extends StatelessWidget {
  const _SendMessageButton({this.onPressed});

  final VoidCallback? onPressed;

  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _whatsappGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                TodayBirthdayCard.whatsappIconAsset,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                placeholderBuilder: (_) => const SizedBox(width: 18, height: 18),
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
