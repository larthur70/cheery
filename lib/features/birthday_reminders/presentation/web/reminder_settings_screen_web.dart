import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_timezones.dart';
import 'package:flutter/material.dart';

class ReminderSettingsScreenWeb extends StatelessWidget {
  const ReminderSettingsScreenWeb({
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    ),
                  Expanded(
                    child: Text(
                      'Lembretes de aniversário',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.cherry,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  if (isSaving)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Receba um aviso diário quando houver aniversariantes.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const SizedBox(height: 24),
              if (!pushSupported) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cherrySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Push está disponível no app iOS/Android. '
                    'Horário e fuso são salvos para o dispositivo móvel.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativar lembretes'),
                subtitle: const Text(
                  'Preferência usada pelo envio diário no horário escolhido',
                ),
                value: settings.notificationsEnabled,
                activeThumbColor: AppColors.cherry,
                onChanged: isSaving ? null : onToggleEnabled,
              ),
              const Divider(height: 36),
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
              const SizedBox(height: 16),
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
      ),
    );
  }
}
