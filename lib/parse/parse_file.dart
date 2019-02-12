part of flutter_parse;

/// [ParseFile] is a local representation of a file that is saved to the Parse cloud.
///
/// The workflow is to construct a [ParseFile] with data and optionally a filename.
/// Then save it and set it as a field on a [ParseObject].
class ParseFile {
  final String type = 'File';
  final String url;
  final String name;

  /// Creates a new [ParseFile] from a [File]
  ParseFile(File file)
      : this.url = file.path,
        this.name = null;

  /// Creates a new file from a JSON.
  ParseFile._fromJson(dynamic json)
      : this.url = json['url'],
        this.name = json['name'];

  /// Returns [Map] of [ParseFile]
  dynamic get toJson =>
      <String, String>{'__type': type, 'name': name, 'url': url};

  @override
  String toString() {
    return json.encode(toJson);
  }
}
