import 'package:cheery/core/platform/store_compliance.dart';

/// Typed failures for clients operations.
sealed class ClientsFailure implements Exception {
  const ClientsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ClientsNotReadyFailure extends ClientsFailure {
  const ClientsNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class ClientsNotFoundFailure extends ClientsFailure {
  const ClientsNotFoundFailure([
    super.message = 'Cliente não encontrado.',
  ]);
}

final class ClientsValidationFailure extends ClientsFailure {
  const ClientsValidationFailure(super.message);
}

final class ClientsPlanLimitFailure extends ClientsFailure {
  ClientsPlanLimitFailure([String? message])
      : super(message ?? StoreCompliance.clientLimitMessage());
}

final class ClientsNetworkFailure extends ClientsFailure {
  const ClientsNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}

final class ClientsUnknownFailure extends ClientsFailure {
  const ClientsUnknownFailure([
    super.message = 'Não foi possível concluir a operação. Tente novamente.',
  ]);
}

final class ClientsAutomaticRequiresApprovedTemplateFailure
    extends ClientsFailure {
  const ClientsAutomaticRequiresApprovedTemplateFailure([
    super.message =
        'Para automação, escolha um template aprovado pela Meta.',
  ]);
}

final class ClientsAutomaticRequiresWhatsAppFailure extends ClientsFailure {
  const ClientsAutomaticRequiresWhatsAppFailure([
    super.message =
        'Conecte o WhatsApp Business antes de ativar a automação.',
  ]);
}

final class ClientsDuplicatePhoneFailure extends ClientsFailure {
  const ClientsDuplicatePhoneFailure([
    super.message = 'Já existe um cliente com este telefone.',
  ]);
}
