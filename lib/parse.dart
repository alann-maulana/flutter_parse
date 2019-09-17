// Copyright (c) 2018, the Flutter Parse project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library flutter_parse;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_parse/src/mime/mime_type.dart' as mime;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

part 'src/parse_acl.dart';
part 'src/parse_config.dart';
part 'src/parse_date_format.dart';
part 'src/parse_decoder.dart';
part 'src/parse_encoder.dart';
part 'src/parse_exception.dart';
part 'src/parse_file.dart';
part 'src/parse_geo_point.dart';
part 'src/parse_http_client.dart';
part 'src/parse_local_storage.dart';
part 'src/parse_object.dart';
part 'src/parse_query.dart';
part 'src/parse_role.dart';
part 'src/parse_session.dart';
part 'src/parse_user.dart';
part 'src/pointer_encoder.dart';

const String kParseSdkVersion = "0.2.0";

final Parse _parse = Parse._internal();

/// The {@code Parse} class contains static functions that handle global
/// configuration for the Parse library.
class Parse {
  Parse._internal() : _enableLogging = false;

  /// Authenticates this client as belonging to your application.
  /// This must be called before your application can use the Parse library.
  ///
  /// The recommended way is to put a call to
  /// [Parse.initialize] in your `main`'s method:
  ///
  /// ```
  /// void main() {
  ///   Parse.initialize(
  ///       server: 'YOUR_PARSE_SERVER_URL',
  ///       applicationId: 'YOUR_PARSE_APPLICATION_ID',
  ///       clientKey: 'YOUR_PARSE_CLIENT_KEY');
  ///   runApp(MyApp());
  /// }
  /// ```
  factory Parse.initialize({
    @required String server,
    @required String applicationId,
    String clientKey,
    bool enableLogging = false,
  }) {
    assert(server != null);
    assert(applicationId != null);

    if (!server.endsWith("/")) {
      server = server + "/";
    }
    _parse._uri = Uri.parse(server);
    _parse._applicationId = applicationId;
    _parse._clientKey = clientKey;
    _parse._enableLogging = enableLogging;

    return _parse;
  }

  Uri _uri;
  String _applicationId;
  String _clientKey;
  bool _enableLogging;

  String get clientKey => _parse._clientKey;

  String get applicationId => _parse._applicationId;

  String get server => _parse._uri.toString();

  bool get enableLogging => _parse._enableLogging;

  bool get initialized => _parse.applicationId != null;
}

abstract class ParseBaseObject {
  external dynamic get _toJson;

  external String get _path;
}
