import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';

/// Contract for template persistence.
abstract class TemplatesRepository {
  Future<List<Template>> listTemplates();

  Future<List<TemplateSummary>> listSummaries();

  Future<Template> getById(String id);

  Future<TemplateSummary> getDefaultTemplate();

  /// Ensures the signed-in user has a default template (backfill safety net).
  Future<TemplateSummary> ensureDefaultTemplate();

  Future<Template> createTemplate({
    required String name,
    required String message,
    required List<String> variables,
  });

  Future<Template> updateTemplate({
    required String id,
    required String name,
    required String message,
    required List<String> variables,
  });

  Future<void> deleteTemplate(String id);

  /// Submits the template to Meta for approval via edge function.
  Future<Template> submitForApproval(String id);

  /// Polls Meta for the latest approval status.
  Future<Template> syncApprovalStatus(String id);
}
