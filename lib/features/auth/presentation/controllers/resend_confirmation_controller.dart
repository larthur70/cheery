import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const resendConfirmationCooldown = Duration(seconds: 60);

class ResendConfirmationState {
  const ResendConfirmationState({
    this.remainingSeconds = 0,
    this.isResending = false,
    this.feedbackMessage,
    this.feedbackIsError = false,
  });

  final int remainingSeconds;
  final bool isResending;
  final String? feedbackMessage;
  final bool feedbackIsError;

  bool get canResend => remainingSeconds <= 0 && !isResending;

  ResendConfirmationState copyWith({
    int? remainingSeconds,
    bool? isResending,
    String? feedbackMessage,
    bool? feedbackIsError,
    bool clearFeedback = false,
  }) {
    return ResendConfirmationState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResending: isResending ?? this.isResending,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
    );
  }
}

final resendConfirmationControllerProvider =
    NotifierProvider<ResendConfirmationController, ResendConfirmationState>(
  ResendConfirmationController.new,
);

class ResendConfirmationController extends Notifier<ResendConfirmationState> {
  Timer? _timer;

  @override
  ResendConfirmationState build() {
    ref.onDispose(() => _timer?.cancel());
    // Signup just triggered the first email — start cooldown immediately.
    Future.microtask(startCooldown);
    return ResendConfirmationState(
      remainingSeconds: resendConfirmationCooldown.inSeconds,
    );
  }

  void startCooldown() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: resendConfirmationCooldown.inSeconds,
      clearFeedback: true,
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

  void setResending(bool value) {
    state = state.copyWith(isResending: value);
  }

  void setSuccess(String message) {
    state = state.copyWith(
      feedbackMessage: message,
      feedbackIsError: false,
      isResending: false,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      feedbackMessage: message,
      feedbackIsError: true,
      isResending: false,
    );
  }
}
