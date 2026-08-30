import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Birthday label with cake icon (day/month).
class ClientBirthdayLabel extends StatelessWidget {
  const ClientBirthdayLabel({
    required this.birthDate,
    this.asPill = false,
    super.key,
  });

  final DateTime birthDate;
  final bool asPill;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('dd/MM').format(birthDate);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cake_outlined,
          size: 16,
          color: asPill ? AppColors.cherry : AppColors.inkMuted,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: asPill ? AppColors.cherry : AppColors.ink,
                fontWeight: asPill ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ],
    );

    if (!asPill) return child;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blushDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
