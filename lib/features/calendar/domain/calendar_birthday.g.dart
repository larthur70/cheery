// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_birthday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarBirthday _$CalendarBirthdayFromJson(Map<String, dynamic> json) =>
    _CalendarBirthday(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      templateId: json['template_id'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      messageSentYear: (json['message_sent_year'] as num?)?.toInt(),
      automaticEnabled: json['automatic_enabled'] as bool? ?? false,
    );

Map<String, dynamic> _$CalendarBirthdayToJson(_CalendarBirthday instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'template_id': instance.templateId,
      'birth_date': instance.birthDate.toIso8601String(),
      'message_sent_year': instance.messageSentYear,
      'automatic_enabled': instance.automaticEnabled,
    };
