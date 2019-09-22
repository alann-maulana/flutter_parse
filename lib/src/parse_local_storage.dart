import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import '../flutter_parse.dart';

final ParseLocalStorage parseLocalStorage = ParseLocalStorage._internal();

class ParseLocalStorage {
  final Map<String, LocalStorage> _cache;

  ParseLocalStorage._internal() : _cache = {};

  Future<LocalStorage> get(String key) async {
    if (!_cache.containsKey(key)) {
      final instance = LocalStorage._internal(key);
      await instance._init();
      _cache[key] = instance;
    }

    return _cache[key];
  }
}

class LocalStorage {
  final StoreRef _store = StoreRef.main();
  final String _filename;
  final Map<String, dynamic> _data = {};
  Database _db;

  LocalStorage._internal(this._filename);

  _init() async {
    final databaseFactory =
        !parse.isWebPlatform ? databaseFactoryIo : databaseFactoryMemory;
    _db = await databaseFactory.openDatabase('flutter_parse.db');

    final map = await _store.record(_filename).get(_db) as Map;
    if (map is Map) {
      _data.addAll(map);
    }
  }

  Future<void> setData(Map<String, dynamic> values) async {
    _data
      ..clear()
      ..addAll(values);

    return _flush();
  }

  Future<void> setItem(String key, value) async {
    _data[key] = value;

    return _flush();
  }

  Future<void> delete() async {
    await _store.record(_filename).delete(_db);
  }

  deleteItem(String key) async {
    _data.remove(key);

    return _flush();
  }

  Map<String, dynamic> getData() {
    return _data;
  }

  getItem(String key) {
    return _data[key];
  }

  bool get isEmpty => _data.isEmpty;

  Future<void> _flush() async {
    await _store.record(_filename).put(_db, _data);
  }
}
