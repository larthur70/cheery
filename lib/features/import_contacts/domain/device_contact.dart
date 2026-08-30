/// Lightweight device contact used in selection / review.
class DeviceContact {
  const DeviceContact({
    required this.id,
    required this.displayName,
    required this.phoneRaw,
    required this.phoneNormalized,
    required this.storedPhone,
    this.birthDate,
  });

  final String id;
  final String displayName;

  /// Original phone string from the address book.
  final String phoneRaw;

  /// E.164-style uniqueness key (`55` + DDD + number), or empty if invalid.
  final String phoneNormalized;

  /// Phone formatted for storage (Brazilian mask without country code).
  final String storedPhone;

  /// Birthday from the device contact, when available.
  final DateTime? birthDate;

  bool get hasValidPhone => phoneNormalized.isNotEmpty;
}
