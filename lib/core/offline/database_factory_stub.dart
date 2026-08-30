import 'package:sembast/sembast.dart';

DatabaseFactory get offlineDatabaseFactory {
  throw UnsupportedError('No database factory for this platform.');
}

Future<String> offlineDatabasePath() async => 'cheery_offline.db';
