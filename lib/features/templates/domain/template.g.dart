// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Template _$TemplateFromJson(Map<String, dynamic> json) => _Template(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  message: json['message'] as String,
  variables:
      (json['variables'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isDefault: json['is_default'] as bool? ?? false,
  approvalStatus: json['approval_status'] == null
      ? TemplateApprovalStatus.draft
      : templateApprovalStatusFromJson(json['approval_status']),
  metaTemplateName: json['meta_template_name'] as String?,
  metaTemplateId: json['meta_template_id'] as String?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  approvedAt: json['approved_at'] == null
      ? null
      : DateTime.parse(json['approved_at'] as String),
  rejectedReason: json['rejected_reason'] as String?,
  metaCategory: json['meta_category'] as String? ?? 'UTILITY',
  metaLanguage: json['meta_language'] as String? ?? 'pt_BR',
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TemplateToJson(_Template instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'message': instance.message,
  'variables': instance.variables,
  'is_default': instance.isDefault,
  'approval_status': templateApprovalStatusToJson(instance.approvalStatus),
  'meta_template_name': instance.metaTemplateName,
  'meta_template_id': instance.metaTemplateId,
  'submitted_at': instance.submittedAt?.toIso8601String(),
  'approved_at': instance.approvedAt?.toIso8601String(),
  'rejected_reason': instance.rejectedReason,
  'meta_category': instance.metaCategory,
  'meta_language': instance.metaLanguage,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
