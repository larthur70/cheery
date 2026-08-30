import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required String phone,
    @JsonKey(name: 'birth_date') required DateTime birthDate,
    @JsonKey(name: 'template_id') required String templateId,
    @JsonKey(name: 'template_name') String? templateName,
    /// Calendar year the birthday WhatsApp was marked sent; null = not sent.
    @JsonKey(name: 'message_sent_year') int? messageSentYear,
    @JsonKey(name: 'automatic_enabled') @Default(false) bool automaticEnabled,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}

extension ClientBirthdayMessageSent on Client {
  bool get isBirthdayMessageSentThisYear {
    final year = messageSentYear;
    return year != null && year == DateTime.now().year;
  }
}
