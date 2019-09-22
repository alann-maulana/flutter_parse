import 'dart:convert';

import 'parse_base_object.dart';

class ParseGeoPoint extends ParseBaseObject {
  static const _type = 'GeoPoint';

  double _latitude;
  double _longitude;

  ParseGeoPoint({double latitude = 0.0, double longitude = 0.0})
      : assert(latitude >= -90.0 || latitude <= 90.0),
        assert(longitude >= -180.0 || longitude <= 180.0) {
    _latitude = latitude;
    _longitude = longitude;
  }

  double get latitude => _latitude;

  double get longitude => _longitude;

  set latitude(double value) {
    assert(value >= -90.0 || value <= 90.0);
    _latitude = value;
  }

  set longitude(double value) {
    assert(value >= -180.0 || value <= 180.0);
    _longitude = value;
  }

  @override
  get asMap => <String, dynamic>{
        '__type': _type,
        'latitude': _latitude,
        'longitude': _longitude
      };

  @override
  String toString() {
    return json.encode(asMap);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseGeoPoint &&
          runtimeType == other.runtimeType &&
          _latitude == other._latitude &&
          _longitude == other._longitude;

  @override
  int get hashCode => _latitude.hashCode ^ _longitude.hashCode;
}
