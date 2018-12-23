library flutter_parse;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'dart:convert';
import 'dart:typed_data';

part 'parse/parse_date_format.dart';
part 'parse/parse_decoder.dart';
part 'parse/parse_encoder.dart';
part 'parse/parse_exception.dart';
part 'parse/parse_file.dart';
part 'parse/parse_geo_point.dart';
part 'parse/parse_object.dart';
part 'parse/parse_user.dart';
part 'parse/pointer_encoder.dart';

class FlutterParse {
  static const MethodChannel _channel = const MethodChannel('flutter_parse');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

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

  static Future<void> get installation async {
    await _channel.invokeMethod('installation');
  }

  static Future<ParseObject> save(ParseObject object) async {
    final json = await _channel.invokeMethod('saveInBackground', object.toJson());
    if (json != null) {
      return ParseObject.createFromJson(json);
    }

    return null;
  }
}
