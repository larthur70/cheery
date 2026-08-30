/// A single mapped spreadsheet row ready for review / import.
class ImportRowDraft {
  const ImportRowDraft({
    required this.rowNumber,
    required this.name,
    required this.phone,
    required this.birthDateRaw,
    required this.templateRaw,
    this.automaticRaw = '',
    this.birthDate,
    this.templateId,
    this.templateName,
    this.automaticEnabled = false,
    this.errors = const [],
    this.warnings = const [],
    this.nameHasError = false,
    this.phoneHasError = false,
    this.birthDateHasError = false,
    this.usedFallbackTemplate = false,
    this.skippedForPlanLimit = false,
  });

  /// 1-based spreadsheet row (header is row 1).
  final int rowNumber;
  final String name;
  final String phone;
  final String birthDateRaw;
  final String templateRaw;
  final String automaticRaw;
  final DateTime? birthDate;
  final String? templateId;
  final String? templateName;
  final bool automaticEnabled;

  /// Blocking issues — row will be skipped on import.
  final List<String> errors;

  /// Non-blocking notices (e.g. template fallback).
  final List<String> warnings;

  final bool nameHasError;
  final bool phoneHasError;
  final bool birthDateHasError;

  /// True when the spreadsheet template was missing and default was applied.
  final bool usedFallbackTemplate;

  /// True when the row is otherwise valid but exceeds Free plan capacity.
  final bool skippedForPlanLimit;

  bool get isValid => errors.isEmpty;

  /// Ready to import (valid fields and within plan capacity).
  bool get willImport => isValid && !skippedForPlanLimit;

  bool get hasWarnings => warnings.isNotEmpty;

  static const planLimitSkipMessage =
      'Não será importado: limite de clientes do plano Free';

  ImportRowDraft copyWith({
    List<String>? errors,
    List<String>? warnings,
    bool? nameHasError,
    bool? phoneHasError,
    bool? birthDateHasError,
    bool? skippedForPlanLimit,
  }) {
    return ImportRowDraft(
      rowNumber: rowNumber,
      name: name,
      phone: phone,
      birthDateRaw: birthDateRaw,
      templateRaw: templateRaw,
      automaticRaw: automaticRaw,
      birthDate: birthDate,
      templateId: templateId,
      templateName: templateName,
      automaticEnabled: automaticEnabled,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      nameHasError: nameHasError ?? this.nameHasError,
      phoneHasError: phoneHasError ?? this.phoneHasError,
      birthDateHasError: birthDateHasError ?? this.birthDateHasError,
      usedFallbackTemplate: usedFallbackTemplate,
      skippedForPlanLimit: skippedForPlanLimit ?? this.skippedForPlanLimit,
    );
  }
}
