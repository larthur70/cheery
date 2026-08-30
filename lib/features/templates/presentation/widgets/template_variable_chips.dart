import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';
import 'package:flutter/material.dart';

/// Chips to insert friendly variable tokens into the message body.
class TemplateVariableChips extends StatelessWidget {
  const TemplateVariableChips({
    required this.onInsert,
    super.key,
  });

  final ValueChanged<TemplateVariableDef> onInsert;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final def in TemplateVariableCatalog.all)
          ActionChip(
            avatar: const Icon(Icons.add, size: 16, color: AppColors.cherry),
            label: Text(
              def.token,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            backgroundColor: AppColors.cherrySoft,
            side: BorderSide.none,
            onPressed: () => onInsert(def),
          ),
      ],
    );
  }
}
