import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';

/// Builds `https://wa.me/...` URIs for opening WhatsApp with a prefilled message.
abstract final class WhatsAppLinkBuilder {
  /// Returns a `wa.me` [Uri], or `null` when [phone] cannot be normalized.
  static Uri? build({
    required String phone,
    required String message,
  }) {
    final normalized = WhatsAppPhone.normalize(phone);
    if (normalized == null) return null;

    return Uri.https(
      'wa.me',
      '/$normalized',
      {'text': message},
    );
  }
}
