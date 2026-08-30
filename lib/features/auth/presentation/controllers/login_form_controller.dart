import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.errorMessage,
  });

  final String email;
  final String password;
  final String? errorMessage;

  bool get isValid =>
      email.trim().isNotEmpty &&
      email.contains('@') &&
      password.isNotEmpty;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final loginFormControllerProvider =
    NotifierProvider<LoginFormController, LoginFormState>(
  LoginFormController.new,
);

class LoginFormController extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String value) {
    state = state.copyWith(email: value, clearError: true);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
