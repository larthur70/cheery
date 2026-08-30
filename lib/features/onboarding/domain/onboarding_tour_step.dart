/// Product-tour steps shown over the real app shell after first signup.
enum OnboardingTourStep {
  /// Large welcome popup on Home before the guided tour.
  welcome,
  clients,
  /// Opens the real import flow so the user can add clients quickly.
  importClients,
  templates,
  home,
}

extension OnboardingTourStepX on OnboardingTourStep {
  /// Matches [StatefulNavigationShell] branch order in [appRouterProvider].
  int get shellBranchIndex => switch (this) {
        OnboardingTourStep.welcome => 0,
        OnboardingTourStep.home => 0,
        OnboardingTourStep.clients => 1,
        OnboardingTourStep.importClients => 1,
        OnboardingTourStep.templates => 3,
      };

  bool get isWelcome => this == OnboardingTourStep.welcome;

  bool get isImportClients => this == OnboardingTourStep.importClients;

  /// Import step hides the tour UI so the user can finish or cancel freely.
  bool get hidesTourChrome => isImportClients;

  /// User can use the screen (import UI) instead of a blocking scrim.
  bool get allowsInteraction => isImportClients;

  /// Guided coach-mark steps (excludes the welcome popup).
  static const List<OnboardingTourStep> tourSteps = [
    OnboardingTourStep.clients,
    OnboardingTourStep.templates,
    OnboardingTourStep.importClients,
    OnboardingTourStep.home,
  ];

  static const List<OnboardingTourStep> ordered = [
    OnboardingTourStep.welcome,
    ...tourSteps,
  ];
}
