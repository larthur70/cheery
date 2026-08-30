import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'whatsapp_connection.freezed.dart';

@freezed
abstract class WhatsAppConnection with _$WhatsAppConnection {
  const WhatsAppConnection._();

  const factory WhatsAppConnection({
    @Default(false) bool connected,
    @Default(WhatsAppIntegrationStatus.disconnected)
    WhatsAppIntegrationStatus status,
    String? displayPhone,
    DateTime? connectedAt,
    String? lastError,
  }) = _WhatsAppConnection;

  static const disconnected = WhatsAppConnection();

  bool get isReady => connected && status.isConnected;
}
