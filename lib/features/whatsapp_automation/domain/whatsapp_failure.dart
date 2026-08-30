/// Typed failures for WhatsApp automation operations.
sealed class WhatsAppFailure implements Exception {
  const WhatsAppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class WhatsAppNotReadyFailure extends WhatsAppFailure {
  const WhatsAppNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class WhatsAppNotProFailure extends WhatsAppFailure {
  const WhatsAppNotProFailure([
    super.message =
        'A integração WhatsApp Business ainda não está disponível. Em breve.',
  ]);
}

final class WhatsAppNotConnectedFailure extends WhatsAppFailure {
  const WhatsAppNotConnectedFailure([
    super.message = 'Conecte o WhatsApp Business para continuar.',
  ]);
}

final class WhatsAppOAuthFailure extends WhatsAppFailure {
  const WhatsAppOAuthFailure([
    super.message = 'Não foi possível concluir a conexão com o WhatsApp.',
  ]);
}

final class WhatsAppRemoteFailure extends WhatsAppFailure {
  const WhatsAppRemoteFailure([
    super.message = 'Não foi possível concluir a operação. Tente novamente.',
  ]);
}

final class WhatsAppNetworkFailure extends WhatsAppFailure {
  const WhatsAppNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}
