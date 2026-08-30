import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:flutter/material.dart';

/// Colored badge for Meta template approval status.
class TemplateApprovalBadge extends StatelessWidget {
  const TemplateApprovalBadge({required this.status, super.key});

  final TemplateApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TemplateApprovalStatus.draft => (
          AppColors.blushDeep,
          AppColors.inkMuted,
        ),
      TemplateApprovalStatus.pendingApproval => (
          const Color(0xFFFFF3CD),
          const Color(0xFF856404),
        ),
      TemplateApprovalStatus.approved => (
          const Color(0xFFD4EDDA),
          const Color(0xFF155724),
        ),
      TemplateApprovalStatus.rejected => (
          const Color(0xFFF8D7DA),
          const Color(0xFF721C24),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
