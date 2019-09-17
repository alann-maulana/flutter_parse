part of flutter_parse;

final _ParseDecoder _parseDecoder = _ParseDecoder._internal();

/// A [_ParseDecoder] can be used to transform JSON data structures into actual objects, such as [ParseObject]
class _ParseDecoder {
  _ParseDecoder._internal();

  List<dynamic> _convertJSONArrayToList(List<dynamic> array) {
    List<dynamic> list = List();
    array.forEach((value) {
      list.add(decode(value));
    });
    return list;
  }

  Map<String, dynamic> _convertJSONObjectToMap(Map<String, dynamic> object) {
    Map<String, dynamic> map = Map();
    object.forEach((key, value) {
      map.putIfAbsent(key, () => decode(value));
    });
    return map;
  }

  /// Decode any type value
  dynamic decode(dynamic value) {
    if (value is List) {
      return _convertJSONArrayToList(value);
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value.toInt();
    }

    if (value is double) {
      return value.toDouble();
    }

    if (value is num) {
      return value;
    }

    if (!(value is Map)) {
      return value;
    }

    Map map = value;
    if (!map.containsKey("__type")) {
      return _convertJSONObjectToMap(map);
    }

    switch (map["__type"]) {
      case "Date":
        String iso = map["iso"];
        return _parseDateFormat.parse(iso);
      case "Bytes":
        String val = map["base64"];
        return base64.decode(val);
      case "Pointer":
        String objectId = map["objectId"];
        String className = map["className"];
        return ParseObject(className: className, objectId: objectId);
      case "Object":
        String objectId = map["objectId"];
        String className = map["className"];
        if (className == '_User') {
          return ParseUser._fromJson(json: map);
        }
        return ParseObject._fromJson(
            className: className, objectId: objectId, json: map);
      case "File":
        return ParseFile._fromJson(map);
      case "GeoPoint":
        num latitude = map["latitude"] ?? 0.0;
        num longitude = map["longitude"] ?? 0.0;
        return ParseGeoPoint(
            latitude: latitude.toDouble(), longitude: longitude.toDouble());
    }

    return null;
  }
}
