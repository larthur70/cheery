import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Home section highlighting the next client birthday after today.
class NextBirthdaySection extends StatelessWidget {
  const NextBirthdaySection({
    required this.nextBirthday,
    super.key,
  });

  final NextBirthdayUiModel? nextBirthday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximo aniversariante',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.cherry,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (nextBirthday == null)
          Text(
            'Cadastre clientes para ver o próximo aniversário aqui.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
            ),
          )
        else
          _NextBirthdayCard(birthday: nextBirthday!),
      ],
    );
  }
}

class _NextBirthdayCard extends StatelessWidget {
  const _NextBirthdayCard({required this.birthday});

  final NextBirthdayUiModel birthday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat("d 'de' MMMM", 'pt_BR')
        .format(birthday.nextOccurrence);
    final capitalizedDate =
        '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';
    final countdown = birthday.daysUntil == 1
        ? 'Amanhã'
        : 'Em ${birthday.daysUntil} dias';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.cherrySoft,
            child: Text(
              birthday.name.isNotEmpty
                  ? birthday.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.cherry,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  birthday.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  capitalizedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              countdown,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.mint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
