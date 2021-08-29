import 'dart:async';

import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse/src/parse_http_client.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:http/retry.dart';

class ParseBaseHTTPClient extends http.BaseClient {
  ParseBaseHTTPClient({
    http.BaseClient? httpClient,
    int retries = 3,
    bool Function(http.BaseResponse) when = _defaultWhen,
    bool Function(Object, StackTrace) whenError = _defaultWhenError,
    Duration Function(int retryCount) delay = _defaultDelay,
    void Function(http.BaseRequest, http.BaseResponse?, int retryCount)?
        onRetry,
  }) : this._client = RetryClient(
          httpClient ?? http.Client(),
          when: when,
          whenError: whenError,
          delay: delay,
        );

  final http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (parse.configuration == null) {
      throw 'Parse SDK not initialized.';
    }
    final config = parse.configuration!;
    if (config.enableLogging) {
      logToCURL(request);
    }

    return _client.send(request);
  }
}

bool _defaultWhen(http.BaseResponse response) => response.statusCode == 503;

bool _defaultWhenError(Object error, StackTrace stackTrace) => false;

Duration _defaultDelay(int retryCount) =>
    const Duration(milliseconds: 500) * math.pow(1.5, retryCount);
