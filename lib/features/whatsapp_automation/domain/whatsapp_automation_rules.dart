import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';

/// Pure rules for WhatsApp automation (testable, no Flutter/Supabase).
abstract final class WhatsAppAutomationRules {
  static bool canEnableAutomatic({
    required bool isPro,
    required bool whatsappConnected,
    required WhatsAppIntegrationStatus status,
    required TemplateApprovalStatus? templateStatus,
  }) {
    if (!isPro) return false;
    if (!whatsappConnected || !status.isConnected) return false;
    return templateStatus?.isApproved ?? false;
  }

  static String? validateAutomaticClient({
    required bool automaticEnabled,
    required bool isPro,
    required bool whatsappConnected,
    required WhatsAppIntegrationStatus status,
    required TemplateApprovalStatus? templateStatus,
  }) {
    if (!automaticEnabled) return null;
    if (!isPro) {
      return 'Automação WhatsApp Business em breve.';
    }
    if (!whatsappConnected || !status.isConnected) {
      return 'Conecte o WhatsApp Business antes de ativar a automação.';
    }
    if (templateStatus == null || !templateStatus.isApproved) {
      return 'Para automação, escolha um template aprovado pela Meta.';
    }
    return null;
  }

  /// Parses spreadsheet Automático column. Null means "use default true".
  /// Throws [FormatException] for invalid values.
  static bool? parseAutomaticCell(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final key = trimmed.toLowerCase();
    const truthy = {'sim', 's', 'yes', 'y', '1', 'true', 'verdadeiro'};
    const falsy = {'nao', 'não', 'n', 'no', '0', 'false', 'falso'};

    if (truthy.contains(key)) return true;
    if (falsy.contains(key)) return false;

    // Accent-stripped "nao"
    final normalized = key
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a');
    if (normalized == 'nao') return false;

    throw FormatException('Valor inválido para Automático: "$raw"');
  }
}
