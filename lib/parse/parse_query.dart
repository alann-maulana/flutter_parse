part of flutter_parse;

class ParseQuery<T extends ParseObject> {
  final String className;
  final _includes = <String>[];
  final _order = <String>[];
  final _where = <String, dynamic>{};
  List<String> _selectedKeys;
  int _limit = -1;
  int _skip = 0;
  bool _countEnabled = false;

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

    whereValue[condition] = value;

    _where[key] = whereValue;
  }

  void whereEqualTo(String key, dynamic value) {
    _where[key] = value;
  }

  void whereLessThan(String key, dynamic value) {
    _addCondition(key, "\$lt", value);
  }

  void whereNotEqualTo(String key, dynamic value) {
    _addCondition(key, "\$ne", value);
  }

  void whereGreaterThan(String key, dynamic value) {
    _addCondition(key, "\$gt", value);
  }

  void whereLessThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$lte", value);
  }

  void whereGreaterThanOrEqualTo(String key, dynamic value) {
    _addCondition(key, "\$gte", value);
  }

  void whereContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$in", values);
  }

  void whereContainsAll(String key, List<dynamic> values) {
    _addCondition(key, "\$all", values);
  }

  void whereFullText(String key, String text) {
    final termDictionary = <String, String>{
      "\$term": text
    };
    final searchDictionary = <String, Map<String, String>>{
      "\$search": termDictionary
    };
    _addCondition(key, "\$text", searchDictionary);
  }

  void whereNotContainedIn(String key, List<dynamic> values) {
    _addCondition(key, "\$nin", values);
  }

  void whereMatches(String key, String regex, {String modifiers}) {
    _addCondition(key, "\$regex", regex);
    if (modifiers != null && modifiers.isNotEmpty) {
      _addCondition(key, "\$options", modifiers);
    }
  }

  void whereContains(String key, String substring) {
    String regex = RegExp.escape(substring);
    whereMatches(key, regex);
  }

  void whereStartsWith(String key, String prefix) {
    String regex = RegExp.escape(prefix);
    regex = "^$regex";
    whereMatches(key, regex);
  }

  void whereEndsWith(String key, String suffix) {
    String regex = RegExp.escape(suffix);
    regex = "$regex\$";
    whereMatches(key, regex);
  }

  void whereExists(String key) {
    _addCondition(key, "\$exists", true);
  }

  void whereDoesNotExist(String key) {
    _addCondition(key, "\$exists", false);
  }

  void whereDoesNotMatchKeyInQuery(String key, String keyInQuery, ParseQuery query) {
    final condition = <String, dynamic>{
      "key": keyInQuery,
      "query": query.toJson()
    };
    _addCondition(key, "\$dontSelect", condition);
  }

  void whereMatchesKeyInQuery(String key, String keyInQuery, ParseQuery query) {
    final condition = <String, dynamic>{
      "key": keyInQuery,
      "query": query.toJson()
    };
    _addCondition(key, "\$select", condition);
  }

  void whereDoesNotMatchQuery(String key, ParseQuery query) {
    _addCondition(key, "\$notInQuery", query.toJson());
  }

  void whereMatchesQuery(String key, ParseQuery query) {
    _addCondition(key, "\$inQuery", query.toJson());
  }

  void whereNear(String key, ParseGeoPoint point) {
    _addCondition(key, "\$nearSphere", point);
  }

  void whereWithinMiles(String key, ParseGeoPoint point, double maxDistance) {
    whereWithinRadians(key, point, maxDistance / ParseGeoPoint.EARTH_MEAN_RADIUS_MILE);
  }

  void whereWithinKilometers(String key, ParseGeoPoint point, double maxDistance) {
    whereWithinRadians(key, point, maxDistance / ParseGeoPoint.EARTH_MEAN_RADIUS_KM);
  }

  void whereWithinRadians(String key, ParseGeoPoint point, double maxDistance) {
    whereNear(key, point);
    _maxDistance(key, maxDistance);
  }

  void whereWithinGeoBox(String key, ParseGeoPoint southwest, ParseGeoPoint northeast) {
    final array = <dynamic>[
      southwest.toJson,
      northeast.toJson
    ];
    final dictionary = <String, List<dynamic>>{
      "\$box": array
    };
    _addCondition(key, "\$within", dictionary);
  }

  void _maxDistance(String key, double maxDistance) {
    _addCondition(key, "\$maxDistance", maxDistance);
  }

  void whereWithinPolygon(String key, List<ParseGeoPoint> points) {
    final dictionary = <String, List<ParseGeoPoint>>{
      "\$polygon": points.map((point) {
        return point.toJson;
      }).toList()
    };
    _addCondition(key, "\$geoWithin", dictionary);
  }

  void wherePolygonContains(String key, ParseGeoPoint point) {
    final dictionary = <String, ParseGeoPoint>{
      "\$point": point
    };
    _addCondition(key, "\$geoIntersects", dictionary);
  }

  void setOrder(String key) {
    _order.clear();
    _order.add(key);
  }

  List<String> get order => _order;

  void _addOrder(String key) {
    _order.add(key);
  }

  void orderByAscending(String key) {
    setOrder(key);
  }

  void addAscendingOrder(String key) {
    _addOrder(key);
  }

  void orderByDescending(String key) {
    setOrder("-$key");
  }

  void addDescendingOrder(String key) {
    _addOrder("-$key");
  }

  void include(String key) {
    _includes.add(key);
  }

  List<String> get includes => _includes;

  void selectKeys(List<String> keys) {
    if (_selectedKeys == null) {
      _selectedKeys = new List();
    }

    _selectedKeys.addAll(keys);
  }

  List<String> get selectedKeys => _selectedKeys;

  void setLimit(int limit) {
    _limit = limit;
  }

  int get limit => _limit;

  void setSkip(int skip) {
    _skip = skip;
  }

  int get skip => _skip;

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
    params["where"] = json.encode(_where);

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

  Future<List<T>> findAsync() async {

  }

  Future<int> countAsync() async {

  }
}
