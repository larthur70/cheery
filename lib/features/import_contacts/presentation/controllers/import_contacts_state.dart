import 'package:cheery/features/import_contacts/domain/contact_import_draft.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_step.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_summary.dart';
import 'package:cheery/features/import_contacts/domain/device_contact.dart';

class ImportContactsState {
  const ImportContactsState({
    this.step = ContactImportStep.select,
    this.contacts = const [],
    this.selectedIds = const {},
    this.drafts = const [],
    this.searchQuery = '',
    this.isLoadingContacts = false,
    this.isImporting = false,
    this.authorizationConfirmed = false,
    this.permissionDenied = false,
    this.permissionPermanentlyDenied = false,
    this.errorMessage,
    this.summary,
  });

  final ContactImportStep step;
  final List<DeviceContact> contacts;
  final Set<String> selectedIds;
  final List<ContactImportDraft> drafts;
  final String searchQuery;
  final bool isLoadingContacts;
  final bool isImporting;
  final bool authorizationConfirmed;
  final bool permissionDenied;
  final bool permissionPermanentlyDenied;
  final String? errorMessage;
  final ContactImportSummary? summary;

  List<DeviceContact> get filteredContacts {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return contacts;
    final qDigits = searchQuery.replaceAll(RegExp(r'\D'), '');
    return contacts.where((contact) {
      final nameMatch = contact.displayName.toLowerCase().contains(q);
      final phoneMatch = contact.storedPhone.toLowerCase().contains(q) ||
          (qDigits.isNotEmpty &&
              contact.phoneNormalized.contains(qDigits));
      return nameMatch || phoneMatch;
    }).toList();
  }

  List<ContactImportDraft> get readyDrafts =>
      drafts.where((d) => d.isReady).toList();

  List<ContactImportDraft> get pendingDrafts =>
      drafts.where((d) => d.isPending).toList();

  List<ContactImportDraft> get planLimitSkippedDrafts =>
      drafts.where((d) => d.skippedForPlanLimit).toList();

  List<ContactImportDraft> get excludedDrafts =>
      drafts.where((d) => d.excluded).toList();

  int get planLimitSkippedCount => planLimitSkippedDrafts.length;

  int get selectedCount => selectedIds.length;

  bool get canImport =>
      readyDrafts.isNotEmpty && authorizationConfirmed && !isImporting;

  ImportContactsState copyWith({
    ContactImportStep? step,
    List<DeviceContact>? contacts,
    Set<String>? selectedIds,
    List<ContactImportDraft>? drafts,
    String? searchQuery,
    bool? isLoadingContacts,
    bool? isImporting,
    bool? authorizationConfirmed,
    bool? permissionDenied,
    bool? permissionPermanentlyDenied,
    String? errorMessage,
    ContactImportSummary? summary,
    bool clearError = false,
    bool clearSummary = false,
    bool clearAuthorization = false,
  }) {
    return ImportContactsState(
      step: step ?? this.step,
      contacts: contacts ?? this.contacts,
      selectedIds: selectedIds ?? this.selectedIds,
      drafts: drafts ?? this.drafts,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      isImporting: isImporting ?? this.isImporting,
      authorizationConfirmed: clearAuthorization
          ? false
          : (authorizationConfirmed ?? this.authorizationConfirmed),
      permissionDenied: permissionDenied ?? this.permissionDenied,
      permissionPermanentlyDenied:
          permissionPermanentlyDenied ?? this.permissionPermanentlyDenied,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: clearSummary ? null : (summary ?? this.summary),
    );
  }
}
