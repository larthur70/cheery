import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Month title with previous / today / next controls.
class CalendarMonthHeader extends StatelessWidget {
  const CalendarMonthHeader({
    required this.visibleMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    this.showTodayButton = true,
    this.compact = false,
    super.key,
  });

  final DateTime visibleMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final bool showTodayButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy', 'pt_BR').format(visibleMonth);
    final capitalized =
        '${label[0].toUpperCase()}${label.substring(1)}';

    if (compact) {
      return Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.cherry,
          ),
          Expanded(
            child: Text(
              capitalized,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.cherry,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            capitalized,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.cherry,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.inkMuted,
        ),
        if (showTodayButton)
          TextButton(
            onPressed: onToday,
            child: Text(
              'Hoje',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.inkMuted,
        ),
      ],
    );
  }
}
