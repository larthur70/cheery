import 'package:cheery/features/import_clients/domain/column_mapping.dart';
import 'package:cheery/features/import_clients/domain/import_column_field.dart';

/// Detects common spreadsheet headers and builds a [ColumnMapping].
abstract final class ColumnAutoMapper {
  /// Keys are accent-stripped and lowercased (see [_normalize]).
  static const Map<ImportColumnField, Set<String>> _synonyms = {
    ImportColumnField.name: {
      'nome',
      'cliente',
      'name',
      'customer',
      'nome do cliente',
      'nome completo',
      'full name',
    },
    ImportColumnField.phone: {
      'telefone',
      'whatsapp',
      'celular',
      'phone',
      'fone',
      'tel',
      'mobile',
      'cell',
      'numero',
      'telefone celular',
      'whats',
    },
    ImportColumnField.birthDate: {
      'aniversario',
      'data de aniversario',
      'nascimento',
      'data de nascimento',
      'birth',
      'birthday',
      'birthdate',
      'birth date',
      'date of birth',
      'dob',
      'data aniversario',
    },
    ImportColumnField.template: {
      'template',
      'mensagem',
      'modelo',
      'template de mensagem',
      'nome do template',
      'message template',
    },
    ImportColumnField.automatic: {
      'automatico',
      'automatic',
      'auto',
      'envio automatico',
      'automacao',
    },
  };

  static ColumnMapping detect(List<String> headers) {
    int? name;
    int? phone;
    int? birth;
    int? template;
    int? automatic;

    for (var i = 0; i < headers.length; i++) {
      final normalized = _normalize(headers[i]);
      if (normalized.isEmpty) continue;

      final field = _matchField(normalized);
      if (field == null) continue;

      switch (field) {
        case ImportColumnField.name:
          name ??= i;
        case ImportColumnField.phone:
          phone ??= i;
        case ImportColumnField.birthDate:
          birth ??= i;
        case ImportColumnField.template:
          template ??= i;
        case ImportColumnField.automatic:
          automatic ??= i;
      }
    }

    return ColumnMapping(
      nameIndex: name,
      phoneIndex: phone,
      birthDateIndex: birth,
      templateIndex: template,
      automaticIndex: automatic,
    );
  }

  static ImportColumnField? _matchField(String normalized) {
    for (final entry in _synonyms.entries) {
      if (entry.value.contains(normalized)) return entry.key;
    }
    return null;
  }

  static String _normalize(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
