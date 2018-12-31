part of flutter_parse;

final ParseEncoder parseEncoder = new ParseEncoder._internal();

/// A [ParseEncoder] can be used to transform objects such as [ParseObject] into Map
/// data structures.
class ParseEncoder {
  ParseEncoder._internal();

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
        value is ParseGeoPoint;
  }

  /// Encode any type value into Map
  dynamic encode(dynamic value) {
    if (value is DateTime) {
      return _encodeDate(value);
    }

    if (value is Uint8List) {
      return <String, dynamic>{
        "__type": "Bytes",
        "base64": base64.encode(value)
      };
    }

    if (value is List) {
      return value.map((v){
        return encode(v);
      }).toList();
    }

    if (value is ParseObject) {
      return pointerOrLocalIdEncoder.encodeRelatedObject(value);
    }

    if (value is ParseQuery) {
      return value.toJson();
    }

    if (value is ParseFile) {
      return value.toJson;
    }

    if (value is ParseGeoPoint) {
      return value.toJson;
    }

    return value;
  }

  Map<String, dynamic> _encodeDate(DateTime date) {
    return <String, dynamic>{
      "__type": "Date",
      "iso": parseDateFormat.format(date)
    };
  }
}
