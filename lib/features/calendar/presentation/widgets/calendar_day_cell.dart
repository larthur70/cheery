import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Single day cell in the month grid.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.birthdayCount,
    required this.shortNames,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final int birthdayCount;
  final List<String> shortNames;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildWeb(context);
  }

  Widget _buildCompact(BuildContext context) {
    final hasBirthdays = birthdayCount > 0;
    final dayColor = !isCurrentMonth
        ? AppColors.inkMuted.withValues(alpha: 0.35)
        : isSelected
            ? Colors.white
            : AppColors.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.cherry : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.cherry.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isSelected && hasBirthdays)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.cake_outlined,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dayColor,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 5,
                  child: hasBirthdays && isCurrentMonth && !isSelected
                      ? Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.cherry,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeb(BuildContext context) {
    final hasBirthdays = birthdayCount > 0 && isCurrentMonth;
    final dayColor = !isCurrentMonth
        ? AppColors.inkMuted.withValues(alpha: 0.4)
        : AppColors.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blushDeep : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.cherry : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: dayColor,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                  ),
                  const Spacer(),
                  if (hasBirthdays)
                    const Icon(
                      Icons.cake_outlined,
                      size: 14,
                      color: AppColors.cherry,
                    ),
                ],
              ),
              if (hasBirthdays) ...[
                const SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (birthdayCount > 1)
                            Row(
                              children: [
                                for (var i = 0;
                                    i < birthdayCount.clamp(0, 3);
                                    i++) ...[
                                  if (i > 0) const SizedBox(width: 2),
                                  Icon(
                                    Icons.cake,
                                    size: 11,
                                    color: AppColors.cherry.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          for (final name in shortNames)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.inkMuted,
                                      fontSize: 10,
                                      height: 1.1,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
