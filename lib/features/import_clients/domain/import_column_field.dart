import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';

/// Spreadsheet columns that can be mapped to client fields.
enum ImportColumnField {
  name,
  phone,
  birthDate,
  template,
  automatic,
}

extension ImportColumnFieldLabel on ImportColumnField {
  String get label => switch (this) {
        ImportColumnField.name => 'Nome',
        ImportColumnField.phone => 'Telefone',
        ImportColumnField.birthDate => 'Data de aniversário',
        ImportColumnField.template => 'Template',
        ImportColumnField.automatic => 'Automático',
      };

  bool get isRequired =>
      this != ImportColumnField.template && this != ImportColumnField.automatic;

  /// Fields shown in the mapping step UI.
  static List<ImportColumnField> get visibleForMapping => [
        for (final field in ImportColumnField.values)
          if (field != ImportColumnField.automatic ||
              WhatsAppAutomationUi.showAutomaticControls)
            field,
      ];
}
