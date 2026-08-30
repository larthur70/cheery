import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_birthday_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Selected-day header + birthday list.
class CalendarDayDetails extends StatelessWidget {
  const CalendarDayDetails({
    required this.selectedDate,
    required this.birthdays,
    this.onSend,
    this.onUndoSent,
    this.compact = false,
    super.key,
  });

  final DateTime selectedDate;
  final List<CalendarBirthday> birthdays;
  final ValueChanged<CalendarBirthday>? onSend;
  final ValueChanged<CalendarBirthday>? onUndoSent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat("d 'de' MMMM", 'pt_BR').format(selectedDate);
    final capitalized =
        '${dayLabel[0].toUpperCase()}${dayLabel.substring(1)}';
    final count = birthdays.length;
    final countLabel = count == 1
        ? '1 aniversariante'
        : '$count aniversariantes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compact)
          Row(
            children: [
              Expanded(
                child: Text(
                  capitalized,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.blushDeep,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count == 1 ? '1 aniversário' : '$count aniversários',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          )
        else ...[
          Text(
            capitalized,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.cherry,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            countLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
        ],
        SizedBox(height: compact ? 14 : 20),
        if (birthdays.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhum aniversariante neste dia.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkMuted,
                  ),
            ),
          )
        else
          for (final birthday in birthdays) ...[
            CalendarBirthdayCard(
              birthday: birthday,
              referenceDate: selectedDate,
              compact: compact,
              onSend: onSend == null ? null : () => onSend!(birthday),
              onUndoSent:
                  onUndoSent == null ? null : () => onUndoSent!(birthday),
            ),
            SizedBox(height: compact ? 10 : 12),
          ],
      ],
    );
  }
}
