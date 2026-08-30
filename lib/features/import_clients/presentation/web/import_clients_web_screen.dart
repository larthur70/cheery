import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/import_clients/domain/import_step.dart';
import 'package:cheery/features/import_clients/presentation/controllers/import_clients_controller.dart';
import 'package:cheery/features/import_clients/presentation/controllers/import_clients_state.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_confirm_step.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_mapping_step.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_review_step.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_stepper_bar.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_upload_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ImportClientsWebScreen extends ConsumerWidget {
  const ImportClientsWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importClientsControllerProvider);
    final controller = ref.read(importClientsControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Voltar',
                onPressed: () {
                  if (state.step == ImportStep.confirmation) {
                    context.go(AppRoutes.clients);
                  } else if (state.step == ImportStep.upload) {
                    context.go(AppRoutes.clients);
                  } else {
                    controller.goBack();
                  }
                },
                icon: const Icon(Icons.arrow_back, color: AppColors.cherry),
              ),
              const SizedBox(width: 4),
              Text(
                'Importar Clientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cherry,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Ajuda',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Como importar'),
                      content: const Text(
                        '1. Envie um arquivo CSV ou Excel.\n'
                        '2. Confirme o mapeamento das colunas.\n'
                        '3. Revise os erros e importe apenas os válidos.\n'
                        '4. Veja o resumo da importação.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entendi'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.help_outline,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ImportStepperBar(current: state.step),
          const SizedBox(height: 24),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: switch (state.step) {
                  ImportStep.upload => ImportUploadStep(
                      fileName: state.fileName,
                      isParsing: state.isParsing,
                      errorMessage: state.errorMessage,
                      onBrowse: controller.pickAndParseFile,
                    ),
                  ImportStep.mapping => state.spreadsheet == null
                      ? const SizedBox.shrink()
                      : ImportMappingStep(
                          spreadsheet: state.spreadsheet!,
                          mapping: state.mapping,
                          errorMessage: state.errorMessage,
                          onChanged: controller.updateMapping,
                        ),
                  ImportStep.review => state.validation == null
                      ? const SizedBox.shrink()
                      : ImportReviewStep(
                          validation: state.validation!,
                          authorizationConfirmed: state.authorizationConfirmed,
                          onAuthorizationChanged:
                              controller.setAuthorizationConfirmed,
                          errorMessage: state.errorMessage,
                        ),
                  ImportStep.confirmation => state.summary == null
                      ? const SizedBox.shrink()
                      : ImportConfirmStep(
                          summary: state.summary!,
                          onGoToClients: () => context.go(AppRoutes.clients),
                          onImportAgain: controller.reset,
                        ),
                },
              ),
            ),
          ),
          if (state.step != ImportStep.confirmation) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CheeryButton(
                  label: 'Cancelar',
                  variant: CheeryButtonVariant.outlined,
                  onPressed: () => context.go(AppRoutes.clients),
                ),
                const SizedBox(width: 12),
                if (state.step != ImportStep.upload) ...[
                  CheeryButton(
                    label: 'Voltar',
                    variant: CheeryButtonVariant.text,
                    onPressed: controller.goBack,
                  ),
                  const SizedBox(width: 8),
                ],
                CheeryButton(
                  label: state.step == ImportStep.review
                      ? 'Importar válidos'
                      : 'Próximo Passo',
                  onPressed: _nextEnabled(state)
                      ? controller.goNext
                      : null,
                  isLoading: state.isImporting || state.isParsing,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _nextEnabled(ImportClientsState state) {
    return switch (state.step) {
      ImportStep.upload => state.canGoToMapping,
      ImportStep.mapping => state.canGoToReview,
      ImportStep.review => state.canImport,
      ImportStep.confirmation => false,
    };
  }
}
