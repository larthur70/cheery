import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum CheeryButtonVariant { filled, outlined, text }

/// Primary button used across Cheery screens.
class CheeryButton extends StatelessWidget {
  const CheeryButton({
    required this.label,
    required this.onPressed,
    this.variant = CheeryButtonVariant.filled,
    this.icon,
    this.leading,
    this.isLoading = false,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final CheeryButtonVariant variant;
  final IconData? icon;
  /// Custom leading widget (e.g. SVG). Takes precedence over [icon].
  final Widget? leading;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    final leadingWidget = leading ??
        (icon == null ? null : Icon(icon, size: 18));

    final progressColor = variant == CheeryButtonVariant.filled
        ? Colors.white
        : AppColors.cherry;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: progressColor,
            ),
          )
        : leadingWidget == null
            ? labelText
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  leadingWidget,
                  const SizedBox(width: 8),
                  if (expanded) Expanded(child: labelText) else labelText,
                ],
              );

    final button = switch (variant) {
      CheeryButtonVariant.filled => FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      CheeryButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      CheeryButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.cherry,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(48, 44),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: child,
        ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
