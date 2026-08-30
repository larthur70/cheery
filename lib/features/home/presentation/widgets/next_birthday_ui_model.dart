/// Upcoming birthday shown on the home dashboard (after today).
class NextBirthdayUiModel {
  const NextBirthdayUiModel({
    required this.id,
    required this.name,
    required this.nextOccurrence,
    required this.daysUntil,
  });

  final String id;
  final String name;
  final DateTime nextOccurrence;
  final int daysUntil;
}
