import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

import 'storage.dart';

getStorage(String path) => StorageHtml();

class StorageHtml implements Storage {
  StorageHtml();

  Database? _database;

  @override
  DatabaseFactory get databaseFactory => databaseFactoryWeb;

  @override
  Future<Database> get database async {
    if (_database == null) {
      _database = await databaseFactory.openDatabase('Dart-Parse');
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
