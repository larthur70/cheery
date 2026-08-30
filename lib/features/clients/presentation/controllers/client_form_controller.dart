import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_rules.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientFormState {
  const ClientFormState({
    this.editingId,
    this.name = '',
    this.phone = '',
    this.birthDate,
    this.templateId,
    this.automaticEnabled = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final String? editingId;
  final String name;
  final String phone;
  final DateTime? birthDate;
  final String? templateId;
  final bool automaticEnabled;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isEditing => editingId != null;

  ClientFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? name,
    String? phone,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? templateId,
    bool clearTemplateId = false,
    bool? automaticEnabled,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return ClientFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
      automaticEnabled: automaticEnabled ?? this.automaticEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final clientFormControllerProvider =
    NotifierProvider<ClientFormController, ClientFormState>(
  ClientFormController.new,
);

class ClientFormController extends Notifier<ClientFormState> {
  @override
  ClientFormState build() => const ClientFormState();

  Future<void> openCreate() async {
    final repository = ref.read(templatesRepositoryProvider);
    if (repository == null) {
      state = state.copyWith(
        errorMessage: const ClientsNotReadyFailure().message,
      );
      return;
    }

    try {
      final defaultTemplate = await repository.ensureDefaultTemplate();
      state = ClientFormState(
        templateId: defaultTemplate.id,
        automaticEnabled: false,
      );
    } on TemplatesFailure catch (failure) {
      state = state.copyWith(errorMessage: failure.message);
    }
  }

  void openEdit(Client client) {
    state = ClientFormState(
      editingId: client.id,
      name: client.name,
      phone: client.phone,
      birthDate: client.birthDate,
      templateId: client.templateId,
      automaticEnabled: client.automaticEnabled,
    );
  }

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);

  void setPhone(String value) =>
      state = state.copyWith(phone: value, clearError: true);

  void setBirthDate(DateTime value) =>
      state = state.copyWith(birthDate: value, clearError: true);

  void setTemplateId(String value) =>
      state = state.copyWith(templateId: value, clearError: true);

  void setAutomaticEnabled(bool value) =>
      state = state.copyWith(automaticEnabled: value, clearError: true);

  void setError(String message) => state = state.copyWith(errorMessage: message);

  void clearError() => state = state.copyWith(clearError: true);

  void setSubmitting(bool value) =>
      state = state.copyWith(isSubmitting: value);

  /// Returns null when valid, otherwise an error message.
  String? validate({TemplateApprovalStatus? templateStatus}) {
    if (state.name.trim().isEmpty) {
      return 'Informe o nome do cliente.';
    }
    if (state.phone.trim().isEmpty) {
      return 'Informe o telefone.';
    }
    if (WhatsAppPhone.normalize(state.phone) == null) {
      return 'Informe um telefone válido com DDD (10 ou 11 dígitos).';
    }
    if (state.birthDate == null) {
      return 'Informe a data de aniversário.';
    }
    if (state.templateId == null || state.templateId!.isEmpty) {
      return 'Selecione um template.';
    }

    if (!WhatsAppAutomationUi.showAutomaticControls) {
      return null;
    }

    final profile = ref.read(currentProfileProvider).valueOrNull;
    return WhatsAppAutomationRules.validateAutomaticClient(
      automaticEnabled: state.automaticEnabled,
      isPro: profile?.isPro ?? false,
      whatsappConnected: profile?.whatsappConnected ?? false,
      status: profile?.whatsappIntegrationStatus ??
          WhatsAppIntegrationStatus.disconnected,
      templateStatus: templateStatus,
    );
  }

  void reset() => state = const ClientFormState();
}
