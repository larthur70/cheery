/// Common IANA timezones for the MVP settings picker.
abstract final class ReminderTimezones {
  static const String defaultId = 'America/Sao_Paulo';

  static const List<({String id, String label})> options = [
    (id: 'America/Sao_Paulo', label: 'Brasília (São Paulo)'),
    (id: 'America/Manaus', label: 'Manaus'),
    (id: 'America/Belem', label: 'Belém'),
    (id: 'America/Fortaleza', label: 'Fortaleza'),
    (id: 'America/Recife', label: 'Recife'),
    (id: 'America/Bahia', label: 'Bahia'),
    (id: 'America/Cuiaba', label: 'Cuiabá'),
    (id: 'America/Porto_Velho', label: 'Porto Velho'),
    (id: 'America/Rio_Branco', label: 'Rio Branco'),
    (id: 'America/Noronha', label: 'Fernando de Noronha'),
  ];
}
