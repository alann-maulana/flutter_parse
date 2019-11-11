import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';
import 'package:synchronized/synchronized.dart';

import '../flutter_parse.dart';
import 'db/db.dart';
import 'path/path_provider.dart';

final ParseLocalStorage parseLocalStorage = ParseLocalStorage._internal();

const String _kDatabaseName = 'flutter_parse.db';

class ParseLocalStorage {
  final Lock lock = Lock();
  final Map<String, LocalStorage> _cache;
  Database _db;

  ParseLocalStorage._internal() : _cache = {};

  Future<void> _init() async {
    if (_db == null) {
      await lock.synchronized(() async {
        if (_db == null) {
          final path = parsePathProvider.databasePath(_kDatabaseName);
          _db = await parseDB.databaseFactory.openDatabase(path);
        }
      });
    }
  }

  Future<LocalStorage> get(String key) async {
    await _init();
    if (!_cache.containsKey(key)) {
      final instance = LocalStorage._internal(_db, key);
      await instance._init();
      _cache[key] = instance;
    }

    return _cache[key];
  }

  @visibleForTesting
  Future<void> clear() async {
    _cache?.forEach((key, cache) async {
      await cache.delete();
    });
    _cache?.clear();
  }
}

class LocalStorage {
  final StoreRef _store = StoreRef.main();
  final String _keyName;
  final Map<String, dynamic> _data = {};
  final Database _db;

  LocalStorage._internal(this._db, this._keyName);

  _init() async {
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
    _data.clear();

    return _flush();
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
