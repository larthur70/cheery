import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/fcm_service_provider.dart';
import 'package:cheery/features/birthday_reminders/presentation/controllers/reminder_controller.dart';
import 'package:cheery/features/birthday_reminders/presentation/mobile/reminder_settings_screen_mobile.dart';
import 'package:cheery/features/birthday_reminders/presentation/web/reminder_settings_screen_web.dart';
import 'package:cheery/features/birthday_reminders/presentation/widgets/notification_permission_rationale_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReminderSettingsEntryScreen extends ConsumerWidget {
  const ReminderSettingsEntryScreen({super.key});

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
  ) async {
    final parts = settings.notificationTimeHm.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;

    try {
      await ref.read(reminderControllerProvider.notifier).updateTime(
            ReminderSettingsTime.formatTimeOfDay(picked.hour, picked.minute),
          );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, error);
    }
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    try {
      final fcm = ref.read(fcmServiceProvider);
      if (enabled &&
          fcm.isSupported &&
          !await fcm.isPermissionGranted()) {
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const NotificationPermissionRationaleDialog(),
        );
        return;
      }
      await ref.read(reminderControllerProvider.notifier).setEnabled(enabled);
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, error);
    }
  }

  Future<void> _timezone(
    BuildContext context,
    WidgetRef ref,
    String timezone,
  ) async {
    try {
      await ref
          .read(reminderControllerProvider.notifier)
          .updateTimezone(timezone);
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    final message = error is NotificationFailure
        ? error.message
        : 'Não foi possível atualizar as configurações.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(reminderControllerProvider);
    final pushSupported = ref.watch(fcmServiceProvider).isSupported;
    final isSaving = settingsAsync.isLoading && settingsAsync.hasValue;

    return settingsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: CheeryLoading(message: 'Carregando configurações...'),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: CheeryEmptyState(
          title: 'Não foi possível carregar',
          message: error is NotificationFailure
              ? error.message
              : 'Tente novamente em instantes.',
          icon: Icons.error_outline,
          actionLabel: 'Tentar novamente',
          onAction: () =>
              ref.read(reminderControllerProvider.notifier).refresh(),
        ),
      ),
      data: (settings) {
        return ResponsiveBuilder(
          mobile: (_) => ReminderSettingsScreenMobile(
            settings: settings,
            isSaving: isSaving,
            pushSupported: pushSupported,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            onToggleEnabled: (value) => _toggle(context, ref, value),
            onPickTime: () => _pickTime(context, ref, settings),
            onTimezoneChanged: (value) => _timezone(context, ref, value),
          ),
          desktop: (_) => ReminderSettingsScreenWeb(
            settings: settings,
            isSaving: isSaving,
            pushSupported: pushSupported,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            onToggleEnabled: (value) => _toggle(context, ref, value),
            onPickTime: () => _pickTime(context, ref, settings),
            onTimezoneChanged: (value) => _timezone(context, ref, value),
          ),
        );
      },
    );
  }
}
