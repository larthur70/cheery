import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_birthday.freezed.dart';
part 'calendar_birthday.g.dart';

@freezed
abstract class CalendarBirthday with _$CalendarBirthday {
  const factory CalendarBirthday({
    required String id,
    required String name,
    required String phone,
    @JsonKey(name: 'template_id') required String templateId,
    @JsonKey(name: 'birth_date') required DateTime birthDate,
    @JsonKey(name: 'message_sent_year') int? messageSentYear,
    @JsonKey(name: 'automatic_enabled') @Default(false) bool automaticEnabled,
  }) = _CalendarBirthday;

  factory CalendarBirthday.fromJson(Map<String, dynamic> json) =>
      _$CalendarBirthdayFromJson(json);
}

extension CalendarBirthdayMessageSent on CalendarBirthday {
  bool get isBirthdayMessageSentThisYear {
    final year = messageSentYear;
    return year != null && year == DateTime.now().year;
  }
}
