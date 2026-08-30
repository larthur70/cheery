import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:flutter/material.dart';

/// Home empty state prompting the user to add their first client.
class HomeEmptyClientsCta extends StatelessWidget {
  const HomeEmptyClientsCta({
    required this.onAddClient,
    super.key,
  });

  final VoidCallback onAddClient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1_outlined,
            size: 40,
            color: AppColors.cherry.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum cliente cadastrado',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre o primeiro para ver aniversariantes aqui.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CheeryButton(
            label: 'Cadastrar cliente',
            icon: Icons.add,
            onPressed: onAddClient,
          ),
        ],
      ),
    );
  }
}
