// Copyright (c) 2018, the Flutter Parse project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.
/// Dart package for accessing Parse Server
library flutter_parse;

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

export 'src/parse_acl.dart';
export 'src/parse_config.dart';
export 'src/parse_exception.dart';
export 'src/parse_file.dart';
export 'src/parse_geo_point.dart';
export 'src/parse_object.dart';
export 'src/parse_query.dart';
export 'src/parse_role.dart';
export 'src/parse_session.dart';
export 'src/parse_user.dart';

const String kParseSdkVersion = "0.2.0";

final Parse parse = Parse._internal();

/// The [Parse] class contains static functions that handle global
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
    return parse..initialize(configuration);
  }

  void initialize(ParseConfiguration configuration) {
    _configuration = configuration;
  }

  ParseConfiguration _configuration;

  ParseConfiguration get configuration => _configuration;

  String get clientKey => configuration.clientKey;

  String get applicationId => configuration.applicationId;

  String get server => configuration.uri.toString();

  bool get enableLogging => configuration.enableLogging;

  bool get initialized => configuration != null;

  bool get isWebPlatform =>
      Uri.base.scheme != 'file' || !Uri.base.path.endsWith('/');
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
