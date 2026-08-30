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

Future<void> showClientFormDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const ClientFormPanel(),
        ),
      );
    },
  );
}

/// Web dialog form for create/edit client.
class ClientFormPanel extends ConsumerStatefulWidget {
  const ClientFormPanel({super.key});

  @override
  ConsumerState<ClientFormPanel> createState() => _ClientFormPanelState();
}

class _ClientFormPanelState extends ConsumerState<ClientFormPanel> {
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

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(clientFormControllerProvider);
    final templatesAsync = ref.watch(clientTemplatesProvider);
    final title = form.isEditing ? 'Editar cliente' : 'Adicionar cliente';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: form.isSubmitting
                    ? null
                    : () {
                        ref.read(clientFormControllerProvider.notifier).reset();
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            enabled: !form.isSubmitting,
            textInputAction: TextInputAction.next,
            onChanged: ref.read(clientFormControllerProvider.notifier).setName,
            decoration: _fieldDecoration('Nome'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            enabled: !form.isSubmitting,
            keyboardType: TextInputType.phone,
            inputFormatters: [BrazilianPhoneFormatter()],
            textInputAction: TextInputAction.next,
            onChanged: ref.read(clientFormControllerProvider.notifier).setPhone,
            decoration: _fieldDecoration('Telefone'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: form.isSubmitting ? null : _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: _fieldDecoration('Data de aniversário').copyWith(
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                form.birthDate == null
                    ? 'Selecionar data'
                    : DateFormat('dd/MM/yyyy').format(form.birthDate!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: form.birthDate == null
                          ? AppColors.inkMuted
                          : AppColors.ink,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          templatesAsync.when(
            loading: () =>
                const LinearProgressIndicator(color: AppColors.cherry),
            error: (error, _) => Text(
              error is ClientsFailure
                  ? error.message
                  : 'Não foi possível carregar templates.',
              style: const TextStyle(color: AppColors.danger),
            ),
            data: (templates) => _TemplateDropdown(
              templates: templates,
              value: form.templateId,
              enabled: !form.isSubmitting,
              automaticEnabled: form.automaticEnabled,
              onChanged: (id) {
                if (id != null) {
                  ref
                      .read(clientFormControllerProvider.notifier)
                      .setTemplateId(id);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          if (WhatsAppAutomationUi.showAutomaticControls)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Automático'),
              subtitle: Text(
                'Automação via WhatsApp Business em breve',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              value: form.automaticEnabled,
              onChanged: form.isSubmitting
                  ? null
                  : (value) {
                      if (value) {
                        showWhatsAppComingSoonDialog(context);
                        return;
                      }
                      ref
                          .read(clientFormControllerProvider.notifier)
                          .setAutomaticEnabled(false);
                    },
            ),
          if (form.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              form.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
            ),
          ],
          const SizedBox(height: 24),
          CheeryButton(
            label: form.isEditing ? 'Salvar' : 'Adicionar',
            expanded: true,
            isLoading: form.isSubmitting,
            onPressed: form.isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: AppColors.surfaceElevated,
    );
  }
}

class _TemplateDropdown extends StatelessWidget {
  const _TemplateDropdown({
    required this.templates,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.automaticEnabled,
  });

  final List<TemplateSummary> templates;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool automaticEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = templates.any((t) => t.id == value) ? value : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(effectiveValue ?? 'template-empty'),
      initialValue: effectiveValue,
      onChanged: enabled ? onChanged : null,
      decoration: const InputDecoration(
        labelText: 'Template',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: AppColors.surfaceElevated,
      ),
      items: [
        for (final template in templates)
          DropdownMenuItem(
            value: template.id,
            child: Text(
              [
                if (template.isDefault)
                  '${template.name} (padrão)'
                else
                  template.name,
                if (automaticEnabled && !template.approvalStatus.isApproved)
                  ' — não aprovado',
                if (template.approvalStatus.isApproved) ' — aprovado',
              ].join(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
