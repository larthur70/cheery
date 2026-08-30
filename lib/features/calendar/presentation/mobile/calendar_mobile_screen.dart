import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_day_details.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:cheery/features/calendar/presentation/widgets/calendar_month_header.dart';
import 'package:flutter/material.dart';

class CalendarMobileScreen extends StatelessWidget {
  const CalendarMobileScreen({
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
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendário',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.cherry,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Navegue pelos meses para ver os aniversários.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  decoration: BoxDecoration(
                    color: AppColors.blushDeep,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      CalendarMonthHeader(
                        visibleMonth: state.visibleMonth,
                        onPrevious: onPreviousMonth,
                        onNext: onNextMonth,
                        onToday: onToday,
                        compact: true,
                        showTodayButton: false,
                      ),
                      SizedBox(
                        height: 280,
                        child: CalendarMonthGrid(
                          visibleMonth: state.visibleMonth,
                          selectedDate: state.selectedDate,
                          birthdays: state.birthdays,
                          onSelectDate: onSelectDate,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: CalendarDayDetails(
                  selectedDate: state.selectedDate,
                  birthdays: state.birthdaysForSelectedDay,
                  onSend: onSend,
                  onUndoSent: onUndoSent,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
