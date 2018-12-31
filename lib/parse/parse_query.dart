part of flutter_parse;

/// The [ParseQuery] class defines a query that is used to fetch [ParseObject]. The most
/// common use case is finding all objects that match a query through the [findAsync]
/// method. For example, this sample code fetches all objects of class
/// `MyClass`. It calls a different function depending on whether the fetch succeeded or not.
class ParseQuery<T extends ParseObject> {
  /// The class name of [ParseObject]
  final String className;
  final _includes = <String>[];
  final _order = <String>[];
  final _where = <String, dynamic>{};
  List<String> _selectedKeys;
  int _limit = -1;
  int _skip = 0;
  bool _countEnabled = false;

  /// Constructs a query. A default query with no further parameters will retrieve all
  /// [ParseObject] of the provided class.
  ParseQuery(this.className);

  void _addCondition(String key, String condition, dynamic value) {
    Map<String, dynamic> whereValue;

    // Check if we already have some of a condition
    if (_where.containsKey(key)) {
      dynamic existingValue = _where[key];
      if (existingValue is Map) {
        whereValue = existingValue;
      }
    }

    if (whereValue == null) {
      whereValue = new Map();
    }

    whereValue[condition] = parseEncoder.encode(value);

    _where[key] = whereValue;
  }

  /// Add a constraint to the query that requires a particular key's value to be equal to the
  /// provided value.
  void whereEqualTo(String key, dynamic value) {
    _where[key] = parseEncoder.encode(value);
  }

