part of flutter_parse;

class ParseFile implements ParseBaseObject {
  static const _type = 'File';

  File _file;
  String _name;
  String _url;

  ParseFile.fromJson(dynamic json) {
    _mergeFrom(json);
  }

  _mergeFrom(dynamic json) {
    _url = json['url'];
    _name = json['name'];
  }

  ParseFile(this._file) : this._name = path.basename(_file.path);

  String get name => _name;

  String get url => _url;

  bool get saved => url != null;

  @override
  String get _path => '${_parse._configuration.uri.path}/files/$_name';

  @override
  get _toJson => <String, String>{'__type': _type, 'name': _name, 'url': _url};

  @override
  String toString() {
    return json.encode(_toJson);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseFile &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _url == other._url;

  @override
  int get hashCode => _name.hashCode ^ _url.hashCode;

  Future<ParseFile> upload() async {
    if (saved) {
      return Future.value(this);
    }

    final ext = path.extension(_file.path).replaceAll('.', '');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: mime.getContentType(ext)
    };

    final body = await _file.readAsBytes();
    final response = await _parseHTTPClient.post(
      _path,
      headers: headers,
      body: body,
    );

    _mergeFrom(response);
    return this;
  }
}
