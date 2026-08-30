import 'package:cheery/core/constants/app_breakpoints.dart';
import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:cheery/features/onboarding/domain/onboarding_tour_step.dart';
import 'package:cheery/features/onboarding/presentation/controllers/onboarding_tour_controller.dart';
import 'package:cheery/features/onboarding/presentation/widgets/onboarding_coach_card.dart';
import 'package:cheery/features/onboarding/presentation/widgets/onboarding_spotlight_layer.dart';
import 'package:cheery/features/onboarding/presentation/widgets/onboarding_welcome_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Coach-mark tour overlaid on the adaptive shell after first signup.
class OnboardingTourOverlay extends ConsumerStatefulWidget {
  const OnboardingTourOverlay({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<OnboardingTourOverlay> createState() =>
      _OnboardingTourOverlayState();
}

class _OnboardingTourOverlayState extends ConsumerState<OnboardingTourOverlay> {
  var _holes = <Rect>[];
  OnboardingTourStep? _lastSyncedStep;
  /// True after we navigated into import; used to detect finish/cancel exit.
  var _awaitingImportExit = false;
  /// Ensures we don't resume before the import route has actually opened.
  var _sawImportRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncStepNavigation());
  }

  bool _isImportLocation(String path) {
    return path == AppRoutes.clientsImport ||
        path.startsWith('${AppRoutes.clientsImport}/') ||
        path == AppRoutes.clientsImportContacts ||
        path.startsWith('${AppRoutes.clientsImportContacts}/');
  }

  void _syncStepNavigation() {
    final state = ref.read(onboardingTourControllerProvider);
    if (!state.isActive) return;
    final step = state.step;
    if (_lastSyncedStep == step) {
      _refreshHoles();
      return;
    }
    _lastSyncedStep = step;

    final branch = step.shellBranchIndex;
    if (widget.navigationShell.currentIndex != branch) {
      widget.navigationShell.goBranch(branch);
    }

    final isMobile =
        MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;
    final router = GoRouter.of(context);

    switch (step) {
      case OnboardingTourStep.importClients:
        _awaitingImportExit = true;
        _sawImportRoute = false;
        router.go(
          isMobile
              ? AppRoutes.clientsImportContacts
              : AppRoutes.clientsImport,
        );
      case OnboardingTourStep.templates:
        _awaitingImportExit = false;
        _sawImportRoute = false;
        router.go(AppRoutes.templates);
      case OnboardingTourStep.home:
        _awaitingImportExit = false;
        _sawImportRoute = false;
        router.go(AppRoutes.home);
      case OnboardingTourStep.clients:
        _awaitingImportExit = false;
        _sawImportRoute = false;
        router.go(AppRoutes.clients);
      case OnboardingTourStep.welcome:
        _awaitingImportExit = false;
        _sawImportRoute = false;
        router.go(AppRoutes.home);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHoles());
    });
  }

  void _maybeResumeAfterImport() {
    final tour = ref.read(onboardingTourControllerProvider);
    if (!tour.isActive || !tour.step.isImportClients || !_awaitingImportExit) {
      return;
    }

    final path = GoRouter.of(context).state.uri.path;
    if (_isImportLocation(path)) {
      _sawImportRoute = true;
      return;
    }
    // Wait until import has opened at least once, then resume on exit.
    if (!_sawImportRoute) return;

    _awaitingImportExit = false;
    _sawImportRoute = false;
    ref.read(onboardingTourControllerProvider.notifier).next();
  }

  void _refreshHoles() {
    if (!mounted) return;
    final state = ref.read(onboardingTourControllerProvider);
    if (!state.isActive ||
        state.step.isWelcome ||
        state.step.hidesTourChrome) {
      if (_holes.isNotEmpty) setState(() => _holes = []);
      return;
    }

    final isMobile =
        MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;
    final keys = _keysFor(state.step, isMobile: isMobile);
    final next = <Rect>[];
    for (final key in keys) {
      final rect = OnboardingAnchors.rectOf(key);
      if (rect != null && rect.width > 0 && rect.height > 0) {
        next.add(rect);
      }
    }

    if (!_sameRects(_holes, next)) {
      setState(() => _holes = next);
    }
  }

  List<GlobalKey> _keysFor(
    OnboardingTourStep step, {
    required bool isMobile,
  }) {
    return switch (step) {
      OnboardingTourStep.welcome || OnboardingTourStep.importClients =>
        const [],
      OnboardingTourStep.clients => [
          OnboardingAnchors.clientsAdd,
          if (isMobile)
            OnboardingAnchors.clientsImportContacts
          else
            OnboardingAnchors.clientsImport,
        ],
      OnboardingTourStep.templates => [OnboardingAnchors.templatesHeader],
      OnboardingTourStep.home => [OnboardingAnchors.homeBirthdays],
    };
  }

  bool _sameRects(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(onboardingTourControllerProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;
    final notifier = ref.read(onboardingTourControllerProvider.notifier);

    // Rebuild when route changes so we notice import finish/cancel.
    GoRouterState.of(context);

    ref.listen(onboardingTourControllerProvider, (previous, next) {
      if (next.isActive &&
          (previous?.stepIndex != next.stepIndex ||
              previous?.isActive != next.isActive)) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _syncStepNavigation());
      }
    });

    if (!tour.isActive) {
      return const SizedBox.shrink();
    }

    if (tour.step.hidesTourChrome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeResumeAfterImport();
      });
      return const SizedBox.shrink();
    }

    final media = MediaQuery.of(context);
    final cardBottom = isMobile
        ? media.padding.bottom + 88
        : media.padding.bottom + 28;

    final tourStepIndex = tour.stepIndex - 1;
    final tourStepCount = OnboardingTourStepX.tourSteps.length;

    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false),
          if (tour.step.isWelcome)
            ColoredBox(
              color: AppColors.ink.withValues(alpha: 0.55),
              child: const SizedBox.expand(),
            )
          else
            OnboardingSpotlightLayer(holes: _holes),
          if (tour.step.isWelcome)
            Center(
              child: OnboardingWelcomePopup(
                onStart: notifier.next,
                onSkip: notifier.skip,
              ),
            )
          else
            Positioned(
              left: 16,
              right: 16,
              bottom: cardBottom,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OnboardingCoachCard(
                  step: tour.step,
                  stepIndex: tourStepIndex.clamp(0, tourStepCount - 1),
                  stepCount: tourStepCount,
                  isMobile: isMobile,
                  onNext: notifier.next,
                  onSkip: notifier.skip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
