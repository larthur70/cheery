import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/import_contacts/data/device_contacts_repository.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_draft.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_failure.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_plan_limit_applier.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_step.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_summary.dart';
import 'package:cheery/features/import_contacts/domain/device_contact.dart';
import 'package:cheery/features/import_contacts/presentation/controllers/import_contacts_state.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceContactsRepositoryProvider = Provider<DeviceContactsRepository>(
  (ref) => DeviceContactsRepository.platform(),
);

final importContactsControllerProvider = NotifierProvider.autoDispose<
    ImportContactsController, ImportContactsState>(
  ImportContactsController.new,
);

class ImportContactsController extends AutoDisposeNotifier<ImportContactsState> {
  @override
  ImportContactsState build() {
    Future.microtask(loadContacts);
    return const ImportContactsState(isLoadingContacts: true);
  }

  DeviceContactsRepository get _repository =>
      ref.read(deviceContactsRepositoryProvider);

  Future<void> loadContacts() async {
    state = state.copyWith(
      isLoadingContacts: true,
      permissionDenied: false,
      permissionPermanentlyDenied: false,
      clearError: true,
    );

    try {
      await _repository.requestPermission();
      final contacts = await _repository.loadContacts();

      try {
        await ref.read(clientsControllerProvider.notifier).refresh();
      } catch (_) {
        state = state.copyWith(
          isLoadingContacts: false,
          errorMessage:
              'Não foi possível atualizar a lista de clientes. '
              'Verifique a conexão e tente novamente.',
        );
        return;
      }

      state = state.copyWith(
        isLoadingContacts: false,
        contacts: contacts,
        permissionDenied: false,
        permissionPermanentlyDenied: false,
        clearError: true,
      );
    } on ContactPermissionPermanentlyDeniedFailure catch (error) {
      state = state.copyWith(
        isLoadingContacts: false,
        permissionDenied: true,
        permissionPermanentlyDenied: true,
        errorMessage: error.message,
      );
    } on ContactPermissionDeniedFailure catch (error) {
      state = state.copyWith(
        isLoadingContacts: false,
        permissionDenied: true,
        permissionPermanentlyDenied: false,
        errorMessage: error.message,
      );
    } on ContactImportFailure catch (error) {
      state = state.copyWith(
        isLoadingContacts: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingContacts: false,
        errorMessage: const ContactUnknownFailure().message,
      );
    }
  }

  Future<void> openSettings() => _repository.openSettings();

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleContact(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (!next.add(id)) {
      next.remove(id);
    }
    state = state.copyWith(selectedIds: next, clearError: true);
  }

