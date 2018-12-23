part of flutter_parse;

class ParseObject {
  static const keyObjectId = "objectId";
  static const keyCreatedAt = "createdAt";
  static const keyUpdatedAt = "updatedAt";
  static const keyClassName = "className";
  static const keyComplete = "__complete";
  static const keyOperations = "__operations";
  static const keySelectedKeys = "__selectedKeys";
  static const keyIsDeletingEventually = "__isDeletingEventually";
  static const keyIsDeletingEventuallyOld = "isDeletingEventually";

  final String className;
  String _objectId;
  DateTime _createdAt;
  DateTime _updatedAt;

  Map<String, dynamic> _data;
  bool _isComplete;
  int _isDeletingEventually;
  List<String> _selectedKeys;
  List<dynamic> _operations;

  ParseObject(this.className, {String objectId, dynamic json})
      : this._objectId = objectId {
    this._data = {};
    this._isComplete = false;
    this._isDeletingEventually = 0;
    this._selectedKeys = [];
    this._operations = [];
    if (json != null) {
      _mergeJson(json);
    }
  }

  static ParseObject createFromJson(Map<String, dynamic> json) {
    String className;
    if (json[keyClassName] != null && json[keyClassName] is String) {
      className = json[keyClassName];
    } else {
      return null;
    }

    return ParseObject(className, json: json);
  }

  void _mergeJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      if (key == keyClassName || key == '__type') {
        // continue
      } else if (key == keyObjectId) {
        _objectId = value;
      } else if (key == keyCreatedAt) {
        _createdAt = parseDateFormat.parse(value);
      } else if (key == keyUpdatedAt) {
        _updatedAt = parseDateFormat.parse(value);
      } else if (key == keyComplete) {
        _isComplete = value;
      } else if (key == keyIsDeletingEventually) {
        _isDeletingEventually = value;
      } else if (key == keySelectedKeys) {
        List<String> list;
        if (value is List) {
          list = List<String>.from(value);
          _selectedKeys = list.map<String>((s) {
            return s.toString();
          }).toList();
        }
      } else if (key == keyOperations) {
        _operations = List<dynamic>.from(value);
      } else {
        _data[key] = parseDecoder.decode(value);
      }
    });
  }

  dynamic toJson({bool withData = true}) {
    final map = <String, dynamic>{
      keyClassName: className,
    };

    if (_objectId != null) {
      map[keyObjectId] = _objectId;
    }

    if (withData) {
      if (_createdAt != null && _updatedAt != null) {
        map[keyCreatedAt] = parseDateFormat.format(_createdAt);
        map[keyUpdatedAt] = parseDateFormat.format(_updatedAt);
      }

      _data.forEach((key, value) {
        map[key] = parseEncoder.encode(value);
      });

      map[keyComplete] = _isComplete;
      map[keyIsDeletingEventually] = _isDeletingEventually;
      map[keySelectedKeys] = _selectedKeys;
      map[keyOperations] = _operations;
    }

    return map;
  }

  void set(String key, dynamic value) {
    assert(key != null);

    if (value == null) {
      _data.remove(key);
      _operations.add({
        key: {'__op': 'Delete'}
      });
    } else {
      _data[key] = value;
      _operations.add({key: parseEncoder.encode(value)});
    }
  }

  // region GETTER
  String get objectId => _objectId;

  DateTime get createdAt => _createdAt;

  DateTime get updatedAt => _updatedAt;

  List<String> get selectedKeys => _selectedKeys;

  dynamic get(String key) {
    assert(key != null);

    if (!_data.containsKey(key)) {
      return null;
    }

    return _data[key];
  }

  bool getBoolean(String key) {
    if (get(key) is! bool) {
      return false;
    }

    return get(key);
  }

  int getInteger(String key) {
    if (get(key) is! int) {
      return 0;
    }

    return get(key);
  }

  double getDouble(String key) {
    if (get(key) is! double) {
      return double.nan;
    }

    return get(key);
  }

  num getNumber(String key) {
    if (get(key) is! num) {
      return null;
    }

    return get(key);
  }

  String getString(String key) {
    if (get(key) is! String) {
      return null;
    }

    return get(key);
  }

  String getDateTime(String key) {
    if (get(key) is! DateTime) {
      return null;
    }

    return get(key);
  }

  Map<String, dynamic> getMap(String key) {
    if (get(key) is! Map) {
      return null;
    }

    return new Map<String, dynamic>.from(get(key));
  }

  List<dynamic> getList(String key) {
    if (get(key) is! List) {
      return null;
    }

    return new List<dynamic>.from(get(key));
  }

  ParseGeoPoint getParseGeoPoint(String key) {
    if (get(key) is! ParseGeoPoint) {
      return null;
    }

    return get(key);
  }

  ParseFile getParseFile(String key) {
    if (get(key) is! ParseFile) {
      return null;
    }

    return get(key);
  }

  ParseObject getParseObject(String key) {
    if (get(key) is! ParseObject) {
      return null;
    }

    return get(key);
  }
  // endregion

  // region SAVE
  Future<ParseObject> saveInBackground() async {
    return _save('saveInBackground');
  }

  Future<ParseObject> saveEventually() async {
    return _save('saveEventually');
  }

  Future<ParseObject> _save(String method) async {
    final result = await FlutterParse._channel
        .invokeMethod(method, toString());
    if (result != null) {
      return ParseObject.createFromJson(json.decode(result));
    }

    return null;
  }

  Future<ParseObject> fetchInBackground() async {
    final result = await FlutterParse._channel
        .invokeMethod('fetchInBackground', toJson(withData: false));
    if (result != null) {
      return ParseObject.createFromJson(json.decode(result));
    }

    return null;
  }
  // endregion

  // region DELETE
  Future<void> deleteInBackground() async {
    _delete('deleteInBackground');
  }

  Future<void> deleteEventually() async {
    _delete('deleteEventually');
  }

  Future<void> _delete(String method) async {
    await FlutterParse._channel.invokeMethod(
        method, toJson(withData: false));
  }
  // endregion

  @override
  String toString() {
    return json.encode(toJson());
  }
}
