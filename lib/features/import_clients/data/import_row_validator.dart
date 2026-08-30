import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/import_clients/domain/column_mapping.dart';
import 'package:cheery/features/import_clients/domain/import_row_draft.dart';
import 'package:cheery/features/import_clients/domain/import_validation_result.dart';
import 'package:cheery/features/import_clients/domain/parsed_spreadsheet.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_rules.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:intl/intl.dart';

/// Validates mapped spreadsheet rows for import.
abstract final class ImportRowValidator {
  static final _ddMMyyyy = DateFormat('dd/MM/yyyy');
  static final _yyyyMMdd = DateFormat('yyyy-MM-dd');
  static final _ddMMyy = DateFormat('dd/MM/yy');

  static ImportValidationResult validate({
    required ParsedSpreadsheet spreadsheet,
    required ColumnMapping mapping,
    required List<TemplateSummary> templates,
    required TemplateSummary defaultTemplate,
    Set<String> existingPhoneKeys = const {},
  }) {
    final templateByName = <String, TemplateSummary>{};
    for (final template in templates) {
      templateByName[_normalizeKey(template.name)] = template;
    }

    final drafts = <ImportRowDraft>[];
    for (var i = 0; i < spreadsheet.rows.length; i++) {
      final row = spreadsheet.rows[i];
      drafts.add(
        _validateRow(
          rowNumber: i + 2,
          row: row,
          mapping: mapping,
          templateByName: templateByName,
          defaultTemplate: defaultTemplate,
        ),
      );
    }

    return ImportValidationResult(
      rows: _applyDuplicatePhoneErrors(
        drafts,
        existingPhoneKeys: existingPhoneKeys,
      ),
    );
  }

  /// Marks file-internal and vs-existing phone collisions as row errors.
  static List<ImportRowDraft> _applyDuplicatePhoneErrors(
    List<ImportRowDraft> drafts, {
    required Set<String> existingPhoneKeys,
  }) {
    final firstRowByKey = <String, int>{};
    final duplicateKeysInFile = <String>{};

    for (final draft in drafts) {
      final key = WhatsAppPhone.uniquenessKey(draft.phone);
      if (key == null) continue;
      final previous = firstRowByKey[key];
      if (previous == null) {
        firstRowByKey[key] = draft.rowNumber;
      } else {
        duplicateKeysInFile.add(key);
      }
    }

    return drafts.map((draft) {
      final key = WhatsAppPhone.uniquenessKey(draft.phone);
      if (key == null) return draft;

      final errors = List<String>.from(draft.errors);
      var phoneHasError = draft.phoneHasError;

      if (duplicateKeysInFile.contains(key) &&
          draft.rowNumber != firstRowByKey[key]) {
        errors.add(
          'Telefone duplicado na planilha (linha ${firstRowByKey[key]})',
        );
        phoneHasError = true;
      } else if (existingPhoneKeys.contains(key)) {
        errors.add('Telefone já cadastrado');
        phoneHasError = true;
      }

      if (errors.length == draft.errors.length) return draft;
      return draft.copyWith(errors: errors, phoneHasError: phoneHasError);
    }).toList();
  }

