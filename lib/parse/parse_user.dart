part of flutter_parse;

/// The [ParseUser] is a local representation of user data that can be saved and retrieved from
/// the Parse cloud.
class ParseUser extends ParseObject {
  static const keyParseClassName = "_User";
  static const keyUsername = "username";
  static const keyPassword = "password";
  static const keyEmail = "email";
  static const keyAuthData = "authData";

  /// Constructs a new [ParseUser] with no data in it. A [ParseUser] constructed in this way will not
  /// have an objectId and will not persist to the database until [register] is called.
  ParseUser({String objectId, dynamic json})
      : super(keyParseClassName, objectId: objectId, json: json);

  /// Retrieves the username.
  String get username => getString(keyUsername);

  /// Retrieves the email address.
  String get email => getString(keyEmail);

  set username(String value) {
    _data[keyUsername] = value;
  }

  /// Sets the password.
  set password(String value) {
    _data[keyPassword] = value;
  }

  /// Sets the email address.
  set email(String value) {
    _data[keyEmail] = value;
  }

  /// This retrieves the currently logged in [ParseUser] with a valid session, either from memory or
  /// disk if necessary.
  static Future<ParseUser> get currentUser =>
      FlutterParse._channel.invokeMethod('getCurrentUser').then((jsonString) {
        if (jsonString != null && jsonString is String) {
          final jsonObject = json.decode(jsonString);
          return ParseUser(json: jsonObject);
        }
      });

  /// Constructs a query for {@code ParseUser}.
  static ParseQuery<ParseUser> get query => new ParseQuery<ParseUser>(keyParseClassName);

  /// Logs in a user with a username and password. On success, this saves the session to disk, so you
  /// can retrieve the currently logged in user using [currentUser].
  static Future<ParseUser> logIn(
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

  /// Signs up a new user. You should call this instead of [saveInBackground()] for new [ParseUser]s. This
  /// will create a new [ParseUser] on the server, and also persist the session on disk so that you can
  /// access the user using [currentUser].
  ///
  /// A `username` and `password` must be set before calling `register`.
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

  /// Logs out the currently logged in user session. This will remove the session from disk, log out
  /// of linked services, and future calls to [currentUser] will return `null`.
  static Future<void> logOut() async {
    return FlutterParse._channel.invokeMethod('logout');
  }
}
