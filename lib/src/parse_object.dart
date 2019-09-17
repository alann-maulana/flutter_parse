part of flutter_parse;

class ParseObject implements ParseBaseObject {
  static const _limitBatchOperations = 50;
  static const _keyObjectId = "objectId";
  static const _keyCreatedAt = "createdAt";
  static const _keyUpdatedAt = "updatedAt";
  static const _keyClassName = "className";

  final String className;
  String _objectId;
  DateTime _createdAt;
  DateTime _updatedAt;
  bool _isComplete;
  bool _isDeleted;
  final Map<String, dynamic> _data;
  final Map<String, dynamic> _operations;
  final Map<String, ParseFile> _operationFiles;

  ParseObject({@required this.className, String objectId})
      : assert(className != null && className.isNotEmpty),
        _isComplete = false,
        _data = {},
        _operations = {},
        _operationFiles = {} {
    if (objectId != null) {
      assert(objectId.isNotEmpty);
      _objectId = objectId;
    }
  }

  factory ParseObject._fromJson(
      {String className, String objectId, dynamic json}) {
    final object = ParseObject(className: className, objectId: objectId);
    object._mergeJson(json);
    return object;
  }

  // region GETTER
  bool get isDeleted => _isDeleted;

  bool get isComplete => _isComplete;

  /// Accessor to the object id. An object id is assigned as soon as an object is saved to the
  /// server. The combination of a className and an objectId uniquely identifies an object in your
  /// application.
  String get objectId => _objectId;

  /// This reports time as the server sees it, so that if you create a [ParseObject], then wait a
  /// while, and then call [saveInBackground], the creation time will be the time of the first
  /// [saveInBackground] call rather than the time the object was created locally.
  DateTime get createdAt => _createdAt;

  /// This reports time as the server sees it, so that if you make changes to a [ParseObject], then
  /// wait a while, and then call [saveInBackground], the updated time will be the time of the
  /// [saveInBackground] call rather than the time the object was changed locally.
  DateTime get updatedAt => _updatedAt ?? _createdAt;

  /// Access a value. In most cases it is more convenient to use a helper function such as
  /// [getString] or [getInteger].
  ///
  /// Returns `null` if there is no such key.
  dynamic get(String key) {
    assert(key != null);

    if (!_data.containsKey(key)) {
      return null;
    }

    return _data[key];
  }

  /// Access a [bool] value.
  ///
  /// Returns `false` if there is no such key or if it is not a [bool].
  bool getBoolean(String key) {
    if (get(key) is! bool) {
      return false;
    }

    return get(key);
  }

  /// Access an [int] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [int].
  int getInteger(String key) {
    if (get(key) is! int) {
      return null;
    }

    return get(key);
  }

  /// Access a [double] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [double].
  double getDouble(String key) {
    if (get(key) is! double) {
      return null;
    }

    return get(key);
  }

  /// Access a [num] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [num].
  num getNumber(String key) {
    if (get(key) is! num) {
      return null;
    }

    return get(key);
  }

  /// Access a [String] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [String].
  String getString(String key) {
    if (get(key) is! String) {
      return null;
    }

    return get(key);
  }

  /// Access a [DateTime] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [DateTime].
  DateTime getDateTime(String key) {
    if (get(key) is! DateTime) {
      return null;
    }

    return get(key);
  }

  /// Access a [Map] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [Map].
  Map<String, T> getMap<T>(String key) {
    if (get(key) is! Map) {
      return null;
    }

    return Map<String, T>.from(get(key));
  }

  /// Access a [List] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [List].
  List<T> getList<T>(String key) {
    if (get(key) is! List) {
      return null;
    }

    return List<T>.from(get(key));
  }

