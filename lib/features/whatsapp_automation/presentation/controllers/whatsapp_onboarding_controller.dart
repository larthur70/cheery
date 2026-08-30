import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhatsAppOnboardingState {
  const WhatsAppOnboardingState({
    this.stepIndex = 0,
    this.isStartingOAuth = false,
    this.errorMessage,
  });

  static const stepCount = 3;

  final int stepIndex;
  final bool isStartingOAuth;
  final String? errorMessage;

  bool get isLastStep => stepIndex >= stepCount - 1;

  WhatsAppOnboardingState copyWith({
    int? stepIndex,
    bool? isStartingOAuth,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WhatsAppOnboardingState(
      stepIndex: stepIndex ?? this.stepIndex,
      isStartingOAuth: isStartingOAuth ?? this.isStartingOAuth,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final whatsappOnboardingControllerProvider =
    NotifierProvider.autoDispose<WhatsAppOnboardingController,
        WhatsAppOnboardingState>(
  WhatsAppOnboardingController.new,
);

class WhatsAppOnboardingController
    extends AutoDisposeNotifier<WhatsAppOnboardingState> {
  @override
  WhatsAppOnboardingState build() => const WhatsAppOnboardingState();

  void nextStep() {
    if (state.isLastStep) return;
    state = state.copyWith(
      stepIndex: state.stepIndex + 1,
      clearError: true,
    );
  }

  void previousStep() {
    if (state.stepIndex <= 0) return;
    state = state.copyWith(
      stepIndex: state.stepIndex - 1,
      clearError: true,
    );
  }

  void setStartingOAuth(bool value) {
    state = state.copyWith(isStartingOAuth: value, clearError: true);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isStartingOAuth: false);
  }
}
