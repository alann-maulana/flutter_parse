import 'dart:async';

import 'package:flutter_parse_storage_interface/flutter_parse_storage_interface.dart';
import 'package:meta/meta.dart';

final ParseLocalStorage parseLocalStorage = ParseLocalStorage._internal();

class ParseLocalStorage {
  final Map<String, LocalStorage> _cache;

  ParseLocalStorage._internal() : _cache = {};

  Future<LocalStorage?> get(String key) async {
    if (!_cache.containsKey(key)) {
      final instance = LocalStorage._internal(key);
      await instance._init();
      _cache[key] = instance;
    }

    return _cache[key];
  }

  @visibleForTesting
  Future<void> clear() async {
    _cache.forEach((key, cache) async {
      await cache.delete();
    });
    _cache.clear();
  }
}

class LocalStorage {
  final String _keyName;
  final Map<String, dynamic> _data = {};

  LocalStorage._internal(this._keyName);

  FlutterParseStorageInterface get storage {
    return FlutterParseStorageInterface.instance;
  }

  _init() async {
    final data = await storage.get(_keyName);

    if (data != null && data is Map) {
      _data.addAll(data);
    }
  }

  Future<bool> setData(Map<String, dynamic> values) async {
    _data
      ..clear()
      ..addAll(values);

    return await storage.put(_keyName, values);
  }

  Future<bool> delete() async {
    _data.clear();

    return await storage.clear(key: _keyName);
  }

  Map<String, dynamic> getData() {
    return _data;
  }

  bool get isEmpty => _data.isEmpty;
}
