import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand wordmark styles (logo + footer).
///
/// Nunito is rounded and friendly — pairs well with the cherry mark.
abstract final class AppBrandTypography {
  static TextStyle wordmark({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cherry,
      height: 1,
      letterSpacing: -0.2,
    );
  }
}
