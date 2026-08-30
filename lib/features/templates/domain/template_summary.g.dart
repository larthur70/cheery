// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateSummary _$TemplateSummaryFromJson(Map<String, dynamic> json) =>
    _TemplateSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      approvalStatus: json['approval_status'] == null
          ? TemplateApprovalStatus.draft
          : templateApprovalStatusFromJson(json['approval_status']),
    );

Map<String, dynamic> _$TemplateSummaryToJson(_TemplateSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_default': instance.isDefault,
      'approval_status': templateApprovalStatusToJson(instance.approvalStatus),
    };
