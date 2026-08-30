import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Colored chip showing the assigned message template name.
class ClientTemplateChip extends StatelessWidget {
  const ClientTemplateChip({
    required this.label,
    this.compact = false,
    super.key,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cherrySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.cherry,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