  static ImportRowDraft _validateRow({
    required int rowNumber,
    required List<String> row,
    required ColumnMapping mapping,
    required Map<String, TemplateSummary> templateByName,
    required TemplateSummary defaultTemplate,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    var nameHasError = false;
    var phoneHasError = false;
    var birthDateHasError = false;
    var usedFallbackTemplate = false;

    final name = _cell(row, mapping.nameIndex).trim();
    final phoneRaw = _cell(row, mapping.phoneIndex).trim();
    final birthRaw = _cell(row, mapping.birthDateIndex).trim();
    final templateRaw = _cell(row, mapping.templateIndex).trim();
    final automaticRaw = _cell(row, mapping.automaticIndex).trim();

    var automaticEnabled = false;
    if (WhatsAppAutomationUi.showAutomaticControls) {
      try {
        final parsed = WhatsAppAutomationRules.parseAutomaticCell(automaticRaw);
        automaticEnabled = parsed ?? false;
      } on FormatException {
        errors.add('Automático inválido (use Sim ou Não)');
      }
    }

    if (name.isEmpty) {
      errors.add('Nome obrigatório');
      nameHasError = true;
    }

    String phone = phoneRaw;
    final normalized = WhatsAppPhone.normalize(phoneRaw);
    if (normalized == null) {
      errors.add('Telefone inválido');
      phoneHasError = true;
    } else {
      phone = _toStoredPhone(normalized);
    }

    DateTime? birthDate;
    if (birthRaw.isEmpty) {
      errors.add('Data de aniversário obrigatória');
      birthDateHasError = true;
    } else {
      birthDate = parseBirthDate(birthRaw);
      if (birthDate == null) {
        errors.add('Data inválida');
        birthDateHasError = true;
      } else if (birthDate.isAfter(DateTime.now())) {
        errors.add('Data inválida');
        birthDate = null;
        birthDateHasError = true;
      }
    }

    String? templateId = defaultTemplate.id;
    String? templateName = defaultTemplate.name;
    TemplateSummary? matchedTemplate;

    if (templateRaw.isNotEmpty) {
      matchedTemplate = templateByName[_normalizeKey(templateRaw)];
      if (matchedTemplate == null) {
        if (automaticEnabled) {
          errors.add('Template "$templateRaw" não encontrado');
        } else {
          usedFallbackTemplate = true;
          templateId = defaultTemplate.id;
          templateName = defaultTemplate.name;
          matchedTemplate = defaultTemplate;
          warnings.add(
            'Template "$templateRaw" não encontrado — será usado '
            '"${defaultTemplate.name}"',
          );
        }
      } else {
        templateId = matchedTemplate.id;
        templateName = matchedTemplate.name;
      }
    } else {
      matchedTemplate = defaultTemplate;
    }

    if (automaticEnabled && matchedTemplate != null) {
      if (!matchedTemplate.approvalStatus.isApproved) {
        errors.add(
          'Template "${matchedTemplate.name}" precisa estar aprovado pela Meta '
          'para Automático = Sim',
        );
      }
    }

    return ImportRowDraft(
      rowNumber: rowNumber,
      name: name,
      phone: phone,
      birthDateRaw: birthRaw,
      templateRaw: templateRaw,
      automaticRaw: automaticRaw,
      birthDate: birthDate,
      templateId: templateId,
      templateName: templateName,
      automaticEnabled: automaticEnabled,
      errors: errors,
      warnings: warnings,
      nameHasError: nameHasError,
      phoneHasError: phoneHasError,
      birthDateHasError: birthDateHasError,
      usedFallbackTemplate: usedFallbackTemplate,
    );
  }

  static String _cell(List<String> row, int? index) {
    if (index == null || index < 0 || index >= row.length) return '';
    return row[index];
  }

  static String _normalizeKey(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Stores phone like the client form (Brazilian mask, without country code).
  static String _toStoredPhone(String e164Digits) {
    var digits = e164Digits;
    if (digits.startsWith('55') &&
        (digits.length == 12 || digits.length == 13)) {
      digits = digits.substring(2);
    }
    return formatBrazilianPhone(digits);
  }

  /// Parses common date formats and Excel serial day numbers.
  static DateTime? parseBirthDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final asSerial = double.tryParse(trimmed.replaceAll(',', '.'));
    if (asSerial != null && asSerial > 20000 && asSerial < 80000) {
      // Excel serial date: days since 1899-12-30 (Windows/1900 system).
      final epoch = DateTime(1899, 12, 30);
      final date = epoch.add(Duration(days: asSerial.floor()));
      return DateTime(date.year, date.month, date.day);
    }

    for (final format in [_ddMMyyyy, _yyyyMMdd]) {
      try {
        final parsed = format.parseStrict(trimmed);
        return DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {}
    }

    // Two-digit years are ambiguous — only accept when the result falls in
    // a sensible birth-year window (1920 … current year).
    try {
      final parsed = _ddMMyy.parseStrict(trimmed);
      final candidate = DateTime(parsed.year, parsed.month, parsed.day);
      final now = DateTime.now();
      if (candidate.year >= 1920 && !candidate.isAfter(now)) {
        return candidate;
      }
    } catch (_) {}

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    return null;
  }
}
