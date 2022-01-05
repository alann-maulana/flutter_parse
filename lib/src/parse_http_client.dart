import 'dart:async';
import 'dart:convert';

import 'package:flutter_parse/src/config/config.dart';
import 'package:http/http.dart' as http;

import '../flutter_parse.dart';
import 'http/http.dart';
import 'log/log.dart' as log;

final ParseHTTPClient parseHTTPClient = ParseHTTPClient._internal();

class ParseHTTPClient {
  ParseHTTPClient._internal()
      : assert(parse.configuration != null),
        this._httpClient =
            parse.configuration!.httpClient ?? ParseBaseHTTPClient();

  final http.BaseClient _httpClient;

  ParseConfiguration get config {
    if (parse.configuration == null) {
      throw 'Parse SDK not initialized.';
    }
    return parse.configuration!;
  }

  Future<Map<String, String>> _addHeader(
    Map<String, String>? additionalHeaders, {
    bool useMasterKey = false,
  }) async {
    if (parse.configuration == null) {
      throw 'Parse SDK not initialized.';
    }

    final headers = additionalHeaders ?? <String, String>{};

    if (kOverrideUserAgentHeaderRequest) {
      headers["User-Agent"] = "Dart Parse SDK v$kParseSdkVersion";
    }
    headers['X-Parse-Application-Id'] = config.applicationId;

    // client key can be null with self-hosted Parse Server
    if (!useMasterKey && config.clientKey != null) {
      headers['X-Parse-Client-Key'] = config.clientKey!;
    }
    if (useMasterKey && config.masterKey != null) {
      headers['X-Parse-Master-Key'] = config.masterKey!;
    }

    headers['X-Parse-Client-Version'] = "dart$kParseSdkVersion";

    if (!headers.containsKey('X-Parse-Revocable-Session')) {
      final currentUser = await ParseUser.currentUser;
      if (currentUser != null && currentUser.sessionId != null) {
        headers['X-Parse-Session-Token'] = currentUser.sessionId!;
      }
    }

    return headers;
  }

  Future<dynamic> get(
    Uri uri, {
    bool useMasterKey = false,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    headers = await _addHeader(
      headers,
      useMasterKey: useMasterKey,
    );

    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    final r = await _httpClient.get(
      uri,
      headers: headers,
    );

    dynamic result = {'body': r.body, 'enableLogging': config.enableLogging};
    if (config.compute != null) {
      result = await config.compute!(_parseResponse, result);
    } else {
      result = await _parseResponse(result);
    }

    if (result is ParseException) throw result;
    return result;
  }

  Future<dynamic> delete(
    Uri uri, {
    bool useMasterKey = false,
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    headers = await _addHeader(
      headers,
      useMasterKey: useMasterKey,
    );

    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    final r = await _httpClient.delete(
      uri,
      headers: headers,
    );

    dynamic result = {'body': r.body, 'enableLogging': config.enableLogging};
    if (config.compute != null) {
      result = await config.compute!(_parseResponse, result);
    } else {
      result = await _parseResponse(result);
    }

    if (result is ParseException) throw result;
    return result;
  }

  Future<dynamic> post(
    Uri uri, {
    bool useMasterKey = false,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    bool ignoreResult = false,
  }) async {
    headers = await _addHeader(
      headers,
      useMasterKey: useMasterKey,
    );

    final r = await _httpClient.post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    if (ignoreResult == true) return null;

    dynamic result = {'body': r.body, 'enableLogging': config.enableLogging};
    if (config.compute != null) {
      result = await config.compute!(_parseResponse, result);
    } else {
      result = await _parseResponse(result);
    }

    if (result is ParseException) throw result;
    return result;
  }

  Future<dynamic> put(
    Uri uri, {
    bool useMasterKey = false,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    headers = await _addHeader(
      headers,
      useMasterKey: useMasterKey,
    );

    final r = await _httpClient.put(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    dynamic result = {'body': r.body, 'enableLogging': config.enableLogging};
    if (config.compute != null) {
      result = await config.compute!(_parseResponse, result);
    } else {
      result = await _parseResponse(result);
    }

    if (result is ParseException) throw result;
    return result;
  }
}

dynamic _parseResponse(dynamic map) {
  final body = map['body'] as String;
  final enableLogging = map['enableLogging'] as bool;

  dynamic result;
  try {
    result = json.decode(body);

    if (enableLogging) {
      print("╭-- JSON");
      _parseLogWrapped(body);
      print("╰-- result");
    }
  } catch (_) {
    if (enableLogging) {
      print("╭-- RESPONSE");
      _parseLogWrapped(body);
      print("╰-- result");
    }
  }

  if (result is Map<String, dynamic>) {
    String? error = result['error'];
    if (error != null) {
      int code = result['code'];
      return ParseException(code: code, message: error);
    }

    return result;
  } else if (result is List<dynamic>) {
    return result;
  }

  return ParseException(
    code: ParseException.invalidJson,
    message: 'invalid server response',
    data: body,
  );
}

void logToCURL(http.BaseRequest request) {
  var curlCmd = "curl -X ${request.method} \\\n";
  var compressed = false;
  var bodyAsText = false;
  request.headers.forEach((name, value) {
    if (name.toLowerCase() == "accept-encoding" &&
        value.toLowerCase() == "gzip") {
      compressed = true;
    } else if (name.toLowerCase() == "content-type") {
      bodyAsText =
          value.contains('application/json') || value.contains('text/plain');
    }
    curlCmd += ' -H "$name: $value" \\\n';
  });
  if (<String>['POST', 'PUT', 'PATCH'].contains(request.method)) {
    if (request is http.Request) {
      curlCmd +=
          " -d '${bodyAsText ? request.body : base64Encode(request.bodyBytes)}' \\\n  ";
    }
  }
  curlCmd += (compressed ? " --compressed " : " ") + request.url.toString();
  print("╭-- cURL");
  _parseLogWrapped(curlCmd);
  print("╰-- (copy and paste the above line to a terminal)");
}

void _parseLogWrapped(String text) {
  log.parseLogWrapped(text);
}
