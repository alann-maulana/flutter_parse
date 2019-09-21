// Copyright (c) 2018, the Flutter Parse project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.
/// Dart package for accessing Parse Server
library flutter_parse;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'src/mime/mime_type.dart' as mime;

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

const String kParseSdkVersion = "0.2.0";

final Parse _parse = Parse._internal();

/// The {@code Parse} class contains static functions that handle global
/// configuration for the Parse library.
class Parse {
  Parse._internal();

  /// Authenticates this client as belonging to your application.
  /// This must be called before your application can use the Parse library.
  ///
  /// The recommended way is to put a call to
  /// [Parse.initialize] in your `main`'s method:
  ///
  /// ```
  /// void main() {
  ///   ParseConfiguration config = ParseConfiguration(
  ///     server: 'YOUR_PARSE_SERVER_URL',
  ///     applicationId: 'YOUR_PARSE_APPLICATION_ID',
  ///     clientKey: 'YOUR_PARSE_CLIENT_KEY',
  ///   );
  ///   Parse.initialize(config);
  ///   runApp(MyApp());
  /// }
  /// ```
  factory Parse.initialize(ParseConfiguration configuration) {
    return _parse.._configuration = configuration;
  }

  ParseConfiguration _configuration;

  String get clientKey => _configuration.clientKey;

  String get applicationId => _configuration.applicationId;

  String get server => _configuration.uri.toString();

  bool get enableLogging => _configuration.enableLogging;

  bool get initialized => _configuration != null;
}

class ParseConfiguration {
  ParseConfiguration({
    @required String server,
    @required this.applicationId,
    this.clientKey,
    this.enableLogging,
    this.client,
  }) : uri = Uri.parse((server.endsWith("/")
            ? server.substring(0, server.length - 1)
            : server));

  final Uri uri;
  final String applicationId;
  final String clientKey;
  final bool enableLogging;
  final http.BaseClient client;
}

abstract class ParseBaseObject {
  external dynamic get _toJson;

  external String get _path;
}
