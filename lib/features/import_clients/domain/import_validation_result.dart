import 'package:cheery/features/import_clients/domain/import_row_draft.dart';

class ImportValidationResult {
  const ImportValidationResult({
    required this.rows,
  });

  final List<ImportRowDraft> rows;

  /// Rows that will actually be imported.
  List<ImportRowDraft> get validRows =>
      rows.where((row) => row.willImport).toList();

  /// Field/validation errors (not plan-limit skips).
  List<ImportRowDraft> get invalidRows =>
      rows.where((row) => !row.isValid).toList();

  /// Valid rows skipped because Free plan client capacity is full.
  List<ImportRowDraft> get planLimitSkippedRows =>
      rows.where((row) => row.skippedForPlanLimit).toList();

  List<ImportRowDraft> get warningRows => rows
      .where((row) => row.willImport && row.hasWarnings)
      .toList();

  int get validCount => validRows.length;
  int get invalidCount => invalidRows.length;
  int get planLimitSkippedCount => planLimitSkippedRows.length;
  int get warningCount => warningRows.length;
  int get totalCount => rows.length;
}
