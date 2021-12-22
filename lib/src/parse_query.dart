import 'dart:async';
import 'dart:convert';

import '../flutter_parse.dart';
import 'parse_encoder.dart';
import 'parse_http_client.dart';

/// The [ParseQuery] class defines a query that is used to fetch [ParseObject]s. The most
/// common use case is finding all objects that match a query through the [find]
/// method.
///
/// For example, this sample code fetches all objects of class `MyClass`
/// It calls a different function depending on whether the fetch succeeded or not.
///
/// ```dart
/// final query = ParseQuery(className: 'MyClass');
/// final classes = await query.find();
/// ```
class ParseQuery<T extends ParseObject> {
  /// Accessor for the class name.
  late final String className;

  final List<String> _includes = [];
  final List<String> _order = [];
  final Map<String, dynamic> _where = Map();
  List<String>? _selectedKeys;
  int _limit = -1;
  int _skip = 0;
  bool _countEnabled = false;

  /// Constructs a query. A default query with no further parameters will retrieve all
  /// [ParseObject]s of the provided class.
  ParseQuery({String? className}) {
    if (className != null) {
      this.className = className;
    } else {
      // ignore: invalid_use_of_visible_for_testing_member
      final creator = ParseObject.kExistingCustomObjects[genericType];
      if (creator != null) {
        final parseObject = creator(<String, dynamic>{'name':''}) as T;
        this.className = parseObject.className;
      } else {
        throw Exception('className required');
      }
    }
  }

  /// Constructs a copy of current [ParseQuery] instance;
  ParseQuery get copy {
    final newQuery = ParseQuery(className: className);
    newQuery._includes.addAll(_includes);
    newQuery._order.addAll(_order);
    newQuery._where.addAll(_where);
    newQuery._selectedKeys = _selectedKeys;
    newQuery._limit = _limit;
    newQuery._skip = _skip;
    newQuery._countEnabled = _countEnabled;

    return newQuery;
  }

  /// Retrieve [Type] of ParseObject subclass
  Type get genericType => T;

  void _addCondition(String key, String condition, dynamic value) {
    Map<String, dynamic>? whereValue;

    // Check if we already have some of a condition
    if (_where.containsKey(key)) {
      dynamic existingValue = _where[key];
      if (existingValue is Map<String, dynamic>) {
        whereValue = existingValue;
      }
    }

    whereValue ??= {};

    whereValue.putIfAbsent(condition, () => value);

    _where.putIfAbsent(key, () => whereValue);
  }

  /// Add a constraint to the query that requires a particular key's value to be equal to the
  /// provided value.
  void whereEqualTo(String key, dynamic value) {
    _where.putIfAbsent(key, () => parseEncoder.encode(value));
  }

