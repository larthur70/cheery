/// UI model for a birthday card on the home dashboard.
class TodayBirthdayUiModel {
  const TodayBirthdayUiModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.templateId,
    required this.age,
    required this.messageSent,
    this.automaticEnabled = false,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String templateId;
  final int age;
  final bool messageSent;
  final bool automaticEnabled;
  final String? avatarUrl;
}
