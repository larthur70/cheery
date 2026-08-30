import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/import_clients/domain/import_step.dart';
import 'package:flutter/material.dart';

class ImportStepperBar extends StatelessWidget {
  const ImportStepperBar({
    required this.current,
    super.key,
  });

  final ImportStep current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < ImportStep.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _StepItem(
              index: i + 1,
              label: ImportStep.values[i].label,
              isActive: ImportStep.values[i].index <= current.index,
              isCurrent: ImportStep.values[i] == current,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.cherry : AppColors.inkMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.cherry : AppColors.blushDeep,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.cherry
                : (isActive ? AppColors.cherryMuted : AppColors.border),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
