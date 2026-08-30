/// Fixed catalog of friendly template variables mapped to Meta keys.
abstract final class TemplateVariableCatalog {
  static const String clientNameKey = 'client_name';
  static const String companyNameKey = 'company_name';

  static const String clientNameToken = '[Nome do cliente]';
  static const String companyNameToken = '[Nome da empresa]';

  static const List<TemplateVariableDef> all = [
    TemplateVariableDef(
      key: clientNameKey,
      token: clientNameToken,
      sampleValue: 'João',
    ),
    TemplateVariableDef(
      key: companyNameKey,
      token: companyNameToken,
      sampleValue: 'Minha Empresa',
    ),
  ];

  static final Map<String, TemplateVariableDef> byKey = {
    for (final def in all) def.key: def,
  };

  static final Map<String, TemplateVariableDef> byToken = {
    for (final def in all) def.token: def,
  };

  static final RegExp friendlyTokenPattern = RegExp(
    r'\[(?:Nome do cliente|Nome da empresa)\]',
  );

  /// Matches any `[...]` bracket token (known or unknown).
  static final RegExp anyBracketPattern = RegExp(r'\[[^\]]+\]');

  static final RegExp metaPlaceholderPattern = RegExp(r'\{\{(\d+)\}\}');
}

class TemplateVariableDef {
  const TemplateVariableDef({
    required this.key,
    required this.token,
    required this.sampleValue,
  });

  final String key;
  final String token;
  final String sampleValue;
}
