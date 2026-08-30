/// Meta / Cheery template approval lifecycle.
enum TemplateApprovalStatus {
  draft,
  pendingApproval,
  approved,
  rejected;

  static TemplateApprovalStatus fromJson(String? raw) {
    return switch (raw) {
      'pending_approval' => TemplateApprovalStatus.pendingApproval,
      'approved' => TemplateApprovalStatus.approved,
      'rejected' => TemplateApprovalStatus.rejected,
      _ => TemplateApprovalStatus.draft,
    };
  }

  String toJson() => switch (this) {
        TemplateApprovalStatus.draft => 'draft',
        TemplateApprovalStatus.pendingApproval => 'pending_approval',
        TemplateApprovalStatus.approved => 'approved',
        TemplateApprovalStatus.rejected => 'rejected',
      };

  String get label => switch (this) {
        TemplateApprovalStatus.draft => 'Rascunho',
        TemplateApprovalStatus.pendingApproval => 'Aguardando Meta',
        TemplateApprovalStatus.approved => 'Aprovado',
        TemplateApprovalStatus.rejected => 'Rejeitado',
      };

  bool get isApproved => this == TemplateApprovalStatus.approved;
  bool get canEditFreely =>
      this == TemplateApprovalStatus.draft ||
      this == TemplateApprovalStatus.rejected;
  bool get canSubmitForApproval =>
      this == TemplateApprovalStatus.draft ||
      this == TemplateApprovalStatus.rejected;
}

TemplateApprovalStatus templateApprovalStatusFromJson(Object? json) =>
    TemplateApprovalStatus.fromJson(json as String?);

String templateApprovalStatusToJson(TemplateApprovalStatus status) =>
    status.toJson();
