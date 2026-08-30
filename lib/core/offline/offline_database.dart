import 'package:cheery/core/offline/database_factory_stub.dart'
    if (dart.library.io) 'package:cheery/core/offline/database_factory_io.dart'
    if (dart.library.html) 'package:cheery/core/offline/database_factory_web.dart'
    if (dart.library.js_interop) 'package:cheery/core/offline/database_factory_web.dart';
import 'package:sembast/sembast.dart';

/// Local Sembast database for snapshots and the sync outbox.
class OfflineDatabase {
  Database? _db;

  Future<Database> get instance async {
    final existing = _db;
    if (existing != null) return existing;
    final path = await offlineDatabasePath();
    final opened = await offlineDatabaseFactory.openDatabase(path);
    _db = opened;
    return opened;
  }
}
