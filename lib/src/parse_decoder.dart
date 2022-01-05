import 'dart:convert';

import 'package:flutter_parse/flutter_parse.dart';

import 'parse_date_format.dart';

final ParseDecoder parseDecoder = ParseDecoder._internal();

/// A [ParseDecoder] can be used to transform JSON data structures into actual objects, such as [ParseObject]
class ParseDecoder {
  ParseDecoder._internal();

  List<dynamic> _convertJSONArrayToList(List<dynamic> array) {
    List<dynamic> list = [];
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

    if (!(value is Map<String, dynamic>)) {
      return value;
    }

    Map<String, dynamic> map = value;
    if (!map.containsKey("__type")) {
      return _convertJSONObjectToMap(map);
    }

    switch (map["__type"]) {
      case "Date":
        String iso = map["iso"];
        return parseDateFormat.parse(iso);
      case "Bytes":
        String val = map["base64"];
        return base64.decode(val);
      case "Pointer":
      case "Object":
        String objectId = map["objectId"];
        String className = map["className"];
        Type? genericType;
        if (className == ParseSession.kClassName) {
          genericType = ParseSession;
        } else if (className == ParseUser.kClassName) {
          genericType = ParseUser;
        } else if (className == ParseRole.kClassName) {
          genericType = ParseRole;
        }

        if (genericType != null) {
          // ignore: invalid_use_of_visible_for_testing_member
          final creator = ParseObject.kExistingCustomObjects[genericType];
          if (creator != null) {
            return creator(map);
          }
        } else {
          // ignore: invalid_use_of_visible_for_testing_member
          for (var type in ParseObject.kExistingCustomObjects.keys) {
            // ignore: invalid_use_of_visible_for_testing_member
            final creator = ParseObject.kExistingCustomObjects[type];
            try {
              if (creator != null &&
                  className == creator(<String, Object>{}).className) {
                return creator(map);
              }
            } catch (_) {}
          }
        }

        return ParseObject(
          className: className,
          objectId: objectId,
          json: map,
        );
      case "File":
        // ignore: invalid_use_of_visible_for_testing_member
        return ParseFile.fromJson(map);
      case "GeoPoint":
        num latitude = map[ParseGeoPoint.keyLatitude] ?? 0.0;
        num longitude = map[ParseGeoPoint.keyLongitude] ?? 0.0;
        return ParseGeoPoint(
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
        );
    }

    return null;
  }
}
