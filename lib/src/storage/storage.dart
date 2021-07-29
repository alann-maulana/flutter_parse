import 'package:sembast/sembast.dart';

import 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.html) 'storage_html.dart';

export 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.html) 'storage_html.dart';

abstract class Storage {
  factory Storage(String path) => getStorage(path);

  DatabaseFactory get databaseFactory;

  Future<Database> get database;

  Future<Map<String, dynamic>?> get(String key);

  Future<bool> put(String key, Map<String, dynamic> data);

  Future<bool> clear({String? key});
}
