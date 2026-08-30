import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_summary.freezed.dart';
part 'template_summary.g.dart';

@freezed
abstract class TemplateSummary with _$TemplateSummary {
  const factory TemplateSummary({
    required String id,
    required String name,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(
      name: 'approval_status',
      fromJson: templateApprovalStatusFromJson,
      toJson: templateApprovalStatusToJson,
    )
    @Default(TemplateApprovalStatus.draft)
    TemplateApprovalStatus approvalStatus,
  }) = _TemplateSummary;

  factory TemplateSummary.fromJson(Map<String, dynamic> json) =>
      _$TemplateSummaryFromJson(json);
}
