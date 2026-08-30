import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_rules.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppAutomationRules.parseAutomaticCell', () {
    test('null/empty defaults to null (caller uses true)', () {
      expect(WhatsAppAutomationRules.parseAutomaticCell(null), isNull);
      expect(WhatsAppAutomationRules.parseAutomaticCell(''), isNull);
      expect(WhatsAppAutomationRules.parseAutomaticCell('  '), isNull);
    });

    test('parses truthy values', () {
      for (final value in ['Sim', 'S', 'yes', '1', 'TRUE', 'verdadeiro']) {
        expect(
          WhatsAppAutomationRules.parseAutomaticCell(value),
          isTrue,
          reason: value,
        );
      }
    });

    test('parses falsy values including Não', () {
      for (final value in ['Não', 'Nao', 'n', 'no', '0', 'false']) {
        expect(
          WhatsAppAutomationRules.parseAutomaticCell(value),
          isFalse,
          reason: value,
        );
      }
    });

    test('throws on invalid value', () {
      expect(
        () => WhatsAppAutomationRules.parseAutomaticCell('talvez'),
        throwsFormatException,
      );
    });
  });

  group('WhatsAppAutomationRules.validateAutomaticClient', () {
    test('allows when automatic is off', () {
      expect(
        WhatsAppAutomationRules.validateAutomaticClient(
          automaticEnabled: false,
          isPro: false,
          whatsappConnected: false,
          status: WhatsAppIntegrationStatus.disconnected,
          templateStatus: TemplateApprovalStatus.draft,
        ),
        isNull,
      );
    });

    test('requires pro, connected, and approved template', () {
      expect(
        WhatsAppAutomationRules.validateAutomaticClient(
          automaticEnabled: true,
          isPro: true,
          whatsappConnected: true,
          status: WhatsAppIntegrationStatus.connected,
          templateStatus: TemplateApprovalStatus.approved,
        ),
        isNull,
      );

      expect(
        WhatsAppAutomationRules.validateAutomaticClient(
          automaticEnabled: true,
          isPro: false,
          whatsappConnected: true,
          status: WhatsAppIntegrationStatus.connected,
          templateStatus: TemplateApprovalStatus.approved,
        ),
        isNotNull,
      );

      expect(
        WhatsAppAutomationRules.validateAutomaticClient(
          automaticEnabled: true,
          isPro: true,
          whatsappConnected: false,
          status: WhatsAppIntegrationStatus.disconnected,
          templateStatus: TemplateApprovalStatus.approved,
        ),
        isNotNull,
      );

      expect(
        WhatsAppAutomationRules.validateAutomaticClient(
          automaticEnabled: true,
          isPro: true,
          whatsappConnected: true,
          status: WhatsAppIntegrationStatus.connected,
          templateStatus: TemplateApprovalStatus.draft,
        ),
        isNotNull,
      );
    });
  });
}
