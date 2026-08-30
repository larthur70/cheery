import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/presentation/controllers/client_templates_provider.dart';
import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/template_form_controller.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_controller.dart';
import 'package:cheery/features/templates/presentation/widgets/template_ai_variables_tip_card.dart';
import 'package:cheery/features/templates/presentation/widgets/template_preview_bubble.dart';
import 'package:cheery/features/templates/presentation/widgets/template_variable_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TemplateFormWebScreen extends ConsumerStatefulWidget {
  const TemplateFormWebScreen({this.templateId, super.key});

  final String? templateId;

  @override
  ConsumerState<TemplateFormWebScreen> createState() =>
      _TemplateFormWebScreenState();
}

class _TemplateFormWebScreenState extends ConsumerState<TemplateFormWebScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bodyController;
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bodyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final form = ref.read(templateFormControllerProvider.notifier);
    if (widget.templateId == null || widget.templateId!.isEmpty) {
      form.openCreate();
    } else {
      await form.openEdit(widget.templateId!);
    }
    if (!mounted) return;
    final state = ref.read(templateFormControllerProvider);
    _nameController.text = state.name;
    _bodyController.text = state.friendlyBody;
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formNotifier = ref.read(templateFormControllerProvider.notifier);
    final error = formNotifier.validate();
    if (error != null) {
      formNotifier.setError(error);
      return;
    }

    final form = ref.read(templateFormControllerProvider);
    final meta = formNotifier.convertOrNull();
    if (meta == null) {
      formNotifier.setError('Não foi possível converter as variáveis.');
      return;
    }

    formNotifier.setSubmitting(true);
    try {
      final templates = ref.read(templatesControllerProvider.notifier);
      if (form.isEditing) {
        await templates.updateTemplate(
          id: form.editingId!,
          name: form.name,
          message: meta.message,
          variables: meta.variables,
        );
      } else {
        await templates.createTemplate(
          name: form.name,
          message: meta.message,
          variables: meta.variables,
        );
      }
      ref.invalidate(clientTemplatesProvider);
      if (!mounted) return;
      context.go(AppRoutes.templates);
    } on TemplatesFailure catch (failure) {
      formNotifier.setError(failure.message);
    } finally {
      formNotifier.setSubmitting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(templateFormControllerProvider);
    final companyName =
        ref.watch(currentProfileProvider).valueOrNull?.companyName;
    final title = form.isEditing ? 'Editar Template' : 'Novo Template';
    final preview = form.previewText(companyName: companyName);

    if (!_initialized || form.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: CheeryLoading(message: 'Carregando template...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;

          final formColumn = _FormColumn(
            nameController: _nameController,
            bodyController: _bodyController,
            form: form,
            onNameChanged: (value) => ref
                .read(templateFormControllerProvider.notifier)
                .setName(value),
            onBodyChanged: (value) => ref
                .read(templateFormControllerProvider.notifier)
                .setFriendlyBody(value),
            onInsertVariable: (def) {
              final notifier =
                  ref.read(templateFormControllerProvider.notifier);
              final selection = _bodyController.selection;
              final text = _bodyController.text;
              final start =
                  selection.isValid ? selection.start : text.length;
              final end = selection.isValid ? selection.end : text.length;
              final next = text.replaceRange(start, end, def.token);
              _bodyController.value = TextEditingValue(
                text: next,
                selection: TextSelection.collapsed(
                  offset: start + def.token.length,
                ),
              );
              notifier.setFriendlyBody(next);
            },
            onCancel: () => context.go(AppRoutes.templates),
            onSave: form.isSubmitting ? null : _save,
          );

          final previewColumn = _PreviewColumn(
            previewText: preview,
            companyLabel: companyName?.trim().isNotEmpty == true
                ? companyName!.trim()
                : 'Nome da empresa',
          );

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => context.go(AppRoutes.templates),
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Templates'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.inkMuted,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.inkMuted,
                          ),
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.cherry),
                          ),
                          const Spacer(),
                          CheeryButton(
                            label: 'Cancelar',
                            variant: CheeryButtonVariant.outlined,
                            onPressed: () => context.go(AppRoutes.templates),
                          ),
                          const SizedBox(width: 12),
                          CheeryButton(
                            label: 'Salvar',
                            icon: Icons.save_outlined,
                            isLoading: form.isSubmitting,
                            onPressed: form.isSubmitting ? null : _save,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.cherry,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 24),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: formColumn),
                            const SizedBox(width: 28),
                            Expanded(flex: 2, child: previewColumn),
                          ],
                        )
                      else ...[
                        formColumn,
                        const SizedBox(height: 28),
                        previewColumn,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormColumn extends StatelessWidget {
  const _FormColumn({
    required this.nameController,
    required this.bodyController,
    required this.form,
    required this.onNameChanged,
    required this.onBodyChanged,
    required this.onInsertVariable,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController bodyController;
  final TemplateFormState form;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onBodyChanged;
  final ValueChanged<TemplateVariableDef> onInsertVariable;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TemplateAiVariablesTipCard(),
        const SizedBox(height: 20),
        Text(
          'Nome do Template',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          onChanged: onNameChanged,
          decoration: const InputDecoration(
            hintText: 'Ex.: Boas Vindas Cliente',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Mensagem',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Variáveis disponíveis:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 8),
        TemplateVariableChips(onInsert: onInsertVariable),
        const SizedBox(height: 12),
        TextField(
          controller: bodyController,
          onChanged: onBodyChanged,
          maxLines: 10,
          maxLength: TemplateBodyConverter.maxMessageLength,
          buildCounter: (
            context, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) {
            return Text(
              '$currentLength / $maxLength caracteres',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
            );
          },
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            hintText: 'Escreva a mensagem do template…',
          ),
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
        const SizedBox(height: 20),
        Row(
          children: [
            CheeryButton(
              label: 'Cancelar',
              variant: CheeryButtonVariant.outlined,
              onPressed: onCancel,
            ),
            const SizedBox(width: 12),
            CheeryButton(
              label: 'Salvar',
              icon: Icons.save_outlined,
              isLoading: form.isSubmitting,
              onPressed: onSave,
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({
    required this.previewText,
    required this.companyLabel,
  });

  final String previewText;
  final String companyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pré-visualização ao vivo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        TemplatePreviewBubble(
          text: previewText,
          companyLabel: companyLabel,
        ),
      ],
    );
  }
}
