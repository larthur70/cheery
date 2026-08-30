import 'package:cheery/core/offline/offline_database.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/birthday_reminders/domain/reminder_settings.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:sembast/sembast.dart';

/// JSON snapshots of server (plus optimistic) state, keyed by user id.
class OfflineStore {
  OfflineStore(this._database);

  final OfflineDatabase _database;
  final _snapshots = stringMapStoreFactory.store('snapshots');

  Future<List<Client>> loadClients(String userId) async {
    final raw = await _getList(userId, 'clients');
    return [
      for (final item in raw)
        Client.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> saveClients(String userId, List<Client> clients) async {
    await _put(userId, 'clients', [
      for (final client in clients) client.toJson(),
    ]);
  }

  Future<List<Template>> loadTemplates(String userId) async {
    final raw = await _getList(userId, 'templates');
    return [
      for (final item in raw)
        Template.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> saveTemplates(String userId, List<Template> templates) async {
    await _put(userId, 'templates', [
      for (final template in templates) template.toJson(),
    ]);
  }

  Future<Profile?> loadProfile(String userId) async {
    final raw = await _getMap(userId, 'profile');
    if (raw == null) return null;
    return Profile.fromJson(raw);
  }

  Future<void> saveProfile(String userId, Profile profile) async {
    await _put(userId, 'profile', profile.toJson());
  }

  Future<ReminderSettings?> loadReminders(String userId) async {
    final raw = await _getMap(userId, 'reminders');
    if (raw == null) return null;
    return ReminderSettings.fromJson(raw);
  }

  Future<void> saveReminders(String userId, ReminderSettings settings) async {
    await _put(userId, 'reminders', settings.toJson());
  }

  Future<void> clearUser(String userId) async {
    final db = await _database.instance;
    await db.transaction((txn) async {
      for (final name in const [
        'clients',
        'templates',
        'profile',
        'reminders',
      ]) {
        await _snapshots.record('$userId/$name').delete(txn);
      }
    });
  }

  Future<List<dynamic>> _getList(String userId, String name) async {
    final db = await _database.instance;
    final record = await _snapshots.record('$userId/$name').get(db);
    final value = record?['value'];
    if (value is List) return value;
    return const [];
  }

  Future<Map<String, dynamic>?> _getMap(String userId, String name) async {
    final db = await _database.instance;
    final record = await _snapshots.record('$userId/$name').get(db);
    final value = record?['value'];
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Future<void> _put(String userId, String name, Object value) async {
    final db = await _database.instance;
    await _snapshots.record('$userId/$name').put(db, {'value': value});
  }
}
