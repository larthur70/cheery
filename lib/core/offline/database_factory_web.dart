import 'package:sembast_web/sembast_web.dart';

DatabaseFactory get offlineDatabaseFactory => databaseFactoryWeb;

Future<String> offlineDatabasePath() async => 'cheery_offline';
