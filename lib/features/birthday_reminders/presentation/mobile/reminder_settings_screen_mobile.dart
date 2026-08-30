import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_timezones.dart';
import 'package:flutter/material.dart';

class ReminderSettingsScreenMobile extends StatelessWidget {
  const ReminderSettingsScreenMobile({
    required this.settings,
    required this.isSaving,
    required this.pushSupported,
    this.onBack,
    this.onToggleEnabled,
    this.onPickTime,
    this.onTimezoneChanged,
    super.key,
  });

  final ReminderSettings settings;
  final bool isSaving;
  final bool pushSupported;
  final VoidCallback? onBack;
  final ValueChanged<bool>? onToggleEnabled;
  final VoidCallback? onPickTime;
  final ValueChanged<String>? onTimezoneChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  ),
                  Expanded(
                    child: Text(
                      'Lembretes de aniversário',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.cherry,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (isSaving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text(
                    'Receba um aviso diário quando houver aniversariantes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (!pushSupported) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cherrySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Push está disponível no app iOS/Android. '
                        'Você já pode salvar horário e fuso aqui.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ativar lembretes'),
                    subtitle: Text(
                      pushSupported
                          ? 'Solicita permissão e registra este dispositivo'
                          : 'Preferência salva para o app mobile',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                    value: settings.notificationsEnabled,
                    activeThumbColor: AppColors.cherry,
                    onChanged: isSaving ? null : onToggleEnabled,
                  ),
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Horário'),
                    subtitle: Text(
                      settings.notificationTimeHm,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    trailing: const Icon(Icons.schedule, color: AppColors.cherry),
                    onTap: isSaving ? null : onPickTime,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fuso horário',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: ReminderTimezones.options.any(
                      (o) => o.id == settings.timezone,
                    )
                        ? settings.timezone
                        : ReminderTimezones.defaultId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                    items: [
                      for (final option in ReminderTimezones.options)
                        DropdownMenuItem(
                          value: option.id,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: isSaving
                        ? null
                        : (value) {
                            if (value != null) onTimezoneChanged?.call(value);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
