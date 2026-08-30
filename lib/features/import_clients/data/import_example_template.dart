import 'dart:convert';
import 'dart:typed_data';

/// Sample CSV used as a downloadable import template.
abstract final class ImportExampleTemplate {
  static const String fileName = 'cheery_clientes_modelo.csv';

  static const String csvContent =
      'Nome,Telefone,Data de aniversário,Template\n'
      'Maria Silva,(11) 98765-4321,15/03/1990,\n'
      'João Santos,(21) 99876-5432,22/07/1985,Mensagem padrão\n';

  // When WhatsAppAutomationUi.showAutomaticControls is true again, restore:
  // 'Nome,Telefone,Data de aniversário,Template,Automático\n'
  // '... ,Sim\n' / '... ,Não\n'

  static Uint8List get bytes => Uint8List.fromList(utf8.encode(csvContent));
}
