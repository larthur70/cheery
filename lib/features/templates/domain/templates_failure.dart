import 'package:cheery/core/platform/store_compliance.dart';

/// Typed failures for templates operations.
sealed class TemplatesFailure implements Exception {
  const TemplatesFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class TemplatesNotReadyFailure extends TemplatesFailure {
  const TemplatesNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class TemplatesNotFoundFailure extends TemplatesFailure {
  const TemplatesNotFoundFailure([
    super.message = 'Template não encontrado.',
  ]);
}

final class TemplatesDefaultMissingFailure extends TemplatesFailure {
  const TemplatesDefaultMissingFailure([
    super.message =
        'Nenhum template padrão encontrado. Tente sair e entrar novamente.',
  ]);
}

final class TemplatesInUseFailure extends TemplatesFailure {
  const TemplatesInUseFailure([
    super.message =
        'Este template está vinculado a clientes. Reatribua-os antes de excluir.',
  ]);
}

final class TemplatesCannotDeleteDefaultFailure extends TemplatesFailure {
  const TemplatesCannotDeleteDefaultFailure([
    super.message =
        'Defina outro template como padrão antes de excluir este.',
  ]);
}

final class TemplatesValidationFailure extends TemplatesFailure {
  const TemplatesValidationFailure(super.message);
}

final class TemplatesPlanLimitFailure extends TemplatesFailure {
  TemplatesPlanLimitFailure([String? message])
      : super(message ?? StoreCompliance.templateLimitMessage());
}

final class TemplatesNetworkFailure extends TemplatesFailure {
  const TemplatesNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}

final class TemplatesUnknownFailure extends TemplatesFailure {
  const TemplatesUnknownFailure([
    super.message = 'Não foi possível concluir a operação. Tente novamente.',
  ]);
}

final class TemplatesNotApprovedFailure extends TemplatesFailure {
  const TemplatesNotApprovedFailure([
    super.message =
        'Para automação, escolha um template aprovado pela Meta.',
  ]);
}

final class TemplatesSubmitFailure extends TemplatesFailure {
  const TemplatesSubmitFailure([
    super.message =
        'Não foi possível enviar o template para aprovação da Meta.',
  ]);
}
