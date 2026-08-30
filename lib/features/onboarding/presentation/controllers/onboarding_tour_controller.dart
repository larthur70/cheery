import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/onboarding/domain/onboarding_copy.dart';
import 'package:cheery/features/onboarding/domain/onboarding_tour_step.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingTourState {
  const OnboardingTourState({
    this.isActive = false,
    this.stepIndex = 0,
    this.isFinishing = false,
    this.showNotificationPrompt = false,
  });

  final bool isActive;
  final int stepIndex;
  final bool isFinishing;
  /// Mobile-only dialog after the visual tour ends.
  final bool showNotificationPrompt;

  OnboardingTourStep get step =>
      OnboardingTourStepX.ordered[stepIndex.clamp(
        0,
        OnboardingTourStepX.ordered.length - 1,
      )];

  bool get isLastStep =>
      stepIndex >= OnboardingTourStepX.ordered.length - 1;

  int get stepCount => OnboardingTourStepX.ordered.length;

  OnboardingTourState copyWith({
    bool? isActive,
    int? stepIndex,
    bool? isFinishing,
    bool? showNotificationPrompt,
  }) {
    return OnboardingTourState(
      isActive: isActive ?? this.isActive,
      stepIndex: stepIndex ?? this.stepIndex,
      isFinishing: isFinishing ?? this.isFinishing,
      showNotificationPrompt:
          showNotificationPrompt ?? this.showNotificationPrompt,
    );
  }
}

final onboardingTourControllerProvider =
    NotifierProvider<OnboardingTourController, OnboardingTourState>(
  OnboardingTourController.new,
);

class OnboardingTourController extends Notifier<OnboardingTourState> {
  var _startedForUserId = '';

  @override
  OnboardingTourState build() {
    ref.listen<AsyncValue<Profile?>>(currentProfileProvider, (previous, next) {
      final profile = next.valueOrNull;
      final userId = ref.read(authControllerProvider).valueOrNull?.id;
      if (userId == null || profile == null) {
        if (state.isActive || state.showNotificationPrompt) {
          state = const OnboardingTourState();
        }
        _startedForUserId = '';
        return;
      }
      _maybeStart(profile, userId);
    });

    ref.listen(authControllerProvider, (previous, next) {
      if (next.valueOrNull == null) {
        state = const OnboardingTourState();
        _startedForUserId = '';
      }
    });

    return const OnboardingTourState();
  }

  void _maybeStart(Profile profile, String userId) {
    if (profile.onboardingCompleted) return;
    // Social sign-in must collect company name before the tour.
    if (!profile.hasCompanyName) return;
    if (state.isActive || state.isFinishing || state.showNotificationPrompt) {
      return;
    }
    if (_startedForUserId == userId) return;
    _startedForUserId = userId;
    state = const OnboardingTourState(isActive: true);
  }

  void next() {
    if (!state.isActive || state.isFinishing) return;
    _trackStepCompleted(state.step);
    if (state.isLastStep) {
      finish(trackCurrentStep: false);
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  void skip() => finish(trackCurrentStep: false);

  Future<void> finish({bool trackCurrentStep = true}) async {
    if (state.isFinishing) return;
    if (trackCurrentStep && state.isActive && state.isLastStep) {
      _trackStepCompleted(state.step);
    }
    state = state.copyWith(isActive: false, isFinishing: true);

    final askNotifications = OnboardingCopy.isMobilePlatform;

    final userId = ref.read(authControllerProvider).valueOrNull?.id;
    final repository = ref.read(authRepositoryProvider);
    if (userId != null && repository != null) {
      try {
        await repository.markOnboardingCompleted(userId);
        ref.invalidate(currentProfileProvider);
      } catch (_) {
        // Allow the tour to start again next session if the write failed.
        _startedForUserId = '';
      }
    }

    state = OnboardingTourState(
      isFinishing: false,
      showNotificationPrompt: askNotifications,
    );
  }

  void dismissNotificationPrompt() {
    state = state.copyWith(showNotificationPrompt: false);
  }

  void _trackStepCompleted(OnboardingTourStep step) {
    final analyticsStep = switch (step) {
      OnboardingTourStep.welcome => OnboardingAnalyticsStep.apresentacao,
      OnboardingTourStep.importClients => OnboardingAnalyticsStep.import,
      OnboardingTourStep.templates => OnboardingAnalyticsStep.template,
      OnboardingTourStep.home => OnboardingAnalyticsStep.home,
      // Coach-mark before import — not part of the PostHog funnel steps.
      OnboardingTourStep.clients => null,
    };
    if (analyticsStep == null) return;
    ref.read(analyticsServiceProvider).trackOnboardingStepCompleted(
          analyticsStep,
        );
  }
}
