import 'package:sembast/sembast.dart';

import 'storage.dart';

getStorage(String path) => StorageStub();

class StorageStub implements Storage {
  @override
  DatabaseFactory get databaseFactory => throw UnimplementedError();

  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<bool> clear({String? key}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> get(String key) {
    throw UnimplementedError();
  }

  @override
  Future<bool> put(String key, Map<String, dynamic> data) {
    throw UnimplementedError();
  }
}
