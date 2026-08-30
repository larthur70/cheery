import 'package:cheery/features/templates/domain/template_variable_catalog.dart';

/// Result of converting a friendly UI body to Meta storage format.
class TemplateMetaConversion {
  const TemplateMetaConversion({
    required this.message,
    required this.variables,
  });

  /// Body with Meta placeholders (`{{1}}`, `{{2}}`, …).
  final String message;

  /// Ordered unique variable keys matching placeholder indices.
  final List<String> variables;
}

/// Converts between friendly `[Nome do cliente]` tokens and Meta `{{n}}`.
abstract final class TemplateBodyConverter {
  static const int maxMessageLength = 1024;

  /// Converts friendly body → Meta message + ordered variables.
  ///
  /// Throws [FormatException] when unknown `[...]` tokens are present.
  static TemplateMetaConversion toMeta(String friendlyBody) {
    final unknown = <String>[];
    for (final match in TemplateVariableCatalog.anyBracketPattern.allMatches(
      friendlyBody,
    )) {
      final token = match.group(0)!;
      if (!TemplateVariableCatalog.byToken.containsKey(token)) {
        unknown.add(token);
      }
    }
    if (unknown.isNotEmpty) {
      throw FormatException(
        'Variáveis desconhecidas: ${unknown.toSet().join(', ')}',
      );
    }

    final variables = <String>[];
    final keyToIndex = <String, int>{};

    final message = friendlyBody.replaceAllMapped(
      TemplateVariableCatalog.friendlyTokenPattern,
      (match) {
        final token = match.group(0)!;
        final def = TemplateVariableCatalog.byToken[token]!;
        final existing = keyToIndex[def.key];
        if (existing != null) {
          return '{{$existing}}';
        }
        final index = variables.length + 1;
        variables.add(def.key);
        keyToIndex[def.key] = index;
        return '{{$index}}';
      },
    );

    return TemplateMetaConversion(message: message, variables: variables);
  }

  /// Converts Meta message + variables → friendly UI body.
  static String toFriendly(String metaBody, List<String> variables) {
    return metaBody.replaceAllMapped(
      TemplateVariableCatalog.metaPlaceholderPattern,
      (match) {
        final index = int.parse(match.group(1)!);
        if (index < 1 || index > variables.length) {
          return match.group(0)!;
        }
        final key = variables[index - 1];
        final def = TemplateVariableCatalog.byKey[key];
        return def?.token ?? match.group(0)!;
      },
    );
  }

  /// Fills Meta placeholders using [values] keyed by variable key.
  static String fill(
    String metaBody,
    List<String> variables,
    Map<String, String> values,
  ) {
    return metaBody.replaceAllMapped(
      TemplateVariableCatalog.metaPlaceholderPattern,
      (match) {
        final index = int.parse(match.group(1)!);
        if (index < 1 || index > variables.length) {
          return match.group(0)!;
        }
        final key = variables[index - 1];
        return values[key] ?? '';
      },
    );
  }

  /// Preview with sample (or override) values from the catalog.
  static String preview(
    String metaBody,
    List<String> variables, {
    Map<String, String>? sampleOverrides,
  }) {
    final samples = <String, String>{
      for (final def in TemplateVariableCatalog.all) def.key: def.sampleValue,
      ...?sampleOverrides,
    };
    return fill(metaBody, variables, samples);
  }

  /// Live preview from a friendly body currently being edited.
  static String previewFriendly(
    String friendlyBody, {
    Map<String, String>? sampleOverrides,
  }) {
    try {
      final meta = toMeta(friendlyBody);
      return preview(
        meta.message,
        meta.variables,
        sampleOverrides: sampleOverrides,
      );
    } on FormatException {
      return friendlyBody;
    }
  }
}
