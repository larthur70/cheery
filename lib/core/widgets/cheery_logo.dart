import 'package:cheery/core/theme/app_brand_typography.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand mark: logo image + optional "Cheery" wordmark.
class CheeryLogo extends StatelessWidget {
  const CheeryLogo({
    this.size = 32,
    this.showWordmark = true,
    this.wordmarkColor,
    this.wordmarkSize,
    this.axis = Axis.horizontal,
    super.key,
  });

  static const assetPath = 'assets/images/logo.png';

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;
  final double? wordmarkSize;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
      fit: BoxFit.contain,
    );

    if (!showWordmark) return mark;

    final resolvedWordmarkSize = wordmarkSize ?? (size * 0.72).clamp(18, 40);
    final wordmark = Text(
      'Cheery',
      style: AppBrandTypography.wordmark(
        fontSize: resolvedWordmarkSize,
        color: wordmarkColor ?? AppColors.cherry,
      ),
    );

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mark,
          SizedBox(height: size * 0.2),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        // Nunito metrics sit slightly high vs the cherry mark — nudge down.
        Transform.translate(
          offset: Offset(0, size * 0.06),
          child: wordmark,
        ),
      ],
    );
  }
}
