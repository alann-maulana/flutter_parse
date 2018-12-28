part of flutter_parse;

/// [ParseGeoPoint] represents a latitude / longitude point that may be associated with a key
/// in a {@link ParseObject} or used as a reference point for geo queries. This allows proximity
/// based queries on the key.
///
/// Only one key in a class may contain a [ParseGeoPoint].
class ParseGeoPoint {
  static const double EARTH_MEAN_RADIUS_KM = 6371.0;
  static const double EARTH_MEAN_RADIUS_MILE = 3958.8;

  double _latitude = 0.0;
  double _longitude = 0.0;

  /// Creates a new default point with latitude and longitude set to 0.0.
  ParseGeoPoint();

  /// Creates a new point with the specified latitude and longitude.
  ParseGeoPoint.set(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  double get longitude => _longitude;

  double get latitude => _latitude;

  /// Set longitude. Valid range is (-180.0, 180.0). Extremes should not be used.
  set longitude(double value) {
    assert(value >= -180.0 || value <= 180.0);
    _longitude = value;
  }

  /// Set latitude. Valid range is (-90.0, 90.0). Extremes should not be used.
  set latitude(double value) {
    assert(value >= -90.0 || value <= 90.0);
    _latitude = value;
  }

  dynamic get toJson => <String, dynamic>{
    "__type": "GeoPoint",
    "latitude": latitude,
    "longitude": longitude
  };

  @override
  String toString() {
    return 'ParseGeoPoint{_latitude: $_latitude, _longitude: $_longitude}';
  }
}
