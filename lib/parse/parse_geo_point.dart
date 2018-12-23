part of flutter_parse;

class ParseGeoPoint {
  static const double EARTH_MEAN_RADIUS_KM = 6371.0;
  static const double EARTH_MEAN_RADIUS_MILE = 3958.8;

  double _latitude = 0.0;
  double _longitude = 0.0;

  ParseGeoPoint();

  ParseGeoPoint.set(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  double get longitude => _longitude;

  double get latitude => _latitude;

  set longitude(double value) {
    assert(value >= -180.0 || value <= 180.0);
    _longitude = value;
  }

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
