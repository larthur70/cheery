// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Client _$ClientFromJson(Map<String, dynamic> json) => _Client(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  birthDate: DateTime.parse(json['birth_date'] as String),
  templateId: json['template_id'] as String,
  templateName: json['template_name'] as String?,
  messageSentYear: (json['message_sent_year'] as num?)?.toInt(),
  automaticEnabled: json['automatic_enabled'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ClientToJson(_Client instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'phone': instance.phone,
  'birth_date': instance.birthDate.toIso8601String(),
  'template_id': instance.templateId,
  'template_name': instance.templateName,
  'message_sent_year': instance.messageSentYear,
  'automatic_enabled': instance.automaticEnabled,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
