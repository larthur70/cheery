import 'dart:typed_data';

import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/import_clients/data/column_auto_mapper.dart';
import 'package:cheery/features/import_clients/data/import_row_validator.dart';
import 'package:cheery/features/import_clients/data/spreadsheet_parser.dart';
import 'package:cheery/features/import_clients/domain/import_clients_failure.dart';
import 'package:cheery/features/import_clients/domain/import_column_field.dart';
import 'package:cheery/features/import_clients/domain/import_plan_limit_applier.dart';
import 'package:cheery/features/import_clients/domain/import_step.dart';
import 'package:cheery/features/import_clients/domain/import_summary.dart';
import 'package:cheery/features/import_clients/presentation/controllers/import_clients_state.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final importClientsControllerProvider =
    NotifierProvider.autoDispose<ImportClientsController, ImportClientsState>(
  ImportClientsController.new,
);

class ImportClientsController extends AutoDisposeNotifier<ImportClientsState> {
  @override
  ImportClientsState build() => const ImportClientsState();

  Future<void> pickAndParseFile() async {
    state = state.copyWith(isParsing: true, clearError: true);
    try {
      final result = await FilePicker.pickFiles(
        // On Flutter Web, FileType.custom + extensions is unreliable.
        // Accept any file and validate CSV/XLSX ourselves.
        type: FileType.any,
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(isParsing: false);
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw const ImportFileInvalidFailure(
          'Não foi possível ler o arquivo. Tente novamente.',
        );
      }

      await parseBytes(
        fileName: file.name.isEmpty
            ? 'planilha.${file.extension ?? 'xlsx'}'
            : file.name,
        bytes: bytes,
        extension: file.extension,
      );
    } on ImportClientsFailure catch (error) {
      state = state.copyWith(isParsing: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isParsing: false,
        errorMessage: const ImportUnknownFailure().message,
      );
    }
  }

  Future<void> parseBytes({
    required String fileName,
    required Uint8List bytes,
    String? extension,
  }) async {
    state = state.copyWith(isParsing: true, clearError: true);
    try {
      final spreadsheet = SpreadsheetParser.parse(
        fileName: fileName,
        bytes: bytes,
        extension: extension,
      );
      final mapping = ColumnAutoMapper.detect(spreadsheet.headers);

      state = state.copyWith(
        isParsing: false,
        fileName: fileName,
        spreadsheet: spreadsheet,
        mapping: mapping,
        clearValidation: true,
        clearSummary: true,
        step: ImportStep.mapping,
      );
    } on ImportClientsFailure catch (error) {
      state = state.copyWith(
        isParsing: false,
        clearFile: true,
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        isParsing: false,
        clearFile: true,
        errorMessage: ImportFileInvalidFailure(
          'Não foi possível ler o arquivo: $error',
        ).message,
      );
    }
  }

  void updateMapping(ImportColumnField field, int? headerIndex) {
    final mapping = state.mapping.withExclusive(field, headerIndex);
    state = state.copyWith(
      mapping: mapping,
      clearValidation: true,
      clearError: true,
    );
  }

  void setAuthorizationConfirmed(bool value) {
    state = state.copyWith(authorizationConfirmed: value, clearError: true);
  }

  void goToStep(ImportStep step) {
    if (step == ImportStep.review) {
      _validateForReview();
      return;
    }
    state = state.copyWith(step: step, clearError: true);
  }

  void goNext() {
    switch (state.step) {
      case ImportStep.upload:
        if (state.canGoToMapping) {
          state = state.copyWith(step: ImportStep.mapping, clearError: true);
        }
      case ImportStep.mapping:
        if (state.canGoToReview) {
          _validateForReview();
        } else {
          state = state.copyWith(
            errorMessage: const ImportMappingIncompleteFailure().message,
          );
        }
      case ImportStep.review:
        confirmImport();
      case ImportStep.confirmation:
        break;
    }
  }

  void goBack() {
    switch (state.step) {
      case ImportStep.upload:
        break;
      case ImportStep.mapping:
        state = state.copyWith(step: ImportStep.upload, clearError: true);
      case ImportStep.review:
        state = state.copyWith(step: ImportStep.mapping, clearError: true);
      case ImportStep.confirmation:
        break;
    }
  }

  void reset() {
    state = const ImportClientsState();
  }

