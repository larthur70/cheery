/// Editable draft for one selected device contact during review.
class ContactImportDraft {
  const ContactImportDraft({
    required this.contactId,
    required this.name,
    required this.phone,
    required this.phoneKey,
    this.birthDate,
    this.alreadyRegistered = false,
    this.duplicateInSelection = false,
    this.excluded = false,
    this.skippedForPlanLimit = false,
  });

  final String contactId;
  final String name;

  /// Normalized Brazilian display/storage phone.
  final String phone;

  /// Uniqueness key (`55`…). Empty when phone is invalid.
  final String phoneKey;

  final DateTime? birthDate;
  final bool alreadyRegistered;
  final bool duplicateInSelection;

  /// User chose to drop this contact from the import batch.
  final bool excluded;

  /// Otherwise ready, but exceeds Free plan remaining capacity.
  final bool skippedForPlanLimit;

  static const planLimitSkipMessage =
      'Não será importado: limite de clientes do plano Free';

  bool get hasValidPhone => phoneKey.isNotEmpty;

  /// Fields are complete and not blocked by duplicate / registration / exclude.
  bool get isFieldReady =>
      !excluded &&
      !alreadyRegistered &&
      !duplicateInSelection &&
      name.trim().isNotEmpty &&
      hasValidPhone &&
      birthDate != null;

  /// Will actually be imported (field-ready and within plan capacity).
  bool get isReady => isFieldReady && !skippedForPlanLimit;

  bool get isPending => !excluded && !isReady;

  String? get pendingReason {
    if (excluded) return null;
    if (alreadyRegistered) return 'Já cadastrado';
    if (duplicateInSelection) return 'Telefone duplicado na seleção';
    if (name.trim().isEmpty) return 'Nome obrigatório';
    if (!hasValidPhone) return 'Telefone inválido';
    if (birthDate == null) return 'Data de aniversário pendente';
    if (skippedForPlanLimit) return planLimitSkipMessage;
    return null;
  }

  ContactImportDraft copyWith({
    String? name,
    DateTime? birthDate,
    bool clearBirthDate = false,
    bool? alreadyRegistered,
    bool? duplicateInSelection,
    bool? excluded,
    bool? skippedForPlanLimit,
  }) {
    return ContactImportDraft(
      contactId: contactId,
      name: name ?? this.name,
      phone: phone,
      phoneKey: phoneKey,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      alreadyRegistered: alreadyRegistered ?? this.alreadyRegistered,
      duplicateInSelection: duplicateInSelection ?? this.duplicateInSelection,
      excluded: excluded ?? this.excluded,
      skippedForPlanLimit: skippedForPlanLimit ?? this.skippedForPlanLimit,
    );
  }
}
