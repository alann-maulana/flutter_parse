import 'dart:async';

import 'package:sembast/sembast.dart';

import '../flutter_parse.dart';
import 'path/path_provider.dart';

final ParseLocalStorage parseLocalStorage = ParseLocalStorage._internal();

const String _kDatabaseName = 'flutter_parse.db';

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
  final String _keyName;
  final Map<String, dynamic> _data = {};
  Database _db;

  LocalStorage._internal(this._keyName);

  _init() async {
    final path = await pathProvider.databasePath(_kDatabaseName);
    _db = await parse.configuration.databaseFactory
        .openDatabase(path);
    if (parse.configuration.enableLogging) {
      print(_db.path);
    }

    final map = await _store.record(_keyName).get(_db) as Map;
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
    await _store.record(_keyName).delete(_db);
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
    await _store.record(_keyName).put(_db, _data);
  }
}