  /// Add a constraint to the query that requires a particular key's value to be less than the
  /// provided value.
  void whereLessThan(String key, dynamic value) {
    _addCondition(key, "\$lt", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be not equal to the
  /// provided value.
  void whereNotEqualTo(String key, dynamic value) {
    _addCondition(key, "\$ne", parseEncoder.encode(value));
  }

  /// Add a constraint to the query that requires a particular key's value to be greater than the
  /// provided value.
  void whereGreaterThan(String key, dynamic value) {
    _addCondition(key, "\$gt", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be less than or equal
  /// to the provided value.
  void whereLessThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$lte", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be greater than or
  /// equal to the provided value.
  void whereGreaterThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$gte", value);
  }

  /// Add a constraint to the query that requires a particular key's value to be contained in the
  /// provided list of values.
  void whereContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$in", values);
  }

  /// Add a constraint to the query that requires a particular key's value to contain every one of
  /// the provided list of values.
  void whereContainsAll(String key, List<dynamic> values) {
    _addCondition(key, "\$all", values);
  }

  /// Add a constraint to the query that requires a particular key's value not be contained in the
  /// provided list of values.
  void whereNotContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$nin", values);
  }

  /// Add a regular expression constraint for finding string values that match the provided regular
  /// expression.
  ///
  /// This may be slow for large datasets.
  void whereMatches(String key, String regex, [String? modifiers]) {
    _addCondition(key, "\$regex", regex);
    if (modifiers != null && modifiers.isNotEmpty) {
      _addCondition(key, "\$options", modifiers);
    }
  }

  /// Add a constraint for finding string values that contain a provided string.
  void whereContains(String key, String substring,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(substring);
    if (caseInsensitive) {
      regex = "${caseInsensitive ? "(?i)" : ""}$regex";
    }
    whereMatches(key, regex);
  }

  /// Add a constraint for finding string values that start with a provided string.
  ///
  /// This query will use the backend index, so it will be fast even for large datasets.
  void whereStartsWith(String key, String prefix,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(prefix);
    regex = "${caseInsensitive ? "(?i)" : ""}^$regex";
    whereMatches(key, regex);
  }

  /// Add a constraint for finding string values that end with a provided string.
  ///
  /// This will be slow for large datasets.
  void whereEndsWith(String key, String suffix,
      {bool caseInsensitive = false}) {
    String regex = RegExp.escape(suffix);
    regex = "${caseInsensitive ? "(?i)" : ""}$regex\$";
    whereMatches(key, regex);
  }

  /// Add a constraint for finding objects that contain the given key.
  void whereExists(String key) {
    _addCondition(key, "\$exists", true);
  }

  /// Add a constraint for finding objects that do not contain a given key.
  void whereDoesNotExist(String key) {
    _addCondition(key, "\$exists", false);
  }

  /// Add a constraint to the query that requires a particular key's value does not match any value
  /// for a key in the results of another [ParseQuery].
  void whereDoesNotMatchKeyInQuery(
      String key, String keyInQuery, ParseQuery query) {
    Map<String, dynamic> condition = Map();
    condition.putIfAbsent("key", () => keyInQuery);
    condition.putIfAbsent("query", () => query);
    _addCondition(key, "\$dontSelect", condition);
  }

  /// Add a constraint to the query that requires a particular key's value matches a value for a key
  /// in the results of another [ParseQuery].
  void whereMatchesKeyInQuery(String key, String keyInQuery, ParseQuery query) {
    Map<String, dynamic> condition = Map();
    condition.putIfAbsent("key", () => keyInQuery);
    condition.putIfAbsent("query", () => query);
    _addCondition(key, "\$select", condition);
  }

  /// Add a constraint to the query that requires a particular key's value does not match another
  /// [ParseQuery].
  void whereDoesNotMatchQuery(String key, ParseQuery query) {
    _addCondition(key, "\$notInQuery", query);
  }

  /// Add a constraint to the query that requires a particular key's value match another
  /// [ParseQuery].
  void whereMatchesQuery(String key, ParseQuery query) {
    _addCondition(key, "\$inQuery", query);
  }

  /// Add a proximity based constraint for finding objects with key point values near the point
  /// given.
  void whereNear(String key, ParseGeoPoint point) {
    _addCondition(key, "\$nearSphere", point);
  }

  /// Add a proximity based constraint for finding objects with key point values near the point given
  /// and within the maximum distance given.
  void whereWithinKilometers(String key, ParseGeoPoint point, num maxDistance) {
    Map<String, dynamic> condition = Map();
    condition["\$nearSphere"] = point;
    condition["\$maxDistanceInKilometers"] = maxDistance;
    _where.putIfAbsent(key, () => parseEncoder.encode(condition));
  }

  /// Add a proximity based constraint for finding objects with key point values near the point given
  /// and within the maximum distance given.
  void whereWithinRadians(String key, double maxDistance) {
    _addCondition(key, "\$maxDistance", maxDistance);
  }

  /// Add a constraint to the query that requires a particular key's coordinates be contained within
  /// a given rectangular geographic bounding box.
  void whereWithinGeoBox(
      String key, ParseGeoPoint southwest, ParseGeoPoint northeast) {
    List<dynamic> array = [];
    array.add(southwest);
    array.add(northeast);
    Map<String, List<dynamic>> dictionary = Map();
    dictionary.putIfAbsent("\$box", () => array);
    _addCondition(key, "\$within", dictionary);
  }

  /// Adds a constraint to the query that requires a particular key's
  /// coordinates be contained within and on the bounds of a given polygon.
  /// Supports closed and open (last point is connected to first) paths
  void whereWithinPolygon(String key, List<ParseGeoPoint> points) {
    Map<String, List<ParseGeoPoint>> dictionary = Map();
    dictionary.putIfAbsent("\$polygon", () => points);
    _addCondition(key, "\$geoWithin", dictionary);
  }

  /// Add a constraint to the query that requires a particular key's
  /// coordinates that contains a [ParseGeoPoint]s
  void wherePolygonContains(String key, ParseGeoPoint point) {
    Map<String, ParseGeoPoint> dictionary = Map();
    dictionary.putIfAbsent("\$point", () => point);
    _addCondition(key, "\$geoIntersects", dictionary);
  }

  void setOrder(String key) {
    _order.clear();
    _order.add(key);
  }

  List<String> get order => _order;

  void addOrder(String key) {
    _order.add(key);
  }

  /// Sorts the results in ascending order by the given key.
  void orderByAscending(String key) {
    setOrder(key);
  }

  /// Also sorts the results in ascending order by the given key.
  ///
  /// The previous sort keys have precedence over this key.
  void addAscendingOrder(String key) {
    addOrder(key);
  }

  /// Sorts the results in descending order by the given key.
  void orderByDescending(String key) {
    setOrder("-$key");
  }

  /// Also sorts the results in descending order by the given key.
  ///
  /// The previous sort keys have precedence over this key.
  void addDescendingOrder(String key) {
    addOrder("-$key");
  }

  /// Include nested [ParseObject]s for the provided key.
  void include(String key) {
    _includes.add(key);
  }

  /// Retrieve the nested provided key.
  List<String> get includes => _includes;

  /// Restrict the fields of returned {@link ParseObject}s to only include the provided keys.
  ///
  /// If this is called multiple times, then all of the keys specified in each of the calls will be
  /// included.
  void selectKeys(List<String> keys) {
    if (_selectedKeys == null) {
      _selectedKeys = [];
    }

    _selectedKeys!.addAll(keys);
  }

  /// Retrieve the restricted fields
  List<String>? get selectedKeys => _selectedKeys;

  /// Controls the maximum number of results that are returned.
  ///
  /// Setting a negative limit denotes retrieval without a limit. The default limit is [100],
  /// with a maximum of [1000] results being returned at a time.
  void setLimit(int limit) {
    _limit = limit;
  }

  /// Accessor for the limit   value.
  int get limit => _limit;

  /// Controls the number of results to skip before returning any results.
  ///
  /// This is useful for pagination. Default is to skip zero results.
  void setSkip(int skip) {
    _skip = skip;
  }

  /// Accessor for the skip value.
  int get skip => _skip;

  Map<String, dynamic> toJson() {
    var params = toJsonParams();
    assert(!params.containsKey("count"));
    params.putIfAbsent("className", () => className);

    return params;
  }

  Map<String, dynamic> toJsonParams() {
    Map<String, dynamic> params = Map();

    if (_where.isNotEmpty) {
      params.putIfAbsent("where", () => parseEncoder.encode(_where));
    }
    if (_limit >= 0) {
      params.putIfAbsent("limit", () => _limit);
    }
    if (_countEnabled) {
      params.putIfAbsent("count", () => 1);
      params.putIfAbsent("limit", () => 0);
    } else {
      if (_skip > 0) {
        params.putIfAbsent("skip", () => _skip);
      }
    }
    if (_order.isNotEmpty) {
      params.putIfAbsent("order", () => _order.join(','));
    }
    if (_includes.isNotEmpty) {
      params.putIfAbsent("include", () => _includes.join(','));
    }
    if (_selectedKeys != null) {
      params.putIfAbsent("keys", () => _selectedKeys!.join(','));
    }

    return params;
  }

  /// Constructs a query that is the {@code or} of the given queries.
  static ParseQuery<T> or<T extends ParseObject>(List<ParseQuery<T>> queries) {
    final className = queries[0].className;
    final clauseOr = queries.map((q) {
      if (q.className != className) {
        throw ParseException(
            code: ParseException.invalidClassName,
            message: 'different className');
      }
      return q._where;
    }).toList();
    return ParseQuery<T>()..whereEqualTo("\$or", clauseOr);
  }

  /// Retrieves a list of [ParseObject]s that satisfy this query from the source in a
  /// background thread.
  Future<List<T>> find({bool useMasterKey = false}) async {
    dynamic result = await _find(useMasterKey: useMasterKey);
    final List<T> objects = [];
    if (result["results"] is List) {
      List<dynamic> results = result["results"];

      results.forEach((json) {
        // ignore: invalid_use_of_visible_for_testing_member
        final creator = ParseObject.kExistingCustomObjects[genericType];
        if (creator != null) {
          objects.add(creator(json) as T);
        } else {
          objects.add(ParseObject(
            className: className,
            json: json,
          ) as T);
        }
      });
    }
    return objects;
  }

  Future<dynamic> _find({bool useMasterKey = false}) {
    _countEnabled = false;
    return _query(useMasterKey: useMasterKey);
  }

  /// Counts the number of objects that match this query. This does not use
  /// caching.
  Future<int> count({bool useMasterKey = false}) async {
    final result = await _count(useMasterKey: useMasterKey);
    if (result.containsKey("count")) {
      return result["count"];
    }

    return 0;
  }

  Future<dynamic> _count({bool useMasterKey = false}) {
    _countEnabled = true;
    return _query(useMasterKey: useMasterKey);
  }

  Future<dynamic> _query({bool useMasterKey = false}) {
    assert(parse.configuration != null);
    Map<String, dynamic> params = toJsonParams();
    params.putIfAbsent("_method", () => "GET");

    dynamic body = json.encode(params);
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };

    return parseHTTPClient.post(
      '${parse.configuration!.uri.path}/classes/$className',
      useMasterKey: useMasterKey,
      body: body,
      headers: headers,
    );
  }
}
