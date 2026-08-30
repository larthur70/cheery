import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection.dart';

/// Contract for WhatsApp Business connection via edge functions.
abstract class WhatsAppConnectionRepository {
  /// Starts Embedded Signup; returns a URL to open in the browser.
  Future<Uri> startConnect();

  /// Completes OAuth after redirect (code / embedded signup payload).
  Future<WhatsAppConnection> completeConnect({
    String? code,
    String? phoneNumberId,
    String? wabaId,
    String? displayPhone,
  });

  Future<WhatsAppConnection> disconnect();

  Future<WhatsAppConnection> refreshStatus();
}
