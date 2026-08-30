/// WhatsApp Business integration connection status on the profile.
enum WhatsAppIntegrationStatus {
  disconnected,
  connecting,
  connected,
  error,
  needsReauth;

  static WhatsAppIntegrationStatus fromJson(String? raw) {
    return switch (raw) {
      'connecting' => WhatsAppIntegrationStatus.connecting,
      'connected' => WhatsAppIntegrationStatus.connected,
      'error' => WhatsAppIntegrationStatus.error,
      'needs_reauth' => WhatsAppIntegrationStatus.needsReauth,
      _ => WhatsAppIntegrationStatus.disconnected,
    };
  }

  String toJson() => switch (this) {
        WhatsAppIntegrationStatus.disconnected => 'disconnected',
        WhatsAppIntegrationStatus.connecting => 'connecting',
        WhatsAppIntegrationStatus.connected => 'connected',
        WhatsAppIntegrationStatus.error => 'error',
        WhatsAppIntegrationStatus.needsReauth => 'needs_reauth',
      };

  String get label => switch (this) {
        WhatsAppIntegrationStatus.disconnected => 'Desconectado',
        WhatsAppIntegrationStatus.connecting => 'Conectando…',
        WhatsAppIntegrationStatus.connected => 'Conectado',
        WhatsAppIntegrationStatus.error => 'Erro na conexão',
        WhatsAppIntegrationStatus.needsReauth => 'Reautenticação necessária',
      };

  bool get isConnected => this == WhatsAppIntegrationStatus.connected;
}

WhatsAppIntegrationStatus whatsAppIntegrationStatusFromJson(Object? json) =>
    WhatsAppIntegrationStatus.fromJson(json as String?);

String whatsAppIntegrationStatusToJson(WhatsAppIntegrationStatus status) =>
    status.toJson();
