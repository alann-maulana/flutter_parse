part of flutter_parse;

final _ParseEncoder _parseEncoder = _ParseEncoder._internal();

/// A [_ParseEncoder] can be used to transform objects such as [ParseObject] into Map
/// data structures.
class _ParseEncoder {
  _ParseEncoder._internal();

  bool isValidType(dynamic value) {
    return value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is DateTime ||
        value is List ||
        value is Map ||
        value is Uint8List ||
        value is ParseObject ||
        value is ParseFile ||
        value is ParseGeoPoint;
  }

  /// Encode any type value into Map
  dynamic encode(dynamic value) {
    if (value is DateTime) {
      return _encodeDate(value);
    }

    if (value is Uint8List) {
      return _encodeUint8List(value);
    }

    if (value is List) {
      return value.map((v) => encode(v)).toList();
    }

    if (value is Map) {
      Map<String, dynamic> map = {};
      value.forEach((k, v) {
        map[k] = encode(v);
      });
      return map;
    }

    if (value is ParseObject) {
      return value._toPointer;
    }

    if (value is ParseQuery) {
      return value.toJson();
    }

    if (value is ParseFile) {
      return value._toJson;
    }

    if (value is ParseGeoPoint) {
      return value._toJson;
    }

    return value;
  }

  Map<String, dynamic> _encodeUint8List(Uint8List value) {
    return <String, dynamic>{
      "__type": "Bytes",
      "base64": base64.encode(value)
    };
  }

  Map<String, dynamic> _encodeDate(DateTime date) {
    return <String, dynamic>{
      "__type": "Date",
      "iso": _parseDateFormat.format(date)
    };
  }
}
