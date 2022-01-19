import 'dart:async';

import '../flutter_parse.dart';
import 'parse_base_object.dart';
import 'parse_http_client.dart';

/// The [ParseSchema] is a representation of [ParseObject] schema that can be retrieved from
/// the Parse cloud.
class ParseSchema implements ParseBaseObject {
  static const String kPathSchemas = 'schemas';
  static const _keyFields = 'fields';
  static const _keyClassLevelPermissions = 'classLevelPermissions';
  static const _keyIndexes = 'indexes';

  /// Constructs a new schema using `className`
  ParseSchema({required this.className})
      : fields = {},
        classLevelPermissions = {},
        indexes = {};

  /// Constructs a new schema using [Map] data from Parse Cloud
  ParseSchema.fromJson(dynamic map)
      : className = map[keyClassName],
        fields = _parseFields(map[_keyFields]),
        classLevelPermissions = map[_keyClassLevelPermissions],
        indexes = map[_keyIndexes];

  /// The className of schema
  final String className;

  /// The map of fields
  final Map<String, SchemaType>? fields;

  /// The map of classLevelPermissions
  final Map<String, dynamic> classLevelPermissions;

  /// The map of indexes
  final Map<String, dynamic> indexes;

  static Map<String, SchemaType>? _parseFields(dynamic json) {
    if (json is Map) {
      final map = <String, SchemaType>{};
      json.forEach((key, value) {
        map[key] = SchemaType.fromJson(value);
      });
      return map;
    }

    return null;
  }

  @override
  dynamic get asMap => <String, dynamic>{
        keyClassName: className,
        _keyFields: fields,
        _keyClassLevelPermissions: classLevelPermissions,
        _keyIndexes: indexes,
      };

  static Uri get _basePath {
    assert(parse.configuration != null);
    final uri = parse.configuration!.uri;
    return uri.replace(path: '${uri.path}/$kPathSchemas');
  }

  @override
  Uri get uri => _basePath.replace(path: '${_basePath.path}/$className');

  @override
  String get path {
    return uri.path;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseSchema &&
          runtimeType == other.runtimeType &&
          className == other.className;

  @override
  int get hashCode => className.hashCode;

  /// Fetch all schemas data from Parse Cloud
  static Future<List<ParseSchema>?> fetchAll() async {
    final result = await parseHTTPClient.get(_basePath, useMasterKey: true);
    final results = result['results'];
    if (results is List) {
      return results.map((map) => ParseSchema.fromJson(map)).toList();
    }
    return null;
  }

  /// Fetch schema data from Parse Cloud
  Future<ParseSchema?> fetch() async {
    final result = await parseHTTPClient.get(uri, useMasterKey: true);
    if (result is Map) return ParseSchema.fromJson(result);
    return null;
  }
}

/// The schema type of a field
class SchemaType {
  static const _keyType = 'type';
  static const _keyTargetClass = 'targetClass';

  /// Constructs field schema type
  SchemaType(this.type, [this.targetClass]);

  /// Constructs schema type using map data
  SchemaType.fromJson(dynamic map) : this(map[_keyType], map[_keyTargetClass]);

  /// The type of field
  final String type;

  /// The target class of field
  final String? targetClass;

  dynamic get asMap => <String, dynamic>{
        _keyType: type,
        _keyTargetClass: targetClass,
      };
}
