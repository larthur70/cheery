import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/import_clients/domain/import_summary.dart';
import 'package:flutter/material.dart';

class ImportConfirmStep extends StatelessWidget {
  const ImportConfirmStep({
    required this.summary,
    required this.onGoToClients,
    required this.onImportAgain,
    super.key,
  });

  final ImportSummary summary;
  final VoidCallback onGoToClients;
  final VoidCallback onImportAgain;

  @override
  Widget build(BuildContext context) {
    final success = summary.imported > 0 && summary.errors == 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.info_outline,
              size: 64,
              color: success ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Importação concluída' : 'Importação finalizada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            _SummaryLine(
              label: 'Importados',
              value: '${summary.imported}',
              color: AppColors.success,
            ),
            _SummaryLine(
              label: 'Ignorados',
              value: '${summary.skipped}',
              color: AppColors.inkMuted,
            ),
            _SummaryLine(
              label: 'Erros',
              value: '${summary.errors}',
              color: summary.errors > 0 ? AppColors.danger : AppColors.inkMuted,
            ),
            if (summary.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                summary.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 32),
            CheeryButton(
              label: 'Ir para clientes',
              onPressed: onGoToClients,
              expanded: true,
            ),
            const SizedBox(height: 12),
            CheeryButton(
              label: 'Importar outra planilha',
              variant: CheeryButtonVariant.outlined,
              onPressed: onImportAgain,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
