import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

DatabaseFactory get offlineDatabaseFactory => databaseFactoryIo;

Future<String> offlineDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'cheery_offline.db');
}
