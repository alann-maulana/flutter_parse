import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';
import 'parse_base_object.dart';
import 'parse_date_format.dart';
import 'parse_decoder.dart';
import 'parse_encoder.dart';
import 'parse_http_client.dart';

typedef ParseObjectCreator<T extends ParseObject> = T Function(dynamic data);

/// The [ParseObject] is a local representation of data that can be saved and retrieved from
/// the Parse cloud.
///
/// The basic workflow for creating new data is to construct a new [ParseObject], use
/// [ParseObject.set] to fill it with data, and then use [ParseObject.save] to
/// persist to the cloud.
///
/// The basic workflow for accessing existing data is to use a [ParseQuery] to specify which
/// existing data to retrieve.
class ParseObject implements ParseBaseObject {
  static int limitBatchOperations = 50;
  static const _keyCreatedAt = "createdAt";
  static const _keyUpdatedAt = "updatedAt";
  static const _keyACL = "ACL";

  /// Accessor to the class name.
  final String className;
  String? _objectId;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool _isComplete = false;
  bool _isDeleted = false;
  final Map<String, dynamic> _data;
  final Map<String, dynamic> _operations;
  final Map<String, ParseFile> _operationFiles;

  /// Constructs a new [ParseObject]
  ///
  /// [className] must be alphanumerical plus underscore, and start with a letter. It is recommended
  /// to name classes in `PascalCaseLikeThis`.
  ///
  /// Set the [objectId] of saved [ParseObject] if any.
  /// Set the [json] with `Map<String, dynamic>`
  ParseObject({
    required this.className,
    String? objectId,
    json,
  })  : assert(className.isNotEmpty),
        _isComplete = false,
        _data = {},
        _operations = {},
        _operationFiles = {} {
    if (objectId != null) {
      assert(objectId.isNotEmpty);
      _objectId = objectId;
    }

    if (json != null) {
      mergeJson(json);
    }
  }

  @visibleForTesting
  factory ParseObject.fromJson({
    required dynamic json,
  }) {
    String? className = json[keyClassName];
    assert(className != null, 'No className defined');

    String? objectId = json[keyObjectId];

    return ParseObject(
      className: className!,
      objectId: objectId,
      json: json,
    );
  }

  // region SUBCLASS
  @visibleForTesting
  static final Map<Type, ParseObjectCreator> kExistingCustomObjects = {
    ParseSession: (data) => ParseSession.fromJson(json: data),
    ParseRole: (data) => ParseRole.fromJson(json: data),
    ParseUser: (data) => ParseUser.fromJson(json: data),
  };

  /// Registers a custom subclass type with the Parse SDK, enabling strong-typing of those
  /// [ParseObject]s whenever they appear. Subclasses must specify the [className]
  /// annotation and have a default constructor.
  ///
  /// ```dart
  /// class Beacon extends ParseObject {
  ///   Beacon(dynamic? data, {String? objectId})
  ///       : super(className: 'Beacon', json: data, objectId: objectId);
  ///
  ///   String? get uuid => getString('uuid');
  ///
  ///   int? get major => getInteger('major');
  ///   set major(int value) => set('major', value);
  ///
  ///   DateTime? get timestamp => getDateTime('timestamp');
  /// }
  ///
  /// ParseObject.registerSubclass((data) => Beacon(data));
  /// ```
  static registerSubclass(
    ParseObjectCreator creator, [
    bool replace = false,
  ]) {
    Type type = creator(<String, dynamic>{}).runtimeType;
    if (replace) {
      kExistingCustomObjects[type] = creator;
    } else {
      kExistingCustomObjects.putIfAbsent(type, () => creator);
    }
  }

  // endregion

  // region GETTER
  /// Return the copy of this instance
  ParseObject get copy => ParseObject(className: className, objectId: objectId)
    .._createdAt = _createdAt
    .._updatedAt = _updatedAt
    .._isComplete = _isComplete
    .._isDeleted = _isDeleted
    .._isDeleted = _isDeleted
    .._data.addAll(_data)
    .._operations.addAll(_operations)
    .._operationFiles.addAll(_operationFiles);