  void selectAllFiltered() {
    final next = Set<String>.from(state.selectedIds);
    for (final contact in state.filteredContacts) {
      next.add(contact.id);
    }
    state = state.copyWith(selectedIds: next, clearError: true);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {}, clearError: true);
  }

  void goToReview() {
    if (state.selectedIds.isEmpty) {
      state = state.copyWith(
        errorMessage: const ContactNoSelectionFailure().message,
      );
      return;
    }

    final drafts = _applyPlanLimit(
      _buildDrafts(
        selectedIds: state.selectedIds,
        existingKeys:
            ref.read(clientsControllerProvider.notifier).existingPhoneKeys,
      ),
    );

    state = state.copyWith(
      drafts: drafts,
      step: ContactImportStep.review,
      clearError: true,
      clearSummary: true,
      clearAuthorization: true,
    );
  }

  void setAuthorizationConfirmed(bool value) {
    state = state.copyWith(authorizationConfirmed: value, clearError: true);
  }

  void goBack() {
    switch (state.step) {
      case ContactImportStep.select:
        break;
      case ContactImportStep.review:
        state = state.copyWith(
          step: ContactImportStep.select,
          clearError: true,
        );
      case ContactImportStep.confirmation:
        break;
    }
  }

  void updateDraftBirthDate(String contactId, DateTime? birthDate) {
    final drafts = state.drafts.map((draft) {
      if (draft.contactId != contactId) return draft;
      if (birthDate == null) {
        return draft.copyWith(clearBirthDate: true);
      }
      return draft.copyWith(birthDate: birthDate);
    }).toList();
    state = state.copyWith(
      drafts: _applyPlanLimit(drafts),
      clearError: true,
    );
  }

  void excludeDraft(String contactId) {
    final drafts = state.drafts
        .map(
          (draft) => draft.contactId == contactId
              ? draft.copyWith(excluded: true)
              : draft,
        )
        .toList();
    state = state.copyWith(
      drafts: _applyPlanLimit(drafts),
      clearError: true,
    );
  }

  void restoreDraft(String contactId) {
    final drafts = state.drafts
        .map(
          (draft) => draft.contactId == contactId
              ? draft.copyWith(excluded: false)
              : draft,
        )
        .toList();
    state = state.copyWith(
      drafts: _applyPlanLimit(drafts),
      clearError: true,
    );
  }

  void reset() {
    state = const ImportContactsState(isLoadingContacts: true);
    loadContacts();
  }

  Future<void> confirmImport() async {
    if (!state.authorizationConfirmed) {
      state = state.copyWith(
        errorMessage:
            'Confirme que você tem autorização desses contatos para receber mensagem.',
      );
      return;
    }
    if (state.readyDrafts.isEmpty) {
      state = state.copyWith(
        errorMessage: const ContactNoReadyRowsFailure().message,
      );
      return;
    }

    state = state.copyWith(isImporting: true, clearError: true);

    try {
      try {
        await ref.read(clientsControllerProvider.notifier).refresh();
      } catch (_) {
        state = state.copyWith(
          isImporting: false,
          errorMessage:
              'Não foi possível atualizar a lista de clientes. '
              'Verifique a conexão e tente novamente.',
        );
        return;
      }

      final existingKeys =
          ref.read(clientsControllerProvider.notifier).existingPhoneKeys;
      final refreshed = _applyPlanLimit(
        state.drafts.map((draft) {
          final key = draft.phoneKey;
          final already = key.isNotEmpty && existingKeys.contains(key);
          return draft.copyWith(alreadyRegistered: already);
        }).toList(),
      );

      state = state.copyWith(drafts: refreshed);

      final ready = state.readyDrafts;
      final skipped = state.drafts.where((d) => !d.isReady).length;
      if (ready.isEmpty) {
        if (state.planLimitSkippedCount > 0) {
          ref.read(analyticsServiceProvider).trackLimiteAtingido(
                tipo: LimiteAnalyticsTipo.clientes,
                valorAtual:
                    ref.read(clientsControllerProvider.notifier).clientCount,
              );
        }
        state = state.copyWith(
          isImporting: false,
          errorMessage: state.planLimitSkippedCount > 0
              ? (StoreCompliance.hideExternalPayments
                  ? StoreCompliance.limitReached
                  : 'Nenhum contato cabe no limite do plano Free. '
                      'Faça upgrade para Pro ou reduza a seleção.')
              : const ContactNoReadyRowsFailure().message,
        );
        return;
      }

      final templateId = await _defaultTemplateId();
      final payload = <
          ({
            String name,
            String phone,
            DateTime birthDate,
            String templateId,
            bool automaticEnabled,
          })>[];
      final seenKeys = <String>{};

      for (final draft in ready) {
        final birthDate = draft.birthDate;
        if (birthDate == null) continue;
        final key = WhatsAppPhone.uniquenessKey(draft.phone) ?? draft.phoneKey;
        if (key.isNotEmpty && !seenKeys.add(key)) continue;
        payload.add((
          name: draft.name.trim(),
          phone: draft.phone,
          birthDate: birthDate,
          templateId: templateId,
          automaticEnabled: false,
        ));
      }

      if (payload.isEmpty) {
        state = state.copyWith(
          isImporting: false,
          errorMessage: const ContactNoReadyRowsFailure().message,
        );
        return;
      }

      final created = await ref
          .read(clientsControllerProvider.notifier)
          .createClientsBatch(payload);

      final duranteOnboarding =
          !(ref.read(currentProfileProvider).valueOrNull?.onboardingCompleted ??
              true);
      ref.read(analyticsServiceProvider).trackImportCompleted(
            origem: ImportAnalyticsOrigem.contatosTelefone,
            quantidade: created.length,
            duranteOnboarding: duranteOnboarding,
          );

      state = state.copyWith(
        isImporting: false,
        summary: ContactImportSummary(
          imported: created.length,
          skipped: skipped + (ready.length - payload.length),
          errors: 0,
        ),
        step: ContactImportStep.confirmation,
      );
    } on ClientsFailure catch (error) {
      state = state.copyWith(
        isImporting: false,
        summary: ContactImportSummary(
          imported: 0,
          skipped: state.drafts.where((d) => !d.isReady).length,
          errors: state.readyDrafts.length,
          errorMessage: error.message,
        ),
        step: ContactImportStep.confirmation,
      );
    } on ContactImportFailure catch (error) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isImporting: false,
        summary: ContactImportSummary(
          imported: 0,
          skipped: state.drafts.where((d) => !d.isReady).length,
          errors: state.readyDrafts.length,
          errorMessage: const ContactUnknownFailure().message,
        ),
        step: ContactImportStep.confirmation,
      );
    }
  }

  List<ContactImportDraft> _buildDrafts({
    required Set<String> selectedIds,
    required Set<String> existingKeys,
  }) {
    final byId = {
      for (final contact in state.contacts) contact.id: contact,
    };

    final selected = selectedIds
        .map((id) => byId[id])
        .whereType<DeviceContact>()
        .toList()
      ..sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

    final firstOwnerByKey = <String, String>{};
    final drafts = <ContactImportDraft>[];

    for (final contact in selected) {
      final key = contact.phoneNormalized;
      var duplicateInSelection = false;
      if (key.isNotEmpty) {
        final firstId = firstOwnerByKey[key];
        if (firstId == null) {
          firstOwnerByKey[key] = contact.id;
        } else if (firstId != contact.id) {
          duplicateInSelection = true;
        }
      }

      drafts.add(
        ContactImportDraft(
          contactId: contact.id,
          name: contact.displayName,
          phone: contact.storedPhone,
          phoneKey: key,
          birthDate: contact.birthDate,
          alreadyRegistered: key.isNotEmpty && existingKeys.contains(key),
          duplicateInSelection: duplicateInSelection,
        ),
      );
    }

    return drafts;
  }

  List<ContactImportDraft> _applyPlanLimit(List<ContactImportDraft> drafts) {
    return ContactImportPlanLimitApplier.apply(
      drafts: drafts,
      currentClientCount:
          ref.read(clientsControllerProvider.notifier).clientCount,
      maxClients: ContactImportPlanLimitApplier.maxClientsForPlan(
        isPro: ref.read(currentProfileProvider).valueOrNull?.isPro ?? false,
      ),
    );
  }

  Future<String> _defaultTemplateId() async {
    final repository = ref.read(templatesRepositoryProvider);
    if (repository == null) {
      throw const ContactNotReadyFailure();
    }
    await repository.ensureDefaultTemplate();
    final summaries = await repository.listSummaries();
    if (summaries.isEmpty) {
      throw const ContactNotReadyFailure(
        'Nenhum template disponível. Crie um template padrão primeiro.',
      );
    }
    final defaultTemplate = summaries.firstWhere(
      (t) => t.isDefault,
      orElse: () => summaries.first,
    );
    return defaultTemplate.id;
  }
}
