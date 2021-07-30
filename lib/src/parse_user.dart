import 'dart:async';
import 'dart:convert';

import '../flutter_parse.dart';
import 'parse_http_client.dart';
import 'parse_local_storage.dart';
import 'parse_object.dart';
import 'parse_session.dart';

/// The [ParseUser] is a local representation of user data that can be saved and retrieved from
/// the Parse cloud.
class ParseUser extends ParseObject {
  static const _keyCurrentUser = '_currentUser';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyEmail = 'email';
  static const _keySessionToken = 'sessionToken';
  static const _keyAuthData = 'authData';

  static const _readOnlyKeys = <String>[_keySessionToken, _keyAuthData];

  bool _isCurrentUser;

  /// Constructs a new [ParseUser]
  ///
  /// Set the [objectId] of saved [ParseUser] if any.
  /// Set the [json] with `Map<String, dynamic>`
  ParseUser({String? objectId, dynamic json})
      : _isCurrentUser = false,
        super(
          className: '_User',
          objectId: objectId,
          json: json,
        );

  /// Constructs a new [ParseUser] from json data
  factory ParseUser.fromJson({dynamic json}) {
    return ParseUser(json: json);
  }

  /// Constructs a new [ParseUser] from [ParseObject]
  factory ParseUser.fromObject({required ParseObject object}) {
    if (object.className != '_User') {
      throw Exception('invalid parse user className');
    }
    return ParseUser.fromJson(json: object.asMap);
  }

  /// Return current logged in user session
  Future<ParseSession> get session => ParseSession.me();

  static Future<LocalStorage?> get _currentUserStorage =>
      parseLocalStorage.get(_keyCurrentUser);

  /// This retrieves the currently logged in [ParseUser] with a valid session,
  /// either from memory or disk if necessary.
  static Future<ParseUser?> get currentUser async {
    final storage = await _currentUserStorage;
    if (storage != null && storage.getData().isNotEmpty) {
      return ParseUser.fromJson(json: storage.getData()).._isCurrentUser = true;
    }

    return null;
  }

  /// Set user instance as current logged in user
  Future<ParseUser> setCurrentUser() async {
    final storage = await _currentUserStorage;
    if (storage != null) {
      await storage.setData(asMap);
    }
    return this;
  }

  /// Constructs a query for [ParseUser].
  static ParseQuery get query => ParseQuery(className: '_User');

  @override
  bool isKeyMutable(String key) {
    return !_readOnlyKeys.contains(key);
  }

  /// True if this is current logged in user
  bool get isCurrentUser => _isCurrentUser;

  /// Return session id of user
  String? get sessionId => getString(_keySessionToken);

  /// Return username of user
  String? get username => getString(_keyUsername);

  /// Retrieves the email address.
  String? get email => getString(_keyEmail);

  /// Sets the username. Usernames cannot be null or blank.
  set username(String? value) {
    if (value != null) {
      set(_keyUsername, value);
    }
  }

  /// Sets the password.
  set password(String value) {
    set(_keyPassword, value);
  }

  /// Sets the email address.
  set email(String? value) {
    if (value != null) {
      set(_keyEmail, value);
    }
  }

  // region EXECUTORS
  /// Saves this user to the server.
  Future<ParseUser> save({bool useMasterKey = false}) async {
    await super.save(useMasterKey: useMasterKey);
    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.objectId == this.objectId) {
      final storage = await _currentUserStorage;
      if (storage != null) {
        await storage.setData(this.asMap);
      }
    }
    return this;
  }

  /// Fetches this user with the data from the server.
  Future<ParseUser> fetch(
      {List<String>? includes, bool useMasterKey = false}) async {
    await super.fetch(includes: includes, useMasterKey: useMasterKey);
    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.objectId == this.objectId) {
      final storage = await _currentUserStorage;
      if (storage != null) {
        await storage.setData(this.asMap);
      }
    }
    return this;
  }

  /// Signing up a user without set it as [currentUser]
  ///
  /// Useful for using with `masterKey`
  Future<ParseUser> create({bool useMasterKey = false}) async {
    assert(parse.configuration != null);
    await uploadFiles();

    dynamic jsonBody = json.encode(operations);
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final result = await parseHTTPClient.post(
      '${parse.configuration!.uri.path}/users',
      body: jsonBody,
      headers: headers,
      useMasterKey: useMasterKey,
    );
    // ignore: invalid_use_of_visible_for_testing_member
    mergeJson(result);
    return this;
  }

  /// Signs up a new user. You should call this instead of {@link #save} for new s. This
  /// will create a new [ParseUser] on the server, and also persist the session on disk so that you can
  /// access the user using [currentUser].
  Future<ParseUser> signUp() async {
    await create();
    _isCurrentUser = true;

    final storage = await _currentUserStorage;
    if (storage != null) {
      await storage.setData(asMap);
    }

    return this;
  }

  /// Authorize a user with a session token. On success, this saves the session to disk, so you can
  /// retrieve the currently logged in user using [currentUser].
  static Future<ParseUser> become(dynamic authData) async {
    assert(parse.configuration != null);
    dynamic jsonBody = json.encode(authData);
    final headers = <String, String>{
      'X-Parse-Revocable-Session': '1',
      'Content-Type': 'application/json',
    };
    final result = await parseHTTPClient.post(
      '${parse.configuration!.uri.path}/users',
      body: jsonBody,
      headers: headers,
    );
    final user = ParseUser.fromJson(json: result);

    final storage = await _currentUserStorage;
    if (storage != null) {
      await storage.setData(user.asMap);
    }

    return user;
  }

  /// Logs in a user with a username and password. On success, this saves the session to disk, so you
  /// can retrieve the currently logged in user using [currentUser].
  static Future<ParseUser> signIn({
    required String username,
    required String password,
  }) async {
    assert(parse.configuration != null);
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final params = <String, String>{'username': username, 'password': password};
    final result = await parseHTTPClient.get(
        '${parse.configuration!.uri.path}/login',
        params: params,
        headers: headers);
    final user = ParseUser.fromJson(json: result);

    await user.setCurrentUser();

    return user;
  }

  /// Requests a password reset email to be sent to the specified email
  /// address associated with the user account. This email allows the user to
  /// securely reset their password on the Parse site.
  static Future<void> resetPassword({required String email}) async {
    assert(parse.configuration != null);
    final body = json.encode(<String, String>{'email': email});
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    return await parseHTTPClient.post(
      '${parse.configuration!.uri.path}/requestPasswordReset',
      body: body,
      headers: headers,
    );
  }

  /// Logs out the currently logged in user session. This will remove the session from disk, log out
  /// of linked services, and future calls to [currentUser] will return `null`.
  static Future<void> signOut() async {
    assert(parse.configuration != null);
    try {
      await parseHTTPClient.post(
        '${parse.configuration!.uri.path}/logout',
        ignoreResult: true,
      );
    } catch (_) {
      // ignores any exception that happen
    }
    final storage = await _currentUserStorage;
    if (storage != null) {
      await storage.delete();
    }
  }

// endregion

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseUser &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          objectId == other.objectId;

  @override
  int get hashCode => className.hashCode ^ objectId.hashCode;
}
