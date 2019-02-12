part of flutter_parse;

class ParseConfig {

  static final _currentConfig = ParseConfig._internal();
  final _data = <String, dynamic>{};

  ParseConfig._internal();

  void _mergeJson(Map<String, dynamic> json) {
    _data.clear();
    json.forEach((key, value) {
      _data[key] = _parseDecoder.decode(value);
    });
  }

  static Future<ParseConfig> get currentConfig async {
    final result = await Parse._channel.invokeMethod('configGetCurrent');
    if (result is String) {
      final dictionary = json.decode(result);
      if (dictionary is Map) {
        _currentConfig._mergeJson(dictionary);
      }
    }

    return _currentConfig;
  }

  static Future<ParseConfig> get fetchInBackground async {
    final result = await Parse._channel.invokeMethod('configFetchInBackground');
    if (result is String) {
      final dictionary = json.decode(result);
      if (dictionary is Map) {
        _currentConfig._mergeJson(dictionary);
      }
    }

    return _currentConfig;
  }

  dynamic operator [](String key) {
    return objectForKey(key);
  }

  dynamic objectForKey(String key) {
    return _data[key];
  }

  dynamic get data => _data;
}