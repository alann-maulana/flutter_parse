part of flutter_parse;

class ParseUser extends ParseObject {
  static const _keyCurrentUser = '_currentUser';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyEmail = 'email';
  static const _keySessionToken = 'sessionToken';
  static const _keyAuthData = 'authData';

  static const _readOnlyKeys = <String>[_keySessionToken, _keyAuthData];

  bool _isCurrentUser;

  ParseUser({String objectId})
      : _isCurrentUser = false,
        super(className: '_User', objectId: objectId);

  factory ParseUser._fromJson({dynamic json}) {
    final user = ParseUser().._mergeJson(json);
    return user;
  }

  factory ParseUser.fromObject({@required ParseObject object}) {
    return ParseUser._fromJson(json: object._toJson);
  }

  Future<ParseSession> get session => ParseSession._me();

  static Future<_LocalStorage> get _currentUserStorage =>
      _parseLocalStorage.get(_keyCurrentUser);

  static Future<ParseUser> get currentUser async {
    final storage = await _currentUserStorage;
    if (storage != null &&
        storage.getData() != null &&
        storage.getData().isNotEmpty) {
      final user = ParseUser._fromJson(json: storage.getData())
        .._isCurrentUser = true;
      return user;
    }

    return null;
  }

  @override
  bool isKeyMutable(String key) {
    return !_readOnlyKeys.contains(key);
  }

  bool get isCurrentUser => _isCurrentUser;

  String get sessionId => getString(_keySessionToken);

  String get username => getString(_keyUsername);

  String get email => getString(_keyEmail);

  set username(String value) {
    set(_keyUsername, value);
  }

  set password(String value) {
    set(_keyPassword, value);
    _data.remove(_keyPassword);
  }

  set email(String value) {
    set(_keyEmail, value);
  }

  // region EXECUTORS
  Future<ParseUser> save() async {
    await super.save();
    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.objectId == this.objectId) {
      final storage = await _currentUserStorage;
      await storage.setData(this._toJson);
    }
    return this;
  }

  Future<ParseUser> fetch({List<String> includes}) async {
    await super.fetch(includes: includes);
    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.objectId == this.objectId) {
      final storage = await _currentUserStorage;
      await storage.setData(this._toJson);
    }
    return this;
  }

  Future<ParseUser> signUp() async {
    await _uploadFiles();

    dynamic jsonBody = json.encode(_operations);
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final result = await _parseHTTPClient.post(
      '${_parse._uri.path}users',
      body: jsonBody,
      headers: headers,
    );
    _mergeJson(result);
    _isCurrentUser = true;

    final storage = await _currentUserStorage;
    await storage.setData(_toJson);

    return Future.value(this);
  }

  static Future<ParseUser> signIn(
      {@required String username, @required String password}) async {
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final params = <String, String>{'username': username, 'password': password};
    final result = await _parseHTTPClient.get('${_parse._uri.path}login',
        params: params, headers: headers);
    final user = ParseUser._fromJson(json: result);

    final storage = await _currentUserStorage;
    await storage.setData(user._toJson);

    return Future.value(user);
  }

  static Future<void> resetPassword({@required String email}) async {
    final body = json.encode(<String, String>{'email': email});
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };
    await _parseHTTPClient.post(
      '${_parse._uri.path}requestPasswordReset',
      body: body,
      headers: headers,
    );
    return;
  }

  static Future<void> signOut() async {
    final storage = await _currentUserStorage;
    await storage.delete();
    return;
  }
  // endregion
}
