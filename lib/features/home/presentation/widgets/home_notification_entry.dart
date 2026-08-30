import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home header control to open reminder time settings.
///
/// When notifications are off, the control itself is a card labeled
/// "Desativada". When on, it shows the scheduled time.
class HomeNotificationEntry extends ConsumerWidget {
  const HomeNotificationEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderControllerProvider).valueOrNull;
    final enabled = settings?.notificationsEnabled ?? false;
    final time = settings == null ? '08:00' : settings.notificationTimeHm;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: enabled ? AppColors.surfaceElevated : AppColors.cherrySoft,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: enabled ? AppColors.border : AppColors.cherryMuted,
          ),
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.reminderSettings),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  enabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  size: 18,
                  color: AppColors.cherry,
                ),
                const SizedBox(width: 6),
                Text(
                  enabled ? time : 'Desativada',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: enabled ? AppColors.ink : AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
