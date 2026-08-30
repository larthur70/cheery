import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday_matcher.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_send_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Birthday person card with Enviar / Enviado (desfazer) action.
class CalendarBirthdayCard extends StatelessWidget {
  const CalendarBirthdayCard({
    required this.birthday,
    required this.referenceDate,
    this.onSend,
    this.onUndoSent,
    this.compact = false,
    super.key,
  });

  final CalendarBirthday birthday;
  final DateTime referenceDate;
  final VoidCallback? onSend;
  final VoidCallback? onUndoSent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final age = CalendarBirthdayMatcher.ageTurningOn(
      birthday.birthDate,
      referenceDate,
    );
    final initial =
        birthday.name.isNotEmpty ? birthday.name[0].toUpperCase() : '?';
    final messageSent = birthday.isBirthdayMessageSentThisYear;

    if (compact) {
      return _MobileCard(
        name: birthday.name,
        subtitle: 'Faz $age anos',
        initial: initial,
        messageSent: messageSent,
        automaticEnabled: birthday.automaticEnabled,
        onSend: onSend,
        onUndoSent: onUndoSent,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.06),
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
                radius: 24,
                backgroundColor: AppColors.cherrySoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
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
                    const SizedBox(height: 2),
                    Text(
                      'Faz $age anos.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CalendarSendButton(
            messageSent: messageSent,
            automaticEnabled: birthday.automaticEnabled,
            onPressed: messageSent ? onUndoSent : onSend,
          ),
        ],
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.name,
    required this.subtitle,
    required this.initial,
    required this.messageSent,
    required this.automaticEnabled,
    this.onSend,
    this.onUndoSent,
  });

  final String name;
  final String subtitle;
  final String initial;
  final bool messageSent;
  final bool automaticEnabled;
  final VoidCallback? onSend;
  final VoidCallback? onUndoSent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.cherrySoft,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.cherry,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!messageSent && automaticEnabled)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CalendarSendButton.automaticBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.autorenew,
                  size: 22,
                  color: CalendarSendButton.automaticForeground,
                ),
              ),
            )
          else
            Material(
              color: messageSent
                  ? AppColors.blushDeep
                  : CalendarSendButton.whatsappGreen,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: messageSent ? onUndoSent : onSend,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: messageSent
                        ? const Icon(
                            Icons.check,
                            size: 22,
                            color: AppColors.cherry,
                          )
                        : SvgPicture.asset(
                            CalendarSendButton.whatsappIconAsset,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                            placeholderBuilder: (_) =>
                                const SizedBox(width: 20, height: 20),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
