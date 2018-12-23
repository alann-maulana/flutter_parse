part of flutter_parse;

class ParseUser extends ParseObject {
  static const keyParseClassName = "_User";
  static const keyUsername = "username";
  static const keyPassword = "password";
  static const keyEmail = "email";
  static const keyEmailVerified = "emailVerified";
  static const keySessionToken = "sessionToken";
  static const keyAuthData = "authData";

  ParseUser({String objectId, dynamic json})
      : super(keyParseClassName, objectId: objectId, json: json);

  String get username => getString(keyUsername);

  String get email => getString(keyEmail);

  bool get emailVerified => getBoolean(keyEmailVerified);

  String get sessionToken => getString(keySessionToken);

  set username(String value) {
    _data[keyUsername] = value;
  }

  set password(String value) {
    _data[keyPassword] = value;
  }

  set email(String value) {
    _data[keyEmail] = value;
  }

  static Future<ParseUser> get currentUser =>
      FlutterParse._channel.invokeMethod('getCurrentUser').then((jsonString) {
        if (jsonString != null && jsonString is String) {
          final jsonObject = json.decode(jsonString);
          return ParseUser(json: jsonObject);
        }
      });

  static Future<ParseUser> login(
      {@required String username, @required String password}) async {
    assert(username != null || username.isEmpty);
    assert(password != null || password.isEmpty);

    dynamic params = {'username': username, 'password': password};

    return FlutterParse._channel
        .invokeMethod('login', params)
        .then((jsonString) {
      return _parseResult(jsonString);
    });
  }

  Future<ParseUser> register() async {
    dynamic params = {};
    _data.forEach((key, value) {
      params[key] = parseEncoder.encode(value);
    });

    return FlutterParse._channel
        .invokeMethod('register', params)
        .then((jsonString) {
      return _parseResult(jsonString);
    });
  }

  static ParseUser _parseResult(dynamic result) {
    if (result != null && result is String) {
      final jsonObject = json.decode(result);
      return ParseUser(json: jsonObject);
    }

    return null;
  }

  static Future<void> logout() async {
    return FlutterParse._channel.invokeMethod('logout');
  }
}
