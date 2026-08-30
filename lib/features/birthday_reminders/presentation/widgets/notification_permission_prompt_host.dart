import 'dart:async';

import 'package:cheery/features/birthday_reminders/presentation/controllers/fcm_service_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/pending_notification_rationale_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/widgets/notification_permission_rationale_dialog.dart';
import 'package:cheery/features/onboarding/presentation/controllers/onboarding_tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the mobile notification rationale when onboarding or bootstrap asks.
class NotificationPermissionPromptHost extends ConsumerStatefulWidget {
  const NotificationPermissionPromptHost({super.key});

  @override
  ConsumerState<NotificationPermissionPromptHost> createState() =>
      _NotificationPermissionPromptHostState();
}

class _NotificationPermissionPromptHostState
    extends ConsumerState<NotificationPermissionPromptHost> {
  var _dialogVisible = false;

  Future<void> _present({VoidCallback? onDismissed}) async {
    if (_dialogVisible || !mounted) return;
    final fcm = ref.read(fcmServiceProvider);
    if (!fcm.isSupported) {
      onDismissed?.call();
      return;
    }

    _dialogVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotificationPermissionRationaleDialog(
        onDismissed: onDismissed,
      ),
    );
    _dialogVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingTourControllerProvider, (previous, next) {
      if (previous?.showNotificationPrompt != next.showNotificationPrompt &&
          next.showNotificationPrompt) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
            _present(
              onDismissed: () {
                ref
                    .read(onboardingTourControllerProvider.notifier)
                    .dismissNotificationPrompt();
              },
            ),
          );
        });
      }
    });

    ref.listen(pendingNotificationRationaleProvider, (previous, next) {
      if (previous != true && next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
            _present(
              onDismissed: () {
                ref.read(pendingNotificationRationaleProvider.notifier).clear();
              },
            ),
          );
        });
      }
    });

    return const SizedBox.shrink();
  }
}
