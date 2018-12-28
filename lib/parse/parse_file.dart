part of flutter_parse;

/// [ParseFile] is a local representation of a file that is saved to the Parse cloud.
///
/// The workflow is to construct a [ParseFile] with data and optionally a filename.
/// Then save it and set it as a field on a [ParseObject].
class ParseFile {
  final String type;
  final String url;
  final String name;

  /// Creates a new file from a JSON.
  ParseFile(dynamic json) :
        this.type = 'File',
        this.url = json['url'],
        this.name = json['name'];

  /// Returns [Map] of [ParseFile]
  dynamic get toJson => <String, String>{
    '__type': type,
    'name': name,
    'url': url
  };
}