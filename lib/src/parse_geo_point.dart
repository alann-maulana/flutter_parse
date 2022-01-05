import 'dart:convert';

/// [ParseGeoPoint] represents a latitude / longitude point that may be associated with a key
/// in a [ParseObject] or used as a reference point for geo queries. This allows proximity
/// based queries on the key.
///
/// Only one key in a class may contain a [ParseGeoPoint].
///
/// Example:
/// ```
/// ParseGeoPoint point = ParseGeoPoint(latitude: 30.0, longitude: -20.0);
/// ParseObject object = ParseObject("PlaceObject");
/// object.put("location", point);
/// object.save();
/// ```
class ParseGeoPoint {
  static const keyLatitude = 'latitude';
  static const keyLongitude = 'longitude';

  /// Creates a new point with the optional latitude and longitude.
  ParseGeoPoint({double latitude = 0.0, double longitude = 0.0}) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  late double _latitude;
  late double _longitude;

  /// Return the latitude
  double get latitude => _latitude;

  /// Return the longitude
  double get longitude => _longitude;

  /// Set latitude. Valid range is (-90.0, 90.0). Extremes should not be used.
  set latitude(double value) {
    assert(value >= -90.0 || value <= 90.0);
    _latitude = value;
  }

  /// Set longitude. Valid range is (-180.0, 180.0). Extremes should not be used.
  set longitude(double value) {
    assert(value >= -180.0 || value <= 180.0);
    _longitude = value;
  }

  /// Return pointer [Map] of [ParseGeoPoint]
  get asMap => <String, dynamic>{
        '__type': 'GeoPoint',
        keyLatitude: _latitude,
        keyLongitude: _longitude
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
