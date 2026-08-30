import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const forgotPasswordCooldown = Duration(seconds: 60);

class ForgotPasswordFormState {
  const ForgotPasswordFormState({
    this.email = '',
    this.errorMessage,
    this.successMessage,
    this.remainingSeconds = 0,
    this.isSubmitting = false,
  });

  final String email;
  final String? errorMessage;
  final String? successMessage;
  final int remainingSeconds;
  final bool isSubmitting;

  bool get isValid => email.trim().contains('@');

  bool get canSubmit => remainingSeconds <= 0 && !isSubmitting;

  ForgotPasswordFormState copyWith({
    String? email,
    String? errorMessage,
    String? successMessage,
    int? remainingSeconds,
    bool? isSubmitting,
    bool clearMessages = false,
  }) {
    return ForgotPasswordFormState(
      email: email ?? this.email,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final forgotPasswordFormControllerProvider =
    NotifierProvider<ForgotPasswordFormController, ForgotPasswordFormState>(
  ForgotPasswordFormController.new,
);

class ForgotPasswordFormController extends Notifier<ForgotPasswordFormState> {
  Timer? _timer;

  @override
  ForgotPasswordFormState build() {
    ref.onDispose(() => _timer?.cancel());
    return const ForgotPasswordFormState();
  }

  void setEmail(String value) {
    state = state.copyWith(email: value, clearMessages: true);
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }

  void setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      successMessage: null,
      isSubmitting: false,
    );
  }

  void setSuccess(String message) {
    state = state.copyWith(
      successMessage: message,
      errorMessage: null,
      isSubmitting: false,
    );
  }

  void startCooldown() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: forgotPasswordCooldown.inSeconds,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(remainingSeconds: 0);
        return;
      }
      state = state.copyWith(remainingSeconds: next);
    });
  }
}
