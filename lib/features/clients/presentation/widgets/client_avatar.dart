import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Circular avatar showing the client's first initial.
class ClientAvatar extends StatelessWidget {
  const ClientAvatar({
    required this.name,
    this.size = 40,
    super.key,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    final color = _colorFor(name);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.cherryDark,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  static Color _colorFor(String name) {
    final palette = [
      AppColors.cherrySoft,
      AppColors.cherryMuted,
      const Color(0xFFFFE8A3),
      const Color(0xFFFFD6E0),
      AppColors.blushDeep,
    ];
    if (name.isEmpty) return palette.first;
    return palette[name.codeUnitAt(0) % palette.length];
  }
}
