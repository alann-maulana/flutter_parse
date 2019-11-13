import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../flutter_parse.dart';
import '../parse_http_client.dart';

class ParseBaseHTTPClient extends IOClient {
  final http.Client _client;

  ParseBaseHTTPClient()
      : this._client =
            IOClient(HttpClient()..connectionTimeout = Duration(seconds: 20));

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (parse.enableLogging) {
      logToCURL(request);
    }

    return await _client.send(request);
  }
}
