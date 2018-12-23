part of flutter_parse;

class ParseException implements Exception {
  @pragma("vm:entry-point")
  const ParseException([this.code = -1, this.message])
      : assert(code != null),
        assert(message != null);

  final int code;
  final String message;

  @override
  String toString() {
    return 'ParseException{code: $code, message: $message}';
  }
}
