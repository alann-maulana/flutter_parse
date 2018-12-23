part of flutter_parse;

class ParseFile {
  final String type;
  final String url;
  final String name;

  ParseFile(dynamic json) :
        this.type = 'File',
        this.url = json['url'],
        this.name = json['name'];

  dynamic get toJson => <String, String>{
    '__type': type,
    'name': name,
    'url': url
  };
}