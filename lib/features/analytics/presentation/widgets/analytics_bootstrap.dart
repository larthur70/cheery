import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifies the signed-in Supabase user in PostHog and tracks `sessao_aberta`.
///
/// Session rules:
/// - Once when the app becomes ready with a logged-in user
/// - Again on resume after [inactivityThreshold] in the background
class AnalyticsBootstrap extends ConsumerStatefulWidget {
  const AnalyticsBootstrap({
    required this.child,
    this.inactivityThreshold = const Duration(minutes: 30),
    super.key,
  });

  final Widget child;
  final Duration inactivityThreshold;

  @override
  ConsumerState<AnalyticsBootstrap> createState() => _AnalyticsBootstrapState();
}

class _AnalyticsBootstrapState extends ConsumerState<AnalyticsBootstrap>
    with WidgetsBindingObserver {
  String? _identifiedUserId;
  DateTime? _backgroundedAt;
  var _sessionTrackedForUserId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _backgroundedAt = DateTime.now();
      case AppLifecycleState.resumed:
        _maybeTrackSessionAfterResume();
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _maybeTrackSessionAfterResume() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;
    final away = DateTime.now().difference(backgroundedAt);
    if (away < widget.inactivityThreshold) return;
    // Force a new session event for the current user.
    _sessionTrackedForUserId = '';
    _trackSessionIfPossible();
  }

  Future<void> _syncIdentity(String? userId) async {
    final analytics = ref.read(analyticsServiceProvider);
    if (userId == null) {
      if (_identifiedUserId != null) {
        await analytics.reset();
      }
      _identifiedUserId = null;
      _sessionTrackedForUserId = '';
      return;
    }

    if (_identifiedUserId == userId) {
      _trackSessionIfPossible();
      return;
    }

    await analytics.identifyUser(userId);
    _identifiedUserId = userId;
    _sessionTrackedForUserId = '';
    _trackSessionIfPossible();
  }

  void _trackSessionIfPossible() {
    final userId = _identifiedUserId;
    if (userId == null) return;
    if (_sessionTrackedForUserId == userId) return;

    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null || profile.id != userId) return;

    final now = DateTime.now().toUtc();
    final created = profile.createdAt.toUtc();
    final days = now.difference(created).inDays;

    _sessionTrackedForUserId = userId;
    // Fire-and-forget is fine; bridge capture is sync into posthog-js queue.
    ref.read(analyticsServiceProvider).trackSessaoAberta(
          diasDesdeCadastro: days < 0 ? 0 : days,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      _syncIdentity(next.valueOrNull?.id);
    });
    ref.listen(currentProfileProvider, (previous, next) {
      if (next.valueOrNull != null) {
        _trackSessionIfPossible();
      }
    });

    // Catch the initial auth value after first frame.
    final userId = ref.watch(authControllerProvider).valueOrNull?.id;
    if (userId != _identifiedUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncIdentity(ref.read(authControllerProvider).valueOrNull?.id);
      });
    }

    return widget.child;
  }
}
