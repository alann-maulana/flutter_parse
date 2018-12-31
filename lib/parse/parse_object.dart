part of flutter_parse;


/// The [ParseObject] is a local representation of data that can be saved and retrieved from
/// the Parse cloud.
///
/// The basic workflow for creating new data is to construct a new [ParseObject], use
/// [set] to fill it with data, and then use [saveInBackground] to
/// persist to the cloud.
///
/// The basic workflow for accessing existing data is to use a [ParseQuery] to specify which
/// existing data to retrieve.
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

  /// Creates a new [ParseObject] based upon a class name. If the class name is a special type
  /// (e.g. for [ParseUser]), then the appropriate type of [ParseObject] is returned.
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

  static ParseObject _createFromJson(Map<String, dynamic> json) {
    String className;
    if (json[keyClassName] != null && json[keyClassName] is String) {
      className = json[keyClassName];
    } else {
      return null;
    }

    return ParseObject(className, json: json);
  }

  void _mergeSave(dynamic json) {
    this._data = {};
    this._isComplete = false;
    this._isDeletingEventually = 0;
    this._selectedKeys = [];
    this._operations = [];
    if (json != null) {
      _mergeJson(json);
    }
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

  /// Converts this [ParseObject] into Map
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

  /// Add a key-value pair to this object. It is recommended to name keys in
  /// <code>camelCaseLikeThis</code>.
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
  DateTime get updatedAt => _updatedAt;

  List<String> get selectedKeys => _selectedKeys;

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
  /// Returns `0` if there is no such key or if it is not a [int].
  int getInteger(String key) {
    if (get(key) is! int) {
      return 0;
    }

    return get(key);
  }

  /// Access a [double] value.
  ///
  /// Returns `double.nan` if there is no such key or if it is not a [double].
  double getDouble(String key) {
    if (get(key) is! double) {
      return double.nan;
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
  Map<String, dynamic> getMap(String key) {
    if (get(key) is! Map) {
      return null;
    }

    return new Map<String, dynamic>.from(get(key));
  }

  /// Access a [List] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [List].
  List<dynamic> getList(String key) {
    if (get(key) is! List) {
      return null;
    }

    return new List<dynamic>.from(get(key));
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
  // endregion

  // region SAVE
  /// Saves this object to the server in a background thread.
  ///
  /// Returns a [Future] of [ParseObject].
  Future<ParseObject> saveInBackground() async {
    return _save('saveInBackground');
  }

  /// Saves this object to the server in a background thread.
  ///
  /// Returns a [Future] of [ParseObject].
  Future<ParseObject> saveEventually() async {
    return _save('saveEventually');
  }

  /// Saves this object to the server at some unspecified time in the future, even if Parse is
  /// currently inaccessible. Use this when you may not have a solid network connection, and don't
  /// need to know when the save completes. If there is some problem with the object such that it
  /// can't be saved, it will be silently discarded. Objects saved with this method will be stored
  /// locally in an on-disk cache until they can be delivered to Parse. They will be sent immediately
  /// if possible. Otherwise, they will be sent the next time a network connection is available.
  /// Objects saved this way will persist even after the app is closed, in which case they will be
  /// sent the next time the app is opened. If more than 10MB of data is waiting to be sent,
  /// subsequent calls to [saveEventually] or [deleteEventually]  will cause old
  /// saves to be silently  discarded until the connection can be re-established, and the queued
  /// objects can be saved.
  Future<ParseObject> _save(String method) async {
    final result = await FlutterParse._channel
        .invokeMethod(method, toString());
    if (result != null) {
      _mergeSave(json.decode(result));
      return this;
    }

    return null;
  }

  /// Fetches this object with the data from the server in a background thread.
  ///
  /// Returns a [Future] of [ParseObject].
  Future<ParseObject> fetchInBackground() async {
    final result = await FlutterParse._channel
        .invokeMethod('fetchInBackground', toJson(withData: false));
    if (result != null) {
      _mergeSave(json.decode(result));
      return this;
    }

    return null;
  }
  // endregion

  // region DELETE
  /// Deletes this object on the server in a background thread.
  Future<void> deleteInBackground() async {
    _delete('deleteInBackground');
  }

  /// Deletes this object from the server at some unspecified time in the future, even if Parse is
  /// currently inaccessible. Use this when you may not have a solid network connection, and don't
  /// need to know when the delete completes. If there is some problem with the object such that it
  /// can't be deleted, the request will be silently discarded. Delete requests made with this method
  /// will be stored locally in an on-disk cache until they can be transmitted to Parse. They will be
  /// sent immediately if possible. Otherwise, they will be sent the next time a network connection
  /// is available. Delete instructions saved this way will persist even after the app is closed, in
  /// which case they will be sent the next time the app is opened. If more than 10MB of commands are
  /// waiting to be sent, subsequent calls to [deleteEventually] or
  /// [saveEventually] will cause old instructions to be silently discarded until the
  /// connection can be re-established, and the queued objects can be saved.
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
