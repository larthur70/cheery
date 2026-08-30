import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';

/// Fills a birthday template with client and company values.
abstract final class BirthdayMessageComposer {
  static String compose({
    required Template template,
    required String clientName,
    required String companyName,
  }) {
    return TemplateBodyConverter.fill(
      template.message,
      template.variables,
      {
        TemplateVariableCatalog.clientNameKey: clientName,
        TemplateVariableCatalog.companyNameKey: companyName,
      },
    );
  }

  /// Map of friendly token → resolved value for insert chips in the preview.
  static Map<String, String> variableInserts({
    required Template template,
    required String clientName,
    required String companyName,
  }) {
    final values = <String, String>{
      TemplateVariableCatalog.clientNameKey: clientName,
      TemplateVariableCatalog.companyNameKey: companyName,
    };

    return {
      for (final key in template.variables)
        if (TemplateVariableCatalog.byKey[key] != null)
          TemplateVariableCatalog.byKey[key]!.token: values[key] ?? '',
    };
  }
}
