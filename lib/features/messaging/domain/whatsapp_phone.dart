/// Normalizes Brazilian phone numbers for WhatsApp `wa.me` links.
abstract final class WhatsAppPhone {
  /// Returns E.164-style digits (`55` + DDD + number) or `null` if invalid.
  static String? normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (digits.startsWith('55') &&
        (digits.length == 12 || digits.length == 13)) {
      return digits;
    }

    if (digits.length == 10 || digits.length == 11) {
      return '55$digits';
    }

    return null;
  }

  /// Stable key for duplicate detection across formats
  /// (`11987654321`, `(11) 98765-4321`, `5511987654321`).
  static String? uniquenessKey(String raw) => normalize(raw);
}
