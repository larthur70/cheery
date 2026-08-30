/// Typed failures for birthday reminder / push operations.
sealed class NotificationFailure implements Exception {
  const NotificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NotificationNotReadyFailure extends NotificationFailure {
  const NotificationNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class NotificationPermissionFailure extends NotificationFailure {
  const NotificationPermissionFailure([
    super.message =
        'Permissão de notificações negada. Ative nas configurações do dispositivo.',
  ]);
}

final class NotificationUnsupportedFailure extends NotificationFailure {
  const NotificationUnsupportedFailure([
    super.message =
        'Notificações push estão disponíveis apenas no app iOS/Android.',
  ]);
}

final class NotificationNetworkFailure extends NotificationFailure {
  const NotificationNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}

final class NotificationUnknownFailure extends NotificationFailure {
  const NotificationUnknownFailure([
    super.message = 'Não foi possível concluir a operação. Tente novamente.',
  ]);
}
