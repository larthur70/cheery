import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'template.freezed.dart';
part 'template.g.dart';

@freezed
abstract class Template with _$Template {
  const factory Template({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    /// Meta-format body with `{{1}}`, `{{2}}`, …
    required String message,
    /// Ordered variable keys matching Meta placeholder indices.
    @Default([]) List<String> variables,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(
      name: 'approval_status',
      fromJson: templateApprovalStatusFromJson,
      toJson: templateApprovalStatusToJson,
    )
    @Default(TemplateApprovalStatus.draft)
    TemplateApprovalStatus approvalStatus,
    @JsonKey(name: 'meta_template_name') String? metaTemplateName,
    @JsonKey(name: 'meta_template_id') String? metaTemplateId,
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'rejected_reason') String? rejectedReason,
    @JsonKey(name: 'meta_category') @Default('UTILITY') String metaCategory,
    @JsonKey(name: 'meta_language') @Default('pt_BR') String metaLanguage,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Template;

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);
}
