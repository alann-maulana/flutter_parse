import 'dart:async';

import 'package:meta/meta.dart';

import '../flutter_parse.dart';

/// The [ParseSession] is a local representation of session data that can be saved
/// and retrieved from the Parse cloud.
class ParseSession extends ParseObject {
  static const kClassName = '_Session';

  @visibleForTesting
  ParseSession({
    String? objectId,
    json,
  }) : super(
          className: kClassName,
          objectId: objectId,
          json: json,
        );

  factory ParseSession.fromJson({dynamic json}) {
    return ParseSession(json: json);
  }

  /// Return the expires time of session
  DateTime? get expiresAt => getDateTime('expiresAt');

  /// Return true if session is restricted, false otherwise
  bool? get restricted => getBoolean('restricted');

  /// `createdWith` (readonly): Information about how this session was created
  Map<String, dynamic>? get createdWith => getMap<dynamic>('createdWith');

  /// `action` could have values: `login`, `signup`, `create`, or `upgrade`.
  /// The create action is when the developer manually creates the session by
  /// saving a `Session` object. The `upgrade` action is when the user is
  /// upgraded to revocable session from a legacy session token.
  String get action => createdWith == null ? null : createdWith!['action'];

  /// `authProvider` could have values: `password`, `anonymous`, `facebook`, or `twitter`.
  String get authProvider =>
      createdWith == null ? null : createdWith!['authProvider'];

  /// Return the [ParseUser] of this session
  ParseUser? get user => getParseUser('user');

  /// Return the session token
  String? get sessionToken => getString('sessionToken');

  /// Get the current logged [ParseUser] session
  static Future<ParseSession> me() async {
    final session = ParseSession(objectId: 'me');
    await session.fetch();
    return session;
  }

  @override
  Uri get path {
    assert(parse.configuration != null);
    final uri = parse.configuration!.uri;
    String path = '${uri.path}/sessions';

    if (objectId != null) {
      path = '$path/$objectId';
    }

    return uri.replace(path: path);
  }
}
