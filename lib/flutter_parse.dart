library flutter_parse;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'parse/parse_date_format.dart';
part 'parse/parse_decoder.dart';
part 'parse/parse_encoder.dart';
part 'parse/parse_exception.dart';
part 'parse/parse_file.dart';
part 'parse/parse_geo_point.dart';
part 'parse/parse_object.dart';
part 'parse/parse_query.dart';
part 'parse/parse_text_utils.dart';
part 'parse/parse_user.dart';
part 'parse/pointer_encoder.dart';

/// The {@code Parse} class contains static functions that handle global
/// configuration for the Parse library.
class FlutterParse {
  static const MethodChannel _channel = const MethodChannel('flutter_parse');

  /// Authenticates this client as belonging to your application.
  /// This must be called before your application can use the Parse library.
  ///
  /// The recommended way is to put a call to
  /// [FlutterParse.initialize] in your `main`'s method:
  ///
  /// ```
  /// void main() async {
  ///   await FlutterParse.initialize(
  ///       server: 'YOUR_PARSE_SERVER_URL',
  ///       applicationId: 'YOUR_PARSE_APPLICATION_ID',
  ///       clientKey: 'YOUR_PARSE_CLIENT_KEY');
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize(
      {@required String server,
      @required String applicationId,
      @required String clientKey}) async {
    dynamic params = <String, String>{
      'server': server,
      'applicationId': applicationId,
      'clientKey': clientKey
    };
    await _channel.invokeMethod('initialize', params);
  }
}
