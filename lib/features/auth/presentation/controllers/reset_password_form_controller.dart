import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordFormState {
  const ResetPasswordFormState({
    this.password = '',
    this.confirmPassword = '',
    this.errorMessage,
    this.successMessage,
    this.isRecoveringSession = true,
    this.hasRecoverySession = false,
  });

  final String password;
  final String confirmPassword;
  final String? errorMessage;
  final String? successMessage;
  final bool isRecoveringSession;
  final bool hasRecoverySession;

  bool get isValid =>
      password.length >= 6 && password == confirmPassword;

  String? get validationMessage {
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (password != confirmPassword) return 'As senhas não coincidem.';
    return null;
  }

  ResetPasswordFormState copyWith({
    String? password,
    String? confirmPassword,
    String? errorMessage,
    String? successMessage,
    bool? isRecoveringSession,
    bool? hasRecoverySession,
    bool clearMessages = false,
  }) {
    return ResetPasswordFormState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      isRecoveringSession:
          isRecoveringSession ?? this.isRecoveringSession,
      hasRecoverySession: hasRecoverySession ?? this.hasRecoverySession,
    );
  }
}

final resetPasswordFormControllerProvider =
    NotifierProvider<ResetPasswordFormController, ResetPasswordFormState>(
  ResetPasswordFormController.new,
);

class ResetPasswordFormController extends Notifier<ResetPasswordFormState> {
  @override
  ResetPasswordFormState build() => const ResetPasswordFormState();

  void setPassword(String value) {
    state = state.copyWith(password: value, clearMessages: true);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, clearMessages: true);
  }

  void setRecovering({required bool recovering, required bool hasSession}) {
    state = state.copyWith(
      isRecoveringSession: recovering,
      hasRecoverySession: hasSession,
      clearMessages: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      successMessage: null,
      isRecoveringSession: false,
    );
  }

  void setSuccess(String message) {
    state = state.copyWith(successMessage: message, errorMessage: null);
  }
}
