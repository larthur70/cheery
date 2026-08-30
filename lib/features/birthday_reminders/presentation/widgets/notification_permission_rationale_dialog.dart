import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_permission_copy.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/fcm_service_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-app rationale shown on mobile before the OS notification permission.
///
/// Cannot be dismissed — the only action continues to the system alert.
class NotificationPermissionRationaleDialog extends ConsumerStatefulWidget {
  const NotificationPermissionRationaleDialog({
    this.onDismissed,
    super.key,
  });

  final VoidCallback? onDismissed;

  @override
  ConsumerState<NotificationPermissionRationaleDialog> createState() =>
      _NotificationPermissionRationaleDialogState();
}

class _NotificationPermissionRationaleDialogState
    extends ConsumerState<NotificationPermissionRationaleDialog> {
  var _loading = false;

  Future<void> _continueToSystemPrompt() async {
    if (_loading) return;
    setState(() => _loading = true);

    final fcm = ref.read(fcmServiceProvider);
    // Close our dialog first so the OS alert is clearly next.
    if (mounted) Navigator.of(context).pop();
    widget.onDismissed?.call();

    try {
      await fcm.markPermissionPromptShown();
      await ref.read(reminderControllerProvider.notifier).setEnabled(true);
    } on NotificationFailure {
      // OS denied or unsupported — still counted as prompted.
    } catch (_) {
      // Ignore; permission may still be pending on the device.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cherrySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.cherry,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                NotificationPermissionCopy.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                NotificationPermissionCopy.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              CheeryButton(
                label: NotificationPermissionCopy.continueLabel,
                expanded: true,
                isLoading: _loading,
                onPressed: _continueToSystemPrompt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
