import 'dart:async';

import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/birthday_reminders/data/fcm_service.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/fcm_service_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/notification_repository_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/pending_notification_rationale_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/reminder_controller.dart';
import 'package:cheery/features/onboarding/presentation/controllers/onboarding_tour_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wires FCM listeners and asks notification permission after onboarding.
///
/// Must receive [router] explicitly: this widget sits in
/// [MaterialApp.router]'s builder, above [GoRouter.of] in the tree.
class PushNotificationBootstrap extends ConsumerStatefulWidget {
  const PushNotificationBootstrap({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<PushNotificationBootstrap> createState() =>
      _PushNotificationBootstrapState();
}

class _PushNotificationBootstrapState
    extends ConsumerState<PushNotificationBootstrap> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  var _listenersReady = false;
  var _firstLaunchPromptStarted = false;
  String? _syncedUserId;

  GoRouter get _router => widget.router;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();
    super.dispose();
  }

  Future<void> _promptPermissionAfterOnboarding() async {
    if (_firstLaunchPromptStarted) return;

    final profile = ref.read(currentProfileProvider).valueOrNull;
    // New users get the prompt from the onboarding dialog instead.
    if (profile == null || !profile.onboardingCompleted) return;

    _firstLaunchPromptStarted = true;

    final fcm = ref.read(fcmServiceProvider);
    if (!fcm.isSupported) return;

    try {
      await fcm.initializeLocalNotifications(
        onNotificationTap: (route) => _navigate(route),
      );
      if (await fcm.hasAskedPermission()) return;
      final tour = ref.read(onboardingTourControllerProvider);
      // Onboarding owns the first prompt right after the tour.
      if (tour.showNotificationPrompt || tour.isFinishing) return;
      // Show in-app rationale first; OS prompt runs after the user continues.
      ref.read(pendingNotificationRationaleProvider.notifier).show();
    } catch (error, stackTrace) {
      AppLogger.e(
        'post-onboarding notification permission failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _ensureListeners() async {
    if (_listenersReady) return;
    final fcm = ref.read(fcmServiceProvider);
    if (!fcm.isSupported) {
      _listenersReady = true;
      return;
    }

    await fcm.initializeLocalNotifications(
      onNotificationTap: (route) => _navigate(route),
    );

    _subscriptions.add(
      fcm.onMessage.listen((message) {
        unawaited(fcm.showForegroundNotification(message));
      }),
    );

    _subscriptions.add(
      fcm.onMessageOpenedApp.listen((message) {
        _navigate(FcmService.routeFromMessage(message));
      }),
    );

    _subscriptions.add(
      fcm.onTokenRefresh.listen((token) async {
        final repository = ref.read(notificationRepositoryProvider);
        final platform = fcm.platformName;
        if (repository == null || platform == null) return;
        try {
          await repository.upsertPushToken(token: token, platform: platform);
        } catch (error, stackTrace) {
          AppLogger.e(
            'token refresh upsert failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }),
    );

    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigate(FcmService.routeFromMessage(initial));
      });
    }

    _listenersReady = true;
  }

  Future<void> _syncForUser(String userId) async {
    await _ensureListeners();
    if (_syncedUserId == userId) return;
    _syncedUserId = userId;

    final fcm = ref.read(fcmServiceProvider);
    if (fcm.isSupported) {
      try {
        final granted = await fcm.isPermissionGranted();
        if (granted) {
          final token = await fcm.getToken();
          final platform = fcm.platformName;
          final repository = ref.read(notificationRepositoryProvider);
          if (token != null && platform != null && repository != null) {
            await repository.upsertPushToken(
              token: token,
              platform: platform,
            );
          }
        }
      } catch (error, stackTrace) {
        AppLogger.e(
          'early token upsert failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    try {
      await ref.read(reminderControllerProvider.notifier).syncTokenIfEnabled();
    } catch (error, stackTrace) {
      AppLogger.e(
        'syncTokenIfEnabled failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _navigate(String route) {
    final target = route.startsWith('/') ? route : AppRoutes.home;
    _router.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(
      authControllerProvider.select((state) => state.valueOrNull?.id),
    );

    ref.listen(authControllerProvider, (previous, next) {
      final id = next.valueOrNull?.id;
      if (id != null) {
        unawaited(_syncForUser(id));
      } else {
        _syncedUserId = null;
        _firstLaunchPromptStarted = false;
      }
    });

    ref.listen(currentProfileProvider, (previous, next) {
      unawaited(_promptPermissionAfterOnboarding());
    });

    if (userId != null) {
      unawaited(_syncForUser(userId));
    }

    return widget.child;
  }
}
