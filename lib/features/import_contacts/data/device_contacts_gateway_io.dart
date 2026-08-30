import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/import_contacts/data/device_contacts_repository.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_failure.dart';
import 'package:cheery/features/import_contacts/domain/device_contact.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

DeviceContactsRepository createRepository() =>
    const IoDeviceContactsRepository();

final class IoDeviceContactsRepository implements DeviceContactsRepository {
  const IoDeviceContactsRepository();

  @override
  Future<bool> hasPermission() async {
    final status =
        await FlutterContacts.permissions.check(PermissionType.read);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  @override
  Future<void> requestPermission() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        throw const ContactPermissionPermanentlyDeniedFailure();
      case PermissionStatus.denied:
      case PermissionStatus.notDetermined:
        throw const ContactPermissionDeniedFailure();
    }
  }

  @override
  Future<void> openSettings() => FlutterContacts.permissions.openSettings();

  @override
  Future<List<DeviceContact>> loadContacts() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.event,
        },
      );
      return _mapContacts(contacts);
    } on ContactImportFailure {
      rethrow;
    } catch (_) {
      throw const ContactLoadFailure();
    }
  }
}

List<DeviceContact> _mapContacts(List<Contact> contacts) {
  final result = <DeviceContact>[];

  for (final contact in contacts) {
    final id = contact.id;
    if (id == null || id.isEmpty) continue;

    final name = _displayName(contact);
    final phoneChoice = _pickPhone(contact.phones);
    if (phoneChoice == null) continue;

    result.add(
      DeviceContact(
        id: id,
        displayName: name,
        phoneRaw: phoneChoice.raw,
        phoneNormalized: phoneChoice.key,
        storedPhone: phoneChoice.stored,
        birthDate: _birthday(contact.events),
      ),
    );
  }

  result.sort(
    (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
  );
  return result;
}

String _displayName(Contact contact) {
  final display = contact.displayName?.trim();
  if (display != null && display.isNotEmpty) return display;

  final name = contact.name;
  if (name == null) return '';

  final parts = [
    name.prefix,
    name.first,
    name.middle,
    name.last,
    name.suffix,
  ].whereType<String>().map((p) => p.trim()).where((p) => p.isNotEmpty);

  return parts.join(' ');
}

({String raw, String key, String stored})? _pickPhone(List<Phone> phones) {
  if (phones.isEmpty) return null;

  final ranked = List<Phone>.from(phones)
    ..sort((a, b) => _phoneScore(b).compareTo(_phoneScore(a)));

  for (final phone in ranked) {
    final raw = phone.normalizedNumber?.trim().isNotEmpty == true
        ? phone.normalizedNumber!.trim()
        : phone.number.trim();
    if (raw.isEmpty) continue;

    final key = WhatsAppPhone.uniquenessKey(raw);
    if (key == null) continue;

    return (raw: raw, key: key, stored: _toStoredPhone(key));
  }

  return null;
}

int _phoneScore(Phone phone) {
  var score = 0;
  if (phone.isPrimary == true) score += 10;
  switch (phone.label.label) {
    case PhoneLabel.mobile:
    case PhoneLabel.iPhone:
    case PhoneLabel.main:
      score += 5;
    case PhoneLabel.workMobile:
      score += 3;
    default:
      break;
  }
  return score;
}

DateTime? _birthday(List<Event> events) {
  for (final event in events) {
    if (event.label.label != EventLabel.birthday) continue;
    // Yearless address-book birthdays are incomplete — leave pending.
    final year = event.year;
    if (year == null) return null;
    try {
      final date = DateTime(year, event.month, event.day);
      if (date.isAfter(DateTime.now())) continue;
      return date;
    } catch (_) {
      continue;
    }
  }
  return null;
}

String _toStoredPhone(String e164Digits) {
  var digits = e164Digits;
  if (digits.startsWith('55') &&
      (digits.length == 12 || digits.length == 13)) {
    digits = digits.substring(2);
  }
  return formatBrazilianPhone(digits);
}
