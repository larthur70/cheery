import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateBodyConverter', () {
    test('converts friendly tokens to Meta placeholders in order', () {
      const friendly =
          'Olá [Nome do cliente]! Equipe [Nome da empresa] agradece.';

      final meta = TemplateBodyConverter.toMeta(friendly);

      expect(meta.message, 'Olá {{1}}! Equipe {{2}} agradece.');
      expect(meta.variables, ['client_name', 'company_name']);
    });

    test('reuses the same index when a token repeats', () {
      const friendly =
          'Oi [Nome do cliente], de novo [Nome do cliente]!';

      final meta = TemplateBodyConverter.toMeta(friendly);

      expect(meta.message, 'Oi {{1}}, de novo {{1}}!');
      expect(meta.variables, ['client_name']);
    });

    test('round-trips Meta body back to friendly tokens', () {
      const message = 'Olá {{1}}! — {{2}}';
      const variables = ['client_name', 'company_name'];

      final friendly = TemplateBodyConverter.toFriendly(message, variables);

      expect(
        friendly,
        'Olá [Nome do cliente]! — [Nome da empresa]',
      );
    });

    test('fills placeholders using variable order', () {
      const message = 'Olá {{1}}! Equipe {{2}}.';
      const variables = ['client_name', 'company_name'];

      final filled = TemplateBodyConverter.fill(
        message,
        variables,
        {
          TemplateVariableCatalog.clientNameKey: 'Maria',
          TemplateVariableCatalog.companyNameKey: 'Doce Aroma',
        },
      );

      expect(filled, 'Olá Maria! Equipe Doce Aroma.');
    });

    test('rejects unknown bracket tokens', () {
      expect(
        () => TemplateBodyConverter.toMeta('Oi [Cargo]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('previewFriendly substitutes sample values', () {
      final preview = TemplateBodyConverter.previewFriendly(
        'Olá [Nome do cliente] da [Nome da empresa]',
      );

      expect(preview, 'Olá João da Minha Empresa');
    });
  });
}
