import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';

import 'parse_http_client.dart';
import 'parse_local_storage.dart';
import 'parse_object.dart';
import 'parse_session.dart';

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

  factory ParseUser.fromJson({dynamic json}) {
    // ignore: invalid_use_of_visible_for_testing_member
    return ParseUser()..mergeJson(json);
  }

  factory ParseUser.fromObject({@required ParseObject object}) {
    return ParseUser.fromJson(json: object.asMap);
  }

  Future<ParseSession> get session => ParseSession.me();

  static Future<LocalStorage> get _currentUserStorage =>
      parseLocalStorage.get(_keyCurrentUser);

  static Future<ParseUser> get currentUser async {
    final storage = await _currentUserStorage;
    if (storage != null &&
        storage.getData() != null &&
        storage.getData().isNotEmpty) {
      return ParseUser.fromJson(json: storage.getData()).._isCurrentUser = true;
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
      await storage.setData(this.asMap);
    }
    return this;
  }

  Future<ParseUser> fetch({List<String> includes}) async {
    await super.fetch(includes: includes);
    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.objectId == this.objectId) {
      final storage = await _currentUserStorage;
      await storage.setData(this.asMap);
    }
    return this;
  }

  Future<ParseUser> signUp() async {
    await uploadFiles();

    dynamic jsonBody = json.encode(operations);
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final result = await parseHTTPClient.post(
      '${parse.configuration.uri.path}/users',
      body: jsonBody,
      headers: headers,
    );
    // ignore: invalid_use_of_visible_for_testing_member
    mergeJson(result);
    _isCurrentUser = true;

    final storage = await _currentUserStorage;
    await storage.setData(asMap);

    return this;
  }

  static Future<ParseUser> become(dynamic authData) async {
    dynamic jsonBody = json.encode(authData);
    final headers = <String, String>{
      'X-Parse-Revocable-Session': '1',
      'Content-Type': 'application/json',
    };
    final result = await parseHTTPClient.post(
      '${parse.configuration.uri.path}/users',
      body: jsonBody,
      headers: headers,
    );
    final user = ParseUser.fromJson(json: result);

    final storage = await _currentUserStorage;
    await storage.setData(user.asMap);

    return user;
  }

  static Future<ParseUser> signIn(
      {@required String username, @required String password}) async {
    final headers = <String, String>{'X-Parse-Revocable-Session': '1'};
    final params = <String, String>{'username': username, 'password': password};
    final result = await parseHTTPClient.get(
        '${parse.configuration.uri.path}/login',
        params: params,
        headers: headers);
    final user = ParseUser.fromJson(json: result);

    final storage = await _currentUserStorage;
    await storage.setData(user.asMap);

    return user;
  }

  static Future<void> resetPassword({@required String email}) async {
    final body = json.encode(<String, String>{'email': email});
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    return await parseHTTPClient.post(
      '${parse.configuration.uri.path}/requestPasswordReset',
      body: body,
      headers: headers,
    );
  }

  static Future<void> signOut() async {
    try {
      await parseHTTPClient.post(
        '${parse.configuration.uri.path}/logout',
        ignoreResult: true,
      );
    } catch (_) {
      // ignores any exception that happen
    }
    final storage = await _currentUserStorage;
    return await storage.delete();
  }
  // endregion
}
