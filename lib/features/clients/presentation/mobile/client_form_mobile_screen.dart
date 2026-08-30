import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/clients/presentation/controllers/client_form_controller.dart';
import 'package:cheery/features/clients/presentation/controllers/client_templates_provider.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_connect_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showClientFormMobile(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => const ClientFormMobileScreen(),
    ),
  );
}

/// Full-screen mobile create/edit client layout (Stitch).
class ClientFormMobileScreen extends ConsumerStatefulWidget {
  const ClientFormMobileScreen({super.key});

  @override
  ConsumerState<ClientFormMobileScreen> createState() =>
      _ClientFormMobileScreenState();
}

class _ClientFormMobileScreenState
    extends ConsumerState<ClientFormMobileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(clientFormControllerProvider);
    _nameController = TextEditingController(text: form.name);
    _phoneController = TextEditingController(text: form.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final form = ref.read(clientFormControllerProvider);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate:
          form.birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Data de aniversário',
      cancelText: 'Cancelar',
      confirmText: 'Ok',
      fieldLabelText: 'Data',
      fieldHintText: 'dd/mm/aaaa',
    );
    if (picked != null) {
      ref.read(clientFormControllerProvider.notifier).setBirthDate(picked);
    }
  }

  Future<void> _submit() async {
    final formNotifier = ref.read(clientFormControllerProvider.notifier);
    final form = ref.read(clientFormControllerProvider);
    final templates = ref.read(clientTemplatesProvider).valueOrNull ?? const [];
    final selected =
        templates.where((t) => t.id == form.templateId).firstOrNull;
    final validation = formNotifier.validate(
      templateStatus: selected?.approvalStatus,
    );
    if (validation != null) {
      formNotifier.setError(validation);
      return;
    }

    formNotifier.setSubmitting(true);
    formNotifier.clearError();

    try {
      final clients = ref.read(clientsControllerProvider.notifier);
      final automaticEnabled = WhatsAppAutomationUi.showAutomaticControls
          ? form.automaticEnabled
          : false;
      if (form.isEditing) {
        await clients.updateClient(
          id: form.editingId!,
          name: form.name,
          phone: form.phone,
          birthDate: form.birthDate!,
          templateId: form.templateId!,
          automaticEnabled: automaticEnabled,
        );
      } else {
        await clients.createClient(
          name: form.name,
          phone: form.phone,
          birthDate: form.birthDate!,
          templateId: form.templateId!,
          automaticEnabled: automaticEnabled,
        );
      }
      if (!mounted) return;
      formNotifier.reset();
      Navigator.of(context).pop();
    } on ClientsFailure catch (failure) {
      formNotifier.setError(failure.message);
    } catch (_) {
      formNotifier.setError(const ClientsUnknownFailure().message);
    } finally {
      formNotifier.setSubmitting(false);
    }
  }

  void _close() {
    if (ref.read(clientFormControllerProvider).isSubmitting) return;
    ref.read(clientFormControllerProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(clientFormControllerProvider);
    final templatesAsync = ref.watch(clientTemplatesProvider);
    final title = form.isEditing ? 'Editar Cliente' : 'Adicionar Cliente';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.cherry,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _FieldLabel('Nome'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              enabled: !form.isSubmitting,
                              textInputAction: TextInputAction.next,
                              onChanged: ref
                                  .read(clientFormControllerProvider.notifier)
                                  .setName,
                              decoration: _inputDecoration(
                                hintText: 'Ex: Maria Silva',
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Telefone'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              enabled: !form.isSubmitting,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [BrazilianPhoneFormatter()],
                              textInputAction: TextInputAction.next,
                              onChanged: ref
                                  .read(clientFormControllerProvider.notifier)
                                  .setPhone,
                              decoration: _inputDecoration(
                                hintText: '(00) 00000-0000',
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel(
                              'Data de aniversário',
                              trailing: Icon(
                                Icons.cake_outlined,
                                size: 18,
                                color: AppColors.cherry,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: form.isSubmitting ? null : _pickDate,
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                  hintText: '',
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                                child: Text(
                                  form.birthDate == null
                                      ? 'dd/mm/aaaa'
                                      : DateFormat('dd/MM/yyyy')
                                          .format(form.birthDate!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: form.birthDate == null
                                            ? AppColors.inkMuted
                                            : AppColors.ink,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Template'),
                            const SizedBox(height: 8),
                            templatesAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: LinearProgressIndicator(
                                  color: AppColors.cherry,
                                ),
                              ),
                              error: (error, _) => Text(
                                error is ClientsFailure
                                    ? error.message
                                    : 'Não foi possível carregar templates.',
                                style: const TextStyle(color: AppColors.danger),
                              ),
                              data: (templates) => _MobileTemplateDropdown(
                                templates: templates,
                                value: form.templateId,
                                enabled: !form.isSubmitting,
                                onChanged: (id) {
                                  if (id != null) {
                                    ref
                                        .read(
                                          clientFormControllerProvider.notifier,
                                        )
                                        .setTemplateId(id);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (WhatsAppAutomationUi.showAutomaticControls)
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Automático'),
                                subtitle: Text(
                                  'Automação via WhatsApp Business em breve',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.inkMuted),
                                ),
                                value: form.automaticEnabled,
                                onChanged: form.isSubmitting
                                    ? null
                                    : (value) {
                                        if (value) {
                                          showWhatsAppComingSoonDialog(
                                            context,
                                          );
                                          return;
                                        }
                                        ref
                                            .read(
                                              clientFormControllerProvider
                                                  .notifier,
                                            )
                                            .setAutomaticEnabled(false);
                                      },
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (form.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        form.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.danger,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: CheeryButton(
                label: 'Salvar',
                icon: Icons.save_outlined,
                expanded: true,
                isLoading: form.isSubmitting,
                onPressed: form.isSubmitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.inkMuted),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cherry, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );
  }
}

class _MobileTemplateDropdown extends StatelessWidget {
  const _MobileTemplateDropdown({
    required this.templates,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final List<TemplateSummary> templates;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        templates.any((t) => t.id == value) ? value : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(effectiveValue ?? 'template-empty'),
      initialValue: effectiveValue,
      onChanged: enabled ? onChanged : null,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.inkMuted),
      decoration: InputDecoration(
        hintText: 'Selecione um template...',
        hintStyle: const TextStyle(color: AppColors.inkMuted),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cherry, width: 1.5),
        ),
      ),
      items: [
        for (final template in templates)
          DropdownMenuItem(
            value: template.id,
            child: Text(
              template.isDefault
                  ? '${template.name} (padrão)'
                  : template.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
