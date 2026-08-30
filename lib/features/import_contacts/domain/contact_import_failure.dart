sealed class ContactImportFailure implements Exception {
  const ContactImportFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ContactPermissionDeniedFailure extends ContactImportFailure {
  const ContactPermissionDeniedFailure([
    super.message =
        'Permissão de contatos negada. Ative o acesso nas configurações do aparelho.',
  ]);
}

final class ContactPermissionPermanentlyDeniedFailure
    extends ContactImportFailure {
  const ContactPermissionPermanentlyDeniedFailure([
    super.message =
        'Permissão de contatos bloqueada. Abra as configurações do app para liberar o acesso.',
  ]);
}

final class ContactLoadFailure extends ContactImportFailure {
  const ContactLoadFailure([
    super.message = 'Não foi possível carregar os contatos do aparelho.',
  ]);
}

final class ContactNoSelectionFailure extends ContactImportFailure {
  const ContactNoSelectionFailure([
    super.message = 'Selecione pelo menos um contato para continuar.',
  ]);
}

final class ContactNoReadyRowsFailure extends ContactImportFailure {
  const ContactNoReadyRowsFailure([
    super.message =
        'Nenhum contato pronto para importar. Preencha a data de aniversário ou ignore os pendentes.',
  ]);
}

final class ContactNotReadyFailure extends ContactImportFailure {
  const ContactNotReadyFailure([
    super.message = 'Não foi possível preparar a importação. Tente novamente.',
  ]);
}

final class ContactUnknownFailure extends ContactImportFailure {
  const ContactUnknownFailure([
    super.message = 'Algo deu errado na importação. Tente novamente.',
  ]);
}
