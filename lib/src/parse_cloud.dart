import 'dart:async';
import 'dart:convert';

import '../flutter_parse.dart';
import 'parse_base_object.dart';
import 'parse_http_client.dart';

const String kParseCloudTypeFunctions = 'functions';
const String kParseCloudTypeJobs = 'jobs';

class ParseCloud extends ParseBaseObject {
  ParseCloud.functions({
    required this.method,
    this.body = const {},
  }) : this.type = kParseCloudTypeFunctions;

  ParseCloud.jobs({
    required this.method,
    this.body = const {},
  }) : this.type = kParseCloudTypeJobs;

  final dynamic body;

  final String method;

  final String type;

  @override
  get asMap => body;

  @override
  Uri get uri {
    assert(parse.configuration != null);
    final uri = parse.configuration!.uri;
    return uri.replace(path: '${uri.path}/$type/$method');
  }

  @override
  String get path {
    return uri.path;
  }

  Future<dynamic> execute({bool useMasterKey = false}) async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    final response = await parseHTTPClient.post(
      uri,
      body: json.encode(body),
      headers: headers,
      useMasterKey: useMasterKey,
    );
    final result = response['result'];

    if (result is List) {
      return result;
    }

    if (result is Map) {
      final error = result['error'];
      final code = result['code'];
      if (error != null) {
        throw ParseException(code: code, message: error);
      }

      return result;
    }

    return result;
  }
}