  /// Access a [ParseGeoPoint] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseGeoPoint].
  ParseGeoPoint getParseGeoPoint(String key) {
    if (get(key) is! ParseGeoPoint) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseFile] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseFile].
  ParseFile getParseFile(String key) {
    if (get(key) is! ParseFile) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseObject] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseObject].
  ParseObject getParseObject(String key) {
    if (get(key) is! ParseObject) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseUser] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseUser].
  ParseUser getParseUser(String key) {
    if (get(key) is! ParseUser) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseACL] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseACL].
  ParseACL getParseACL() {
    final acl = get('ACL');
    if (acl == null) {
      return ParseACL();
    } else if (!(acl is Map)) {
      // it won't going to happen
      return null;
    }

    return ParseACL.fromMap(acl);
  }
  // endregion

  // region SETTER
  void _reset() {
    if (_isDeleted) {
      _objectId = null;
      _createdAt = null;
      _updatedAt = null;
      _isComplete = null;
      _data.clear();
      _operations.clear();
      _operationFiles.clear();
    }
  }

  /// Add a key-value pair to this object. It is recommended to name keys in
  /// <code>camelCaseLikeThis</code>.
  void set(String key, dynamic value) {
    assert(key != null && key.isNotEmpty);
    _checkKeyIsMutable(key);

    if (value == null) {
      remove(key);
      return;
    }

    if (value is ParseFile) {
      if (!value.saved) {
        _operationFiles[key] = value;
        return;
      }
    }

    _data[key] = value;
    _operations[key] = _parseEncoder.encode(value);
  }

  void remove(String key) {
    assert(key != null && key.isNotEmpty);

    _data.remove(key);
    _operations[key] = {'__op': 'Delete'};
  }

  void removeAll(String key, List<dynamic> values) {
    _operations[key] = {
      '__op': 'Remove',
      'objects': _parseEncoder.encode(values)
    };
  }

  void increment(key, {int by = 1}) {
    _operations[key] = {'__op': 'Increment', 'amount': by};
  }

  void decrement(key, {int by = -1}) {
    increment(key, by: by);
  }

  void add(String key, dynamic value) {
    addAll(key, [value]);
  }

  void addAll(String key, List<dynamic> values) {
    _operations[key] = {'__op': 'Add', 'objects': _parseEncoder.encode(values)};
  }

  void addUnique(String key, dynamic value) {
    addAllUnique(key, [value]);
  }

  void addAllUnique(String key, List<dynamic> values) {
    _operations[key] = {
      '__op': 'AddUnique',
      'objects': _parseEncoder.encode(values)
    };
  }

  void _mergeJson(dynamic json, {bool fromFetch = false}) {
    if (fromFetch) {
      _data.clear();
    }

    _isComplete = true;
    json.forEach((key, value) {
      if (key == _keyClassName || key == '__type') {
        // continue
      } else if (key == _keyObjectId) {
        _objectId = value;
      } else if (key == _keyCreatedAt) {
        _createdAt = _parseDateFormat.parse(value);
      } else if (key == _keyUpdatedAt) {
        _updatedAt = _parseDateFormat.parse(value);
      } else {
        _data[key] = _parseDecoder.decode(value);
      }
    });

    if (_operations.isNotEmpty) {
      _operations.clear();
    }
  }
  // endregion

  // region HELPERS
  bool isKeyMutable(String key) {
    return true;
  }

  void _checkKeyIsMutable(String key) {
    if (!isKeyMutable(key)) {
      throw Exception("Cannot modify `" +
          key +
          "` property of an " +
          className +
          " object.");
    }
  }

  @override
  String get _path {
    String path = '${_parse._uri.path}classes/$className';

    if (objectId != null) {
      path = '$path/$objectId';
    }

    return path;
  }

  dynamic get _batchSaveCommand => {
        'method': objectId != null ? 'PUT' : 'POST',
        'path': '$_path',
        'body': _operations
      };

  dynamic get _batchDeleteCommand => {'method': 'DELETE', 'path': '$_path'};

  get _toPointer =>
      {'__type': 'Pointer', _keyClassName: className, _keyObjectId: objectId};

  @override
  get _toJson {
    final map = <String, dynamic>{
      _keyClassName: className,
    };

    if (objectId != null) {
      map[_keyObjectId] = objectId;
    }

    if (createdAt != null) {
      map[_keyCreatedAt] = _parseDateFormat.format(createdAt);
    }

    if (updatedAt != null) {
      map[_keyUpdatedAt] = _parseDateFormat.format(updatedAt);
    }

    _data.forEach((key, value) {
      map[key] = _parseEncoder.encode(value);
    });

    return map;
  }

  dynamic get asMap => _toJson;

  @override
  String toString() {
    return json.encode(_toJson);
  }
  // endregion

  // region EXECUTORS
  Future<void> _uploadFiles() async {
    if (_operationFiles.isNotEmpty) {
      List<String> keys = [];
      List<Future<ParseFile>> futures = [];
      _operationFiles.forEach((key, parseFile) async {
        keys.add(key);
        final future = parseFile.upload();
        futures.add(future);
      });

      List<ParseFile> files = await Future.wait(futures);
      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        ParseFile file = files[i];
        if (file.saved) {
          set(key, file);
        }
      }
      _operationFiles.clear();
    }
    return;
  }

  Future<ParseObject> save() async {
    await _uploadFiles();

    dynamic jsonBody = json.encode(_operations);
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    };

    final result = objectId == null
        ? await _parseHTTPClient.post(_path, body: jsonBody, headers: headers)
        : await _parseHTTPClient.put(_path, body: jsonBody, headers: headers);

    _mergeJson(result);
    return Future.value(this);
  }

  Future<ParseObject> fetchIfNeeded() async {
    if (!isComplete) {
      return fetch();
    }

    return Future.value(this);
  }

  Future<ParseObject> fetch({List<String> includes}) async {
    if (objectId != null) {
      var queryString = '';
      if (includes != null) {
        queryString = '?include=${includes.join(',')}';
      }
      final result = await _parseHTTPClient.get(_path + queryString);
      _mergeJson(result);
      return Future.value(this);
    }

    return null;
  }

  Future<void> delete() async {
    if (objectId != null) {
      await _parseHTTPClient.delete(_path);
      _isDeleted = true;
      _reset();
    }
    return null;
  }
  // endregion

  // region BATCH OPERATIONS
  static Future<void> saveAll(List<ParseObject> objects) async {
    assert(objects.length <= _limitBatchOperations,
        'batch operations limit are $_limitBatchOperations objects, currently ${objects.length}');

    for (int i = 0; i < objects.length; i++) {
      await objects[i]._uploadFiles();
    }

    final jsonBody = json.encode({
      'requests': objects
          .map((object) => object._batchSaveCommand)
          .toList(growable: false)
    });
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };
    final results = await _parseHTTPClient.post(
      '${_parse._uri.path}batch',
      body: jsonBody,
      headers: headers,
    );
    if (results is List<dynamic>) {
      for (int i = 0; i < results.length; i++) {
        objects[i]._mergeJson(results[i]);
      }
    }
    return;
  }

  static Future<void> deleteAll(List<ParseObject> objects) async {
    assert(objects.length <= _limitBatchOperations,
        'batch operations limit are $_limitBatchOperations objects');

    final jsonBody = json.encode({
      'requests': objects
          .map((object) => object._batchDeleteCommand)
          .toList(growable: false)
    });

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };
    final results = await _parseHTTPClient.post(
      'batch',
      body: jsonBody,
      headers: headers,
    );
    if (results is List<dynamic>) {
      for (int i = 0; i < results.length; i++) {
        objects[i]._isDeleted = true;
        objects[i]._reset();
      }
    }
    return;
  }
  // endregion

}