  Map<String, dynamic> get operations => _operations;

  /// Return true if this is already deleted
  bool get isDeleted => _isDeleted;

  /// Return true if this object already fetched
  bool get isComplete => _isComplete;

  /// Accessor to the object id. An object id is assigned as soon as an object is saved to the
  /// server. The combination of a className and an objectId uniquely identifies an object in your
  /// application.
  String? get objectId => _objectId;

  /// This reports time as the server sees it, so that if you create a [ParseObject], then wait a
  /// while, and then call [save], the creation time will be the time of the first
  /// [save] call rather than the time the object was created locally.
  DateTime? get createdAt => _createdAt;

  /// This reports time as the server sees it, so that if you make changes to a [ParseObject], then
  /// wait a while, and then call [save], the updated time will be the time of the
  /// [save] call rather than the time the object was changed locally.
  DateTime? get updatedAt => _updatedAt ?? _createdAt;

  /// Access a value. In most cases it is more convenient to use a helper function such as
  /// [getString] or [getInteger].
  ///
  /// Returns `null` if there is no such key.
  dynamic get(String key) {
    if (!_data.containsKey(key)) {
      return null;
    }

    return _data[key];
  }

  /// Access a [bool] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [bool].
  bool? getBoolean(String key) {
    if (get(key) is! bool) {
      return null;
    }

    return get(key);
  }

  /// Access an [int] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [int].
  int? getInteger(String key) {
    if (get(key) is! int) {
      return null;
    }

    return get(key);
  }

  /// Access a [double] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [double].
  double? getDouble(String key) {
    if (get(key) is! double) {
      return null;
    }

    return get(key);
  }

  /// Access a [num] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [num].
  num? getNumber(String key) {
    if (get(key) is! num) {
      return null;
    }

    return get(key);
  }

  /// Access a [String] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [String].
  String? getString(String key) {
    if (get(key) is! String) {
      return null;
    }

    return get(key);
  }

  /// Access a [DateTime] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [DateTime].
  DateTime? getDateTime(String key) {
    if (get(key) is! DateTime) {
      return null;
    }

    return get(key);
  }

  /// Access a [Map] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [Map].
  Map<String, T>? getMap<T>(String key) {
    if (get(key) is! Map) {
      return null;
    }

    return Map<String, T>.from(get(key));
  }

  /// Access a [List] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [List].
  List<T>? getList<T>(String key) {
    if (get(key) is! List) {
      return null;
    }

    return List<T>.from(get(key));
  }

