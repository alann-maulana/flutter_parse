part of flutter_parse;

/// A ParseException gets raised whenever a [ParseObject] issues an invalid request,
/// such as deleting or editing an object that no longer exists on the server,
/// or when there is a network failure preventing communication with the Parse server.
class ParseException implements Exception {

  /// Construct a new ParseException with a particular error code.
  ///
  ///
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
