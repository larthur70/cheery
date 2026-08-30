import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormState {
  const SignUpFormState({
    this.fullName = '',
    this.companyName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.errorMessage,
  });

  final String fullName;
  final String companyName;
  final String email;
  final String password;
  final String confirmPassword;
  final String? errorMessage;

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      companyName.trim().isNotEmpty &&
      email.trim().contains('@') &&
      password.length >= 6 &&
      password == confirmPassword;

  String? get validationMessage {
    if (fullName.trim().isEmpty) return 'Informe seu nome.';
    if (companyName.trim().isEmpty) return 'Informe o nome da sua empresa.';
    if (!email.trim().contains('@')) return 'Informe um e-mail válido.';
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (password != confirmPassword) return 'As senhas não coincidem.';
    return null;
  }

  SignUpFormState copyWith({
    String? fullName,
    String? companyName,
    String? email,
    String? password,
    String? confirmPassword,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignUpFormState(
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final signUpFormControllerProvider =
    NotifierProvider<SignUpFormController, SignUpFormState>(
  SignUpFormController.new,
);

class SignUpFormController extends Notifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  void setFullName(String value) {
    state = state.copyWith(fullName: value, clearError: true);
  }

  void setCompanyName(String value) {
    state = state.copyWith(companyName: value, clearError: true);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value, clearError: true);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, clearError: true);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
