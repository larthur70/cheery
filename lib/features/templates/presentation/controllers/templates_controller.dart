import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/presentation/controllers/client_templates_provider.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/domain/templates_repository.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templatesControllerProvider =
    AsyncNotifierProvider<TemplatesController, List<Template>>(
  TemplatesController.new,
);

class TemplatesController extends AsyncNotifier<List<Template>> {
  TemplatesRepository get _repository {
    final repository = ref.read(templatesRepositoryProvider);
    if (repository == null) {
      throw const TemplatesNotReadyFailure();
    }
    return repository;
  }

  void _invalidateClientPicker() {
    ref.invalidate(clientTemplatesProvider);
  }

  void _assertCanCreateCustomTemplate() {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile != null && profile.isPro) return;
    final currentCount = state.valueOrNull?.length ?? 0;
    ref.read(analyticsServiceProvider).trackLimiteAtingido(
          tipo: LimiteAnalyticsTipo.templates,
          valorAtual: currentCount,
        );
    throw TemplatesPlanLimitFailure();
  }

  bool get _duranteOnboarding {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    return profile != null && !profile.onboardingCompleted;
  }

  @override
  Future<List<Template>> build() async {
    final repository = ref.watch(templatesRepositoryProvider);
    if (repository == null) return const [];

    try {
      await repository.ensureDefaultTemplate();
    } on TemplatesFailure {
      // Cached templates (or an empty list) still render without a full-page error.
    }
    return repository.listTemplates();
  }

  Future<void> refresh() async {
    try {
      await _repository.ensureDefaultTemplate();
      final list = await _repository.listTemplates();
      state = AsyncData(list);
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<Template> createTemplate({
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    _assertCanCreateCustomTemplate();
    final duranteOnboarding = _duranteOnboarding;
    final created = await _repository.createTemplate(
      name: name,
      message: message,
      variables: variables,
    );
    await refresh();
    _invalidateClientPicker();
    ref.read(analyticsServiceProvider).trackTemplateCriado(
          templateId: created.id,
          duranteOnboarding: duranteOnboarding,
        );
    return created;
  }

  Future<Template> updateTemplate({
    required String id,
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    final updated = await _repository.updateTemplate(
      id: id,
      name: name,
      message: message,
      variables: variables,
    );
    await refresh();
    _invalidateClientPicker();
    ref.read(analyticsServiceProvider).trackTemplateEditado(
          templateId: updated.id,
        );
    return updated;
  }

  Future<void> deleteTemplate(String id) async {
    await _repository.deleteTemplate(id);
    await refresh();
    _invalidateClientPicker();
  }

  Future<Template> submitForApproval(String id) async {
    final submitted = await _repository.submitForApproval(id);
    await refresh();
    _invalidateClientPicker();
    return submitted;
  }

  Future<Template> syncApprovalStatus(String id) async {
    final synced = await _repository.syncApprovalStatus(id);
    await refresh();
    _invalidateClientPicker();
    return synced;
  }
}