  Future<void> _validateForReview() async {
    final spreadsheet = state.spreadsheet;
    if (spreadsheet == null || !state.mapping.isComplete) {
      state = state.copyWith(
        errorMessage: const ImportMappingIncompleteFailure().message,
      );
      return;
    }

    try {
      final templates = await _loadTemplates();
      final defaultTemplate = templates.firstWhere(
        (t) => t.isDefault,
        orElse: () => templates.first,
      );

      // Ensure local client list is fresh for duplicate-phone checks.
      try {
        await ref.read(clientsControllerProvider.notifier).refresh();
      } catch (_) {
        state = state.copyWith(
          errorMessage:
              'Não foi possível atualizar a lista de clientes. '
              'Verifique a conexão e tente novamente.',
        );
        return;
      }

      final validation = ImportPlanLimitApplier.apply(
        validation: ImportRowValidator.validate(
          spreadsheet: spreadsheet,
          mapping: state.mapping,
          templates: templates,
          defaultTemplate: defaultTemplate,
          existingPhoneKeys:
              ref.read(clientsControllerProvider.notifier).existingPhoneKeys,
        ),
        currentClientCount:
            ref.read(clientsControllerProvider.notifier).clientCount,
        maxClients: ImportPlanLimitApplier.maxClientsForPlan(
          isPro: ref.read(currentProfileProvider).valueOrNull?.isPro ?? false,
        ),
      );

      state = state.copyWith(
        validation: validation,
        step: ImportStep.review,
        clearError: true,
        clearSummary: true,
      );
    } on ImportClientsFailure catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        errorMessage: const ImportUnknownFailure().message,
      );
    }
  }

  Future<void> confirmImport() async {
    if (!state.authorizationConfirmed) {
      state = state.copyWith(
        errorMessage:
            'Confirme que você tem autorização desses contatos para receber mensagem.',
      );
      return;
    }
    final validation = state.validation;
    if (validation == null) {
      state = state.copyWith(
        errorMessage: const ImportNoValidRowsFailure().message,
      );
      return;
    }

    state = state.copyWith(isImporting: true, clearError: true);

    try {
      try {
        await ref.read(clientsControllerProvider.notifier).refresh();
      } catch (_) {
        state = state.copyWith(
          isImporting: false,
          errorMessage:
              'Não foi possível atualizar a lista de clientes. '
              'Verifique a conexão e tente novamente.',
        );
        return;
      }

      final limited = ImportPlanLimitApplier.apply(
        validation: validation,
        currentClientCount:
            ref.read(clientsControllerProvider.notifier).clientCount,
        maxClients: ImportPlanLimitApplier.maxClientsForPlan(
          isPro: ref.read(currentProfileProvider).valueOrNull?.isPro ?? false,
        ),
      );

      if (limited.validCount == 0) {
        if (limited.planLimitSkippedCount > 0) {
          ref.read(analyticsServiceProvider).trackLimiteAtingido(
                tipo: LimiteAnalyticsTipo.clientes,
                valorAtual:
                    ref.read(clientsControllerProvider.notifier).clientCount,
              );
        }
        state = state.copyWith(
          isImporting: false,
          errorMessage: limited.planLimitSkippedCount > 0
              ? 'Limite de ${PlanLimits.freeMaxClients} clientes do plano Free '
                  'atingido. Nenhuma linha será importada.'
              : const ImportNoValidRowsFailure().message,
        );
        return;
      }

      final existingKeys =
          ref.read(clientsControllerProvider.notifier).existingPhoneKeys;
      final payload = <
          ({
            String name,
            String phone,
            DateTime birthDate,
            String templateId,
            bool automaticEnabled,
          })>[];
      var skippedNow =
          limited.invalidCount + limited.planLimitSkippedCount;

      for (final row in limited.validRows) {
        final birthDate = row.birthDate;
        final templateId = row.templateId;
        if (birthDate == null || templateId == null || templateId.isEmpty) {
          skippedNow++;
          continue;
        }
        final key = WhatsAppPhone.uniquenessKey(row.phone);
        if (key != null && existingKeys.contains(key)) {
          skippedNow++;
          continue;
        }
        payload.add((
          name: row.name,
          phone: row.phone,
          birthDate: birthDate,
          templateId: templateId,
          automaticEnabled: WhatsAppAutomationUi.showAutomaticControls
              ? row.automaticEnabled
              : false,
        ));
      }

      if (payload.isEmpty) {
        state = state.copyWith(
          isImporting: false,
          errorMessage: const ImportNoValidRowsFailure().message,
        );
        return;
      }

      final created = await ref
          .read(clientsControllerProvider.notifier)
          .createClientsBatch(payload);

      final duranteOnboarding =
          !(ref.read(currentProfileProvider).valueOrNull?.onboardingCompleted ??
              true);
      ref.read(analyticsServiceProvider).trackImportCompleted(
            origem: ImportAnalyticsOrigem.csv,
            quantidade: created.length,
            duranteOnboarding: duranteOnboarding,
          );

      state = state.copyWith(
        isImporting: false,
        summary: ImportSummary(
          imported: created.length,
          skipped: skippedNow,
          errors: 0,
        ),
        step: ImportStep.confirmation,
      );
    } on ClientsFailure catch (error) {
      state = state.copyWith(
        isImporting: false,
        summary: ImportSummary(
          imported: 0,
          skipped: validation.invalidCount + validation.planLimitSkippedCount,
          errors: validation.validCount,
          errorMessage: error.message,
        ),
        step: ImportStep.confirmation,
      );
    } on ImportClientsFailure catch (error) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isImporting: false,
        summary: ImportSummary(
          imported: 0,
          skipped: validation.invalidCount + validation.planLimitSkippedCount,
          errors: validation.validCount,
          errorMessage: const ImportUnknownFailure().message,
        ),
        step: ImportStep.confirmation,
      );
    }
  }

  Future<List<TemplateSummary>> _loadTemplates() async {
    final repository = ref.read(templatesRepositoryProvider);
    if (repository == null) {
      throw const ImportNotReadyFailure();
    }
    await repository.ensureDefaultTemplate();
    final summaries = await repository.listSummaries();
    if (summaries.isEmpty) {
      throw const ImportNotReadyFailure(
        'Nenhum template disponível. Crie um template padrão primeiro.',
      );
    }
    return summaries;
  }
}
