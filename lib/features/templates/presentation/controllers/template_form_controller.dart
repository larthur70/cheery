import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateFormState {
  const TemplateFormState({
    this.editingId,
    this.name = '',
    this.friendlyBody = '',
    this.errorMessage,
    this.isSubmitting = false,
    this.isLoading = false,
  });

  final String? editingId;
  final String name;

  /// Friendly UI body with `[Nome do cliente]` tokens.
  final String friendlyBody;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isLoading;

  bool get isEditing => editingId != null;

  /// Live preview using catalog samples, optionally overriding company name.
  String previewText({String? companyName}) {
    return TemplateBodyConverter.previewFriendly(
      friendlyBody,
      sampleOverrides: companyName == null || companyName.trim().isEmpty
          ? null
          : {TemplateVariableCatalog.companyNameKey: companyName.trim()},
    );
  }

  TemplateFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? name,
    String? friendlyBody,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
    bool? isLoading,
  }) {
    return TemplateFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      name: name ?? this.name,
      friendlyBody: friendlyBody ?? this.friendlyBody,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final templateFormControllerProvider =
    NotifierProvider<TemplateFormController, TemplateFormState>(
  TemplateFormController.new,
);

class TemplateFormController extends Notifier<TemplateFormState> {
  static const _newDefaultBody =
      'Olá [Nome do cliente]! Passando para desejar um feliz aniversário. — Equipe [Nome da empresa]';

  @override
  TemplateFormState build() => const TemplateFormState();

  void openCreate() {
    state = const TemplateFormState(friendlyBody: _newDefaultBody);
  }

  Future<void> openEdit(String id) async {
    final repository = ref.read(templatesRepositoryProvider);
    if (repository == null) {
      state = state.copyWith(
        errorMessage: const TemplatesNotReadyFailure().message,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final template = await repository.getById(id);
      loadTemplate(template);
    } on TemplatesFailure catch (failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: const TemplatesUnknownFailure().message,
      );
    }
  }

  void loadTemplate(Template template) {
    state = TemplateFormState(
      editingId: template.id,
      name: template.name,
      friendlyBody: TemplateBodyConverter.toFriendly(
        template.message,
        template.variables,
      ),
    );
  }

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);

  void setFriendlyBody(String value) =>
      state = state.copyWith(friendlyBody: value, clearError: true);

  void insertVariable(String token) {
    final current = state.friendlyBody;
    final next = current.isEmpty ? token : '$current$token';
    state = state.copyWith(friendlyBody: next, clearError: true);
  }

  void insertCatalogVariable(TemplateVariableDef def) {
    insertVariable(def.token);
  }

  void setError(String message) =>
      state = state.copyWith(errorMessage: message);

  void clearError() => state = state.copyWith(clearError: true);

  void setSubmitting(bool value) =>
      state = state.copyWith(isSubmitting: value);

  /// Returns null when valid, otherwise an error message.
  String? validate() {
    if (state.name.trim().isEmpty) {
      return 'Informe o nome do template.';
    }
    if (state.friendlyBody.trim().isEmpty) {
      return 'Informe a mensagem do template.';
    }
    if (state.friendlyBody.length > TemplateBodyConverter.maxMessageLength) {
      return 'A mensagem deve ter no máximo ${TemplateBodyConverter.maxMessageLength} caracteres.';
    }
    try {
      TemplateBodyConverter.toMeta(state.friendlyBody);
    } on FormatException catch (error) {
      return error.message;
    }
    return null;
  }

  TemplateMetaConversion? convertOrNull() {
    try {
      return TemplateBodyConverter.toMeta(state.friendlyBody);
    } on FormatException {
      return null;
    }
  }

  void reset() => state = const TemplateFormState();
}
