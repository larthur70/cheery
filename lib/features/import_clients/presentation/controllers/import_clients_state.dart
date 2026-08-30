import 'package:cheery/features/import_clients/domain/column_mapping.dart';
import 'package:cheery/features/import_clients/domain/import_step.dart';
import 'package:cheery/features/import_clients/domain/import_summary.dart';
import 'package:cheery/features/import_clients/domain/import_validation_result.dart';
import 'package:cheery/features/import_clients/domain/parsed_spreadsheet.dart';

class ImportClientsState {
  const ImportClientsState({
    this.step = ImportStep.upload,
    this.fileName,
    this.spreadsheet,
    this.mapping = const ColumnMapping(),
    this.validation,
    this.summary,
    this.isParsing = false,
    this.isImporting = false,
    this.authorizationConfirmed = false,
    this.errorMessage,
  });

  final ImportStep step;
  final String? fileName;
  final ParsedSpreadsheet? spreadsheet;
  final ColumnMapping mapping;
  final ImportValidationResult? validation;
  final ImportSummary? summary;
  final bool isParsing;
  final bool isImporting;
  final bool authorizationConfirmed;
  final String? errorMessage;

  bool get hasFile => spreadsheet != null;

  bool get canGoToMapping => spreadsheet != null && !isParsing;

  bool get canGoToReview => mapping.isComplete;

  bool get canImport =>
      validation != null &&
      validation!.validCount > 0 &&
      authorizationConfirmed &&
      !isImporting;

  ImportClientsState copyWith({
    ImportStep? step,
    String? fileName,
    ParsedSpreadsheet? spreadsheet,
    ColumnMapping? mapping,
    ImportValidationResult? validation,
    ImportSummary? summary,
    bool? isParsing,
    bool? isImporting,
    bool? authorizationConfirmed,
    String? errorMessage,
    bool clearFile = false,
    bool clearValidation = false,
    bool clearSummary = false,
    bool clearError = false,
  }) {
    return ImportClientsState(
      step: step ?? this.step,
      fileName: clearFile ? null : (fileName ?? this.fileName),
      spreadsheet: clearFile ? null : (spreadsheet ?? this.spreadsheet),
      mapping: clearFile ? const ColumnMapping() : (mapping ?? this.mapping),
      validation: clearFile || clearValidation
          ? null
          : (validation ?? this.validation),
      summary: clearFile || clearSummary ? null : (summary ?? this.summary),
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      authorizationConfirmed: clearFile || clearValidation
          ? false
          : (authorizationConfirmed ?? this.authorizationConfirmed),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
