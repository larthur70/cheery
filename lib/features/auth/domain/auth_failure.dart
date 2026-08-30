/// Typed failures for authentication operations.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AuthInvalidCredentialsFailure extends AuthFailure {
  const AuthInvalidCredentialsFailure([
    super.message = 'E-mail ou senha inválidos.',
  ]);
}

final class AuthAccountNotFoundFailure extends AuthFailure {
  const AuthAccountNotFoundFailure([
    super.message = 'Não existe uma conta com este e-mail.',
  ]);
}

final class AuthWrongPasswordFailure extends AuthFailure {
  const AuthWrongPasswordFailure([
    super.message = 'Senha incorreta.',
  ]);
}

final class AuthEmailAlreadyInUseFailure extends AuthFailure {
  const AuthEmailAlreadyInUseFailure([
    super.message = 'Este e-mail já está em uso.',
  ]);
}

final class AuthWeakPasswordFailure extends AuthFailure {
  const AuthWeakPasswordFailure([
    super.message = 'A senha é muito fraca. Use pelo menos 6 caracteres.',
  ]);
}

final class AuthEmailNotConfirmedFailure extends AuthFailure {
  const AuthEmailNotConfirmedFailure([
    super.message = 'Confirme seu e-mail antes de entrar.',
  ]);
}

final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}

final class AuthCancelledFailure extends AuthFailure {
  const AuthCancelledFailure([
    super.message = 'Autenticação cancelada.',
  ]);
}

final class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure([
    super.message = 'Não foi possível autenticar. Tente novamente.',
  ]);
}

final class AuthEmailChangeNotAllowedFailure extends AuthFailure {
  const AuthEmailChangeNotAllowedFailure([
    super.message =
        'Contas conectadas ao Google ou Apple não podem alterar o e-mail '
        'por aqui. Use o e-mail da conta social.',
  ]);
}

final class AuthDeleteAccountFailure extends AuthFailure {
  const AuthDeleteAccountFailure([
    super.message = 'Não foi possível excluir a conta. Tente novamente.',
  ]);
}

final class AuthDeleteAccountEmailSentFailure extends AuthFailure {
  const AuthDeleteAccountEmailSentFailure([
    super.message =
        'Não foi possível enviar o e-mail de confirmação. Tente novamente.',
  ]);
}