  /// Access a [ParseGeoPoint] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseGeoPoint].
  ParseGeoPoint? getParseGeoPoint(String key) {
    if (get(key) is! ParseGeoPoint) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseFile] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseFile].
  ParseFile? getParseFile(String key) {
    if (get(key) is! ParseFile) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseObject] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseObject].
  ParseObject? getParseObject(String key) {
    if (get(key) is! ParseObject) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseUser] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseUser].
  ParseUser? getParseUser(String key) {
    if (get(key) is! ParseUser) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseRole] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseRole].
  ParseRole? getParseRole(String key) {
    if (get(key) is! ParseRole) {
      return null;
    }

    return get(key);
  }

  /// Access a [ParseACL] value.
  ///
  /// Returns `null` if there is no such key or if it is not a [ParseACL].
  ParseACL? getParseACL() {
    final acl = get('ACL');
    if (acl == null) {
      return ParseACL();
    } else if (!(acl is ParseACL)) {
      throw Exception("only ACLs can be stored in the ACL key");
    }

    return acl;
  }

  // endregion

  // region SETTER
  void _reset() {
    if (_isDeleted) {
      _objectId = null;
      _createdAt = null;
      _updatedAt = null;
      _isComplete = false;
      _data.clear();
      _operations.clear();
      _operationFiles.clear();
    }
  }

  /// Add a key-value pair to this object. It is recommended to name keys in
  /// `camelCaseLikeThis`.
  void set(String key, dynamic value) {
    assert(key.isNotEmpty);
    _checkKeyIsMutable(key);
    parseEncoder.isValidType(value);

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

    if (key != 'password') {
      _data[key] = value;
    }
    _operations[key] = parseEncoder.encode(value);
  }

  /// Setup [ParseACL] into this object
  void setACL(ParseACL acl) {
    set(_keyACL, acl);
  }

  /// Removes a key from this object's data if it exists.
  void remove(String key) {
    assert(key.isNotEmpty);

    _data.remove(key);
    _operations[key] = {'__op': 'Delete'};
  }

  /// Atomically removes all instances of the objects contained in a [List] from the
  /// array associated with a given key.
  void removeAll(String key, List<dynamic> values) {
    _operations[key] = {
      '__op': 'Remove',
      'objects': parseEncoder.encode(values)
    };
  }

  /// Atomically increments the given key by the given number.
  ///
  /// Default increment number = 1
  void increment(key, {num by = 1}) {
    _operations[key] = {'__op': 'Increment', 'amount': by};
  }

  /// Atomically decrements the given key by the given number.
  ///
  /// Default decrement number = 1
  void decrement(key, {num by = -1}) {
    increment(key, by: by);
  }

  /// Atomically adds an object to the end of the array associated with a given key.
  void add(String key, dynamic value) {
    addAll(key, [value]);
  }

  /// Atomically adds the objects contained in a [List] to the end of the array
  /// associated with a given key.
  void addAll(String key, List<dynamic> values) {
    _operations[key] = {'__op': 'Add', 'objects': parseEncoder.encode(values)};
  }

  /// Atomically adds an object to the array associated with a given key, only if it is not already
  /// present in the array. The position of the insert is not guaranteed.
  void addUnique(String key, dynamic value) {
    addAllUnique(key, [value]);
  }

  /// Atomically adds the objects contained in a [List] to the array associated with a
  /// given key, only adding elements which are not already present in the array. The position of the
  /// insert is not guaranteed.
  void addAllUnique(String key, List<dynamic> values) {
    _operations[key] = {
      '__op': 'AddUnique',
      'objects': parseEncoder.encode(values)
    };
  }

  @visibleForTesting
  void mergeJson(dynamic json, {bool fromFetch = false}) {
    if (fromFetch) {
      _data.clear();
    }

    _isComplete = true;
    json.forEach((key, value) {
      if (key == keyClassName || key == '__type') {
        // continue
      } else if (key == keyObjectId) {
        _objectId = value;
      } else if (key == _keyCreatedAt) {
        _createdAt = parseDateFormat.parse(value);
      } else if (key == _keyUpdatedAt) {
        _updatedAt = parseDateFormat.parse(value);
      } else if (key == _keyACL) {
        _data[key] = ParseACL.fromMap(value);
      } else {
        _data[key] = parseDecoder.decode(value);
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
      throw Exception("Cannot modify `$key` property of an $className object.");
    }
  }

  @override
  Uri get uri {
    assert(parse.configuration != null);
    final uri = parse.configuration!.uri;
    String path = '${uri.path}/classes/$className';

    if (objectId != null) {
      path = '$path/$objectId';
    }

    return uri.replace(path: path);
  }

  @override
  String get path {
    return uri.path;
  }

  dynamic get _batchSaveCommand => {
        'method': objectId != null ? 'PUT' : 'POST',
        'path': '$path',
        'body': _operations
      };

  dynamic get _batchDeleteCommand => {'method': 'DELETE', 'path': '$path'};

  /// Return `Map<String, dynamic>` of pointer object
  get asPointer =>
      {'__type': 'Pointer', keyClassName: className, keyObjectId: objectId};

  /// Return `Map<String, dynamic>` of complete data object
  @override
  get asMap {
    final map = <String, dynamic>{
      keyClassName: className,
    };

    if (objectId != null) {
      map[keyObjectId] = objectId;
    }

    if (createdAt != null) {
      map[_keyCreatedAt] = parseDateFormat.format(createdAt!);
    }

    if (updatedAt != null) {
      map[_keyUpdatedAt] = parseDateFormat.format(updatedAt!);
    }

    _data.forEach((key, value) {
      map[key] = parseEncoder.encode(value);
    });

    return map;
  }

  @override
  String toString() => json.encode(asMap);

  // endregion

  // region EXECUTORS
  /// Uploading [ParseFile]'s when there is any file to upload
  Future<void> uploadFiles() async {
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

  /// Saves this object to the server.
  Future<ParseObject> save({bool useMasterKey = false}) async {
    await uploadFiles();

    dynamic jsonBody = json.encode(_operations);
    final headers = {'content-type': 'application/json; charset=utf-8'};

    final result = objectId == null
        ? await parseHTTPClient.post(uri,
            body: jsonBody, headers: headers, useMasterKey: useMasterKey)
        : await parseHTTPClient.put(uri,
            body: jsonBody, headers: headers, useMasterKey: useMasterKey);

    mergeJson(result);
    return this;
  }

  /// If this [ParseObject] has not been fetched (i.e. [isComplete] returns `false`),
  /// fetches this object with the data from the server.
  Future<ParseObject> fetchIfNeeded({bool useMasterKey = false}) async {
    if (!isComplete) {
      return fetch(useMasterKey: useMasterKey);
    }

    return this;
  }

  /// Fetches this object with the data from the server.
  Future<ParseObject> fetch(
      {List<String>? includes, bool useMasterKey = false}) async {
    assert(objectId != null, 'cannot fetch ParseObject without objectId');

    final params = <String, String>{};
    if (includes != null) {
      params['include'] = includes.join(',');
    }
    final result = await parseHTTPClient
        .get(uri.replace(queryParameters: params), useMasterKey: useMasterKey);
    mergeJson(result, fromFetch: true);
    return Future.value(this);
  }

  /// Deletes this object on the server.
  Future<void> delete({bool useMasterKey = false}) async {
    if (objectId != null) {
      await parseHTTPClient.delete(uri, useMasterKey: useMasterKey);
      _isDeleted = true;
      _reset();
    }
    return;
  }

  // endregion

  // region BATCH OPERATIONS
  /// Saves each object in the provided list to the server.
  static Future<void> saveAll(List<ParseObject> objects,
      {bool useMasterKey = false}) async {
    assert(parse.configuration != null);
    assert(objects.length <= limitBatchOperations,
        'batch operations limit are $limitBatchOperations objects, currently ${objects.length}');

    for (int i = 0; i < objects.length; i++) {
      await objects[i].uploadFiles();
    }

    final jsonBody = json.encode({
      'requests': objects
          .map((object) => object._batchSaveCommand)
          .toList(growable: false)
    });
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    final uri = parse.configuration!.uri;
    final results = await parseHTTPClient.post(
      uri.replace(path: '${uri.path}/batch'),
      body: jsonBody,
      headers: headers,
      useMasterKey: useMasterKey,
    );
    if (results is List<dynamic>) {
      for (int i = 0; i < results.length; i++) {
        objects[i].mergeJson(results[i]);
      }
    }
    return;
  }

  /// Deletes each object in the provided list from the server.
  static Future<void> deleteAll(List<ParseObject> objects,
      {bool useMasterKey = false}) async {
    assert(parse.configuration != null);
    assert(objects.length <= limitBatchOperations,
        'batch operations limit are $limitBatchOperations objects');

    final jsonBody = json.encode({
      'requests': objects
          .map((object) => object._batchDeleteCommand)
          .toList(growable: false)
    });

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    final uri = parse.configuration!.uri;
    final results = await parseHTTPClient.post(
      uri.replace(path: '${uri.path}/batch'),
      body: jsonBody,
      headers: headers,
      useMasterKey: useMasterKey,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseObject &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          _objectId == other._objectId;

  @override
  int get hashCode => className.hashCode ^ _objectId.hashCode;
}
