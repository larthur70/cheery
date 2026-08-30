import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_day_details.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_month_header.dart';
import 'package:flutter/material.dart';

class CalendarWebScreen extends StatelessWidget {
  const CalendarWebScreen({
    required this.state,
    required this.onSelectDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    this.onSend,
    this.onUndoSent,
    super.key,
  });

  final CalendarViewState state;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<CalendarBirthday>? onSend;
  final ValueChanged<CalendarBirthday>? onUndoSent;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calendário Mensal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use as setas para navegar entre os meses e ver todos os aniversários.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          CalendarMonthHeader(
                            visibleMonth: state.visibleMonth,
                            onPrevious: onPreviousMonth,
                            onNext: onNextMonth,
                            onToday: onToday,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: CalendarMonthGrid(
                              visibleMonth: state.visibleMonth,
                              selectedDate: state.selectedDate,
                              birthdays: state.birthdays,
                              onSelectDate: onSelectDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SingleChildScrollView(
                        child: CalendarDayDetails(
                          selectedDate: state.selectedDate,
                          birthdays: state.birthdaysForSelectedDay,
                          onSend: onSend,
                          onUndoSent: onUndoSent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
