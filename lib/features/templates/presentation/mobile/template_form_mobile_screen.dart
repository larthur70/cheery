import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/presentation/controllers/client_templates_provider.dart';
import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/template_form_controller.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_controller.dart';
import 'package:cheery/features/templates/presentation/widgets/template_ai_variables_tip_card.dart';
import 'package:cheery/features/templates/presentation/widgets/template_preview_bubble.dart';
import 'package:cheery/features/templates/presentation/widgets/template_variable_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TemplateFormMobileScreen extends ConsumerStatefulWidget {
  const TemplateFormMobileScreen({this.templateId, super.key});

  final String? templateId;

  @override
  ConsumerState<TemplateFormMobileScreen> createState() =>
      _TemplateFormMobileScreenState();
}

class _TemplateFormMobileScreenState
    extends ConsumerState<TemplateFormMobileScreen> {
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

  void _insertToken(String token) {
    final selection = _bodyController.selection;
    final text = _bodyController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, token);
    _bodyController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    ref.read(templateFormControllerProvider.notifier).setFriendlyBody(next);
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.cherry,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.templates),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.cherry,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
              controller: _nameController,
              onChanged: ref
                  .read(templateFormControllerProvider.notifier)
                  .setName,
              decoration: const InputDecoration(
                hintText: 'Ex.: Aniversário B2B Padrão',
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
            TemplateVariableChips(
              onInsert: (def) => _insertToken(def.token),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              onChanged: ref
                  .read(templateFormControllerProvider.notifier)
                  .setFriendlyBody,
              maxLines: 8,
              maxLength: TemplateBodyConverter.maxMessageLength,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                hintText: 'Escreva a mensagem do template…',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TemplatePreviewBubble(
              text: preview,
              companyLabel: companyName?.trim().isNotEmpty == true
                  ? companyName!.trim()
                  : 'Nome da empresa',
              compact: true,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CheeryButton(
                    label: 'Cancelar',
                    variant: CheeryButtonVariant.outlined,
                    expanded: true,
                    onPressed: () => context.go(AppRoutes.templates),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CheeryButton(
                    label: 'Salvar',
                    icon: Icons.save_outlined,
                    expanded: true,
                    isLoading: form.isSubmitting,
                    onPressed: form.isSubmitting ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
