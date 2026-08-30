import 'package:cheery/features/import_contacts/domain/contact_import_failure.dart';
import 'package:cheery/features/import_contacts/domain/device_contact.dart';

import 'device_contacts_gateway_stub.dart'
    if (dart.library.io) 'device_contacts_gateway_io.dart' as gateway;

/// Reads device address-book contacts for import.
abstract class DeviceContactsRepository {
  const DeviceContactsRepository();

  factory DeviceContactsRepository.platform() => gateway.createRepository();

  Future<bool> hasPermission();

  /// Requests read access. Throws typed failures when denied.
  Future<void> requestPermission();

  Future<void> openSettings();

  /// Loads contacts that have at least one valid Brazilian phone.
  Future<List<DeviceContact>> loadContacts();
}

/// Web / unsupported platforms — contacts API is unavailable.
final class UnsupportedDeviceContactsRepository
    implements DeviceContactsRepository {
  const UnsupportedDeviceContactsRepository();

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> requestPermission() async {
    throw const ContactPermissionDeniedFailure(
      'Importação de contatos está disponível apenas no app mobile.',
    );
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<List<DeviceContact>> loadContacts() async {
    throw const ContactLoadFailure(
      'Importação de contatos está disponível apenas no app mobile.',
    );
  }
}