  /// Add a constraint to the query that requires a particular key's value to be less than the
  /// provided value.
  void whereLessThan(String key, dynamic value) {
    _addCondition(key, "whereLessThan", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be not equal to the
  /// provided value.
  void whereNotEqualTo(String key, dynamic value) {
    _addCondition(key, "whereNotEqualTo", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be greater than the
  /// provided value.
  void whereGreaterThan(String key, dynamic value) {
    _addCondition(key, "whereGreaterThan", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be less than or equal
  /// to the provided value.
  void whereLessThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "whereLessThanOrEqualTo", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be greater than or
  /// equal to the provided value.
  void whereGreaterThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "whereGreaterThanOrEqualTo", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be contained in the
  /// provided list of values.
  void whereContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "whereContainedIn", values);
  }

  /// Add a constraint to the query that requires a particular key's value match another
  /// [ParseQuery].
  ///
  /// This only works on keys whose values are [ParseObject] or lists of [ParseObject]s.
  /// Add a constraint to the query that requires a particular key's value to contain every one of
  /// the provided list of values.
  void whereContainsAll(String key, List<dynamic> values) {
    _addCondition(key, "whereContainsAll", values);
  }

  /// Adds a constraint for finding string values that contain a provided
  /// string using Full Text Search
  void whereFullText(String key, String text) {
    _addCondition(key, "whereFullText", text);
  }

  /// Add a constraint to the query that requires a particular key's value not be contained in the
  /// provided list of values.
  void whereNotContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "whereNotContainedIn", values);
  }


  /// Add a regular expression constraint for finding string values that match the provided regular
  /// expression.
  ///
  /// This may be slow for large datasets.
  void whereMatches(String key, String regex, {String modifiers = ''}) {
    _addCondition(key, "whereMatches",
        <String, dynamic>{'regex': regex, 'modifiers': modifiers});
  }

  /// Add a constraint for finding string values that contain a provided string.
  ///
  /// This will be slow for large datasets.
  void whereContains(String key, String substring) {
    _addCondition(key, "whereContains", substring);
  }

  /// Add a constraint for finding string values that start with a provided string.
  ///
  /// This query will use the backend index, so it will be fast even for large datasets.
  void whereStartsWith(String key, String prefix) {
    _addCondition(key, "whereStartsWith", prefix);
  }

  /// Add a constraint for finding string values that end with a provided string.
  ///
  /// This will be slow for large datasets.
  void whereEndsWith(String key, String suffix) {
    _addCondition(key, "whereEndsWith", suffix);
  }

  /// Add a constraint for finding objects that contain the given key.
  void whereExists(String key) {
    _addCondition(key, "whereExists", true);
  }

  /// Add a constraint for finding objects that do not contain a given key.
  void whereDoesNotExist(String key) {
    _addCondition(key, "whereDoesNotExist", false);
  }

  /// Add a constraint to the query that requires a particular key's value does not match any value
  /// for a key in the results of another [ParseQuery].
  void whereDoesNotMatchKeyInQuery(
      String key, String keyInQuery, ParseQuery query) {
    final condition = <String, dynamic>{
      "keyInQuery": keyInQuery,
      "query": query.toJson()
    };
    _addCondition(key, "whereDoesNotMatchKeyInQuery", condition);
  }

  /// Add a constraint to the query that requires a particular key's value matches a value for a key
  /// in the results of another [ParseQuery].
  void whereMatchesKeyInQuery(String key, String keyInQuery, ParseQuery query) {
    final condition = <String, dynamic>{
      "keyInQuery": keyInQuery,
      "query": query.toJson()
    };
    _addCondition(key, "whereMatchesKeyInQuery", condition);
  }

  /// Add a constraint to the query that requires a particular key's value does not match another
  /// [ParseQuery].
  ///
  /// This only works on keys whose values are [ParseObject]s or lists of [ParseObject]s.
  void whereDoesNotMatchQuery(String key, ParseQuery query) {
    _addCondition(key, "whereDoesNotMatchQuery", query.toJson());
  }

  /// Add a constraint to the query that requires a particular key's value match another
  /// [ParseQuery].
  ///
  /// This only works on keys whose values are [ParseObject]s or lists of [ParseObject]s.
  void whereMatchesQuery(String key, ParseQuery query) {
    _addCondition(key, "whereMatchesQuery", query.toJson());
  }

  /// Add a proximity based constraint for finding objects with key point values near the point
  /// given.
  void whereNear(String key, ParseGeoPoint point) {
    _addCondition(key, "whereNear", point.toJson);
  }

  /// Add a proximity based constraint for finding objects with key point values near the point given
  /// and within the maximum distance given.
  ///
  /// Radius of earth used is {@code 3958.8} miles.
  void whereWithinMiles(String key, ParseGeoPoint point, double maxDistance) {
    whereWithinRadians(
        key, point, maxDistance / ParseGeoPoint.EARTH_MEAN_RADIUS_MILE);
  }

  /// Add a proximity based constraint for finding objects with key point values near the point given
  /// and within the maximum distance given.
  ///
  /// Radius of earth used is {@code 6371.0} kilometers.
  void whereWithinKilometers(
      String key, ParseGeoPoint point, double maxDistance) {
    whereWithinRadians(
        key, point, maxDistance / ParseGeoPoint.EARTH_MEAN_RADIUS_KM);
  }

  /// Add a proximity based constraint for finding objects with key point values near the point given
  /// and within the maximum distance given.
  void whereWithinRadians(String key, ParseGeoPoint point, double maxDistance) {
    _addCondition(key, "whereWithinRadians",
        <String, dynamic>{'point': point.toJson, 'maxDistance': maxDistance});
  }

  /// Add a constraint to the query that requires a particular key's coordinates be contained within
  /// a given rectangular geographic bounding box.
  void whereWithinGeoBox(
      String key, ParseGeoPoint southwest, ParseGeoPoint northeast) {
    _addCondition(key, "whereWithinGeoBox",
        <dynamic>[southwest.toJson, northeast.toJson]);
  }

  /// Adds a constraint to the query that requires a particular key's
  /// coordinates be contained within and on the bounds of a given polygon.
  /// Supports closed and open (last point is connected to first) paths
  ///
  /// Polygon must have at least 3 points
  void whereWithinPolygon(String key, List<ParseGeoPoint> points) {
    _addCondition(key, "whereWithinPolygon",
        points.map((point) => point.toJson).toList());
  }

  /// Add a constraint to the query that requires a particular key's
  /// coordinates that contains a [ParseGeoPoint]
  ///
  /// (Requires parse-server@2.6.0)
  void wherePolygonContains(String key, ParseGeoPoint point) {
    _addCondition(key, "wherePolygonContains", point.toJson);
  }

  void _setOrder(String key) {
    _order.clear();
    _order.add(key);
  }

  List<String> get order => _order;

  void _addOrder(String key) {
    _order.add(key);
  }

  /// Sorts the results in ascending order by the given key.
  void orderByAscending(String key) {
    _setOrder(key);
  }

  /// Also sorts the results in ascending order by the given key.
  ///
  /// The previous sort keys have precedence over this key.
  void addAscendingOrder(String key) {
    _addOrder(key);
  }

  /// Sorts the results in descending order by the given key.
  void orderByDescending(String key) {
    _setOrder("-$key");
  }

  /// Also sorts the results in descending order by the given key.
  ///
  /// The previous sort keys have precedence over this key.
  void addDescendingOrder(String key) {
    _addOrder("-$key");
  }

  /// Include nested {@link ParseObject}s for the provided key.
  ///
  /// You can use dot notation to specify which fields in the included object that are also fetched.
  void include(String key) {
    _includes.add(key);
  }

  List<String> get includes => _includes;

  /// Restrict the fields of returned {@link ParseObject}s to only include the provided keys.
  ///
  /// If this is called multiple times, then all of the keys specified in each of the calls will be
  /// included.
  ///
  /// **Note:** This option will be ignored when querying from the local datastore. This
  /// is done since all the keys will be in memory anyway and there will be no performance gain from
  /// removing them.
  void selectKeys(List<String> keys) {
    if (_selectedKeys == null) {
      _selectedKeys = new List();
    }

    _selectedKeys.addAll(keys);
  }

  List<String> get selectedKeys => _selectedKeys;

  /// Controls the maximum number of results that are returned.
  ///
  /// Setting a negative limit denotes retrieval without a limit. The default limit is {@code 100},
  /// with a maximum of {@code 1000} results being returned at a time.
  void setLimit(int limit) {
    _limit = limit;
  }

  int get limit => _limit;

  /// Controls the number of results to skip before returning any results.
  ///
  /// This is useful for pagination. Default is to skip zero results.
  void setSkip(int skip) {
    _skip = skip;
  }

  int get skip => _skip;

  /// Constructs a query that is the `or` of the given queries.
  static ParseQuery or(List<ParseQuery> queries) {
    final className = queries[0].className;
    final clauseOr = queries.map((q) {
      if (q.className != className) {
        throw new Exception('different className');
      }
      return q._where;
    }).toList();
    return ParseQuery(className)..whereEqualTo("\$or", clauseOr);
  }

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};

    params["className"] = className;
    params["where"] = _where;

    if (_limit >= 0) {
      params["limit"] = _limit;
    }
    if (_countEnabled) {
      params["count"] = 1;
    } else {
      if (_skip > 0) {
        params["skip"] = _skip;
      }
    }
    if (_order.isNotEmpty) {
      params["order"] = ParseTextUtils.join(",", _order);
    }
    if (_includes.isNotEmpty) {
      params["include"] = ParseTextUtils.join(",", _includes);
    }
    if (_selectedKeys != null) {
      params["fields"] = ParseTextUtils.join(",", _selectedKeys);
    }

    return params;
  }

  /// Retrieves a list of [ParseObject]s that satisfy this query from the source in a
  /// background thread.
  Future<List<ParseObject>> findAsync() async {
    final result = await FlutterParse._channel
        .invokeMethod('queryInBackground', toString());
    if (result is String) {
      dynamic list = json.decode(result);
      if (list is List) {
        return list.map((o) {
          return ParseObject._createFromJson(o);
        }).toList();
      }
    }

    return null;
  }

  /// Counts the number of objects that match this query in a background thread. This does not use
  /// caching.
  Future<int> countAsync() async {
    _countEnabled = true;
    final result = await FlutterParse._channel
        .invokeMethod('queryInBackground', toString());
    if (result is int) {
      int count = result;
      return count;
    }

    return 0;
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
