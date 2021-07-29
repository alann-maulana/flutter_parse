import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'storage.dart';

getStorage(String path) => StorageIO(path);

class StorageIO implements Storage {
  StorageIO(this.path);

  final String path;
  Database? _database;

  @override
  DatabaseFactory get databaseFactory => databaseFactoryIo;

  @override
  Future<Database> get database async {
    if (_database == null) {
      _database = await databaseFactory.openDatabase(path);
    }

    return _database!;
  }

  @override
  Future<bool> clear({String? key}) async {
    final store = stringMapStoreFactory.store();
    final db = await database;
    if (key != null) {
      await store.record(key).delete(db);
    } else {
      await store.delete(db);
    }
    return true;
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final store = stringMapStoreFactory.store();
    final db = await database;
    return await store.record(key).get(db);
  }

  @override
  Future<bool> put(String key, Map<String, dynamic> data) async {
    final store = stringMapStoreFactory.store();
    final db = await database;
    await store.record(key).put(db, data);
    return true;
  }
}
