import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday_matcher.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:flutter/material.dart';

/// Monthly calendar grid (Sunday → Saturday).
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.birthdays,
    required this.onSelectDate,
    this.compact = false,
    super.key,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<CalendarBirthday> birthdays;
  final ValueChanged<DateTime> onSelectDate;
  final bool compact;

  static const _weekdaysFull = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
  ];

  static const _weekdaysShort = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final days = _buildGridDays(visibleMonth);
    final labels = compact ? _weekdaysShort : _weekdaysFull;
    final counts =
        CalendarBirthdayMatcher.countsForMonth(birthdays, visibleMonth);
    final rowCount = (days.length / 7).ceil();
    final spacing = compact ? 4.0 : 6.0;

    return Column(
      children: [
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? 8 : 12),
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < rowCount; row++) ...[
                if (row > 0) SizedBox(height: spacing),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < 7; col++) ...[
                        if (col > 0) SizedBox(width: spacing),
                        Expanded(
                          child: _cellFor(
                            days[row * 7 + col],
                            counts,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _cellFor(DateTime date, Map<int, int> monthCounts) {
    final isCurrentMonth = date.month == visibleMonth.month;
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    final count = isCurrentMonth ? (monthCounts[date.day] ?? 0) : 0;
    final names = compact || count == 0
        ? const <String>[]
        : CalendarBirthdayMatcher.shortNamesForDay(birthdays, date);

    return CalendarDayCell(
      date: date,
      isCurrentMonth: isCurrentMonth,
      isSelected: isSelected,
      birthdayCount: count,
      shortNames: names,
      compact: compact,
      onTap: () => onSelectDate(date),
    );
  }

  /// Builds a flat list of dates covering full weeks for [month].
  static List<DateTime> _buildGridDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    // Dart weekday: Mon=1 … Sun=7. Convert so Sunday is column 0.
    final leading = first.weekday % 7;
    final start = first.subtract(Duration(days: leading));
    final days = <DateTime>[];
    for (var i = 0; i < 42; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    // Drop trailing week if it is entirely next month.
    final lastInMonth = DateTime(month.year, month.month + 1, 0);
    final usedWeeks = ((leading + lastInMonth.day + 6) ~/ 7);
    return days.take(usedWeeks * 7).toList();
  }
}
