import 'dart:convert';

import 'package:http/http.dart' as http;

import '../flutter_parse.dart';

import 'parse_exception.dart';
import 'parse_user.dart';

final ParseHTTPClient parseHTTPClient = ParseHTTPClient._internal();

class ParseHTTPClient {
  ParseHTTPClient._internal() : this._httpClient = parseBaseHTTPClient();

  final parseBaseHTTPClient _httpClient;

  String _getFullUrl(String path) {
    return parse.configuration.uri.origin + path;
  }

  Future<dynamic> parseResponse(http.Response httpResponse) {
    String response = httpResponse.body;
    final result = json.decode(response);

    if (parse.enableLogging) {
      print("╭-- JSON");
      _httpClient.printWrapped(response);
      print("╰-- result");
    }

    if (result is Map<String, dynamic>) {
      String error = result['error'];
      if (error != null) {
        int code = result['code'];
        throw ParseException(code: code, message: error);
      }

      return Future.value(result);
    } else if (result is List<dynamic>) {
      return Future.value(result);
    }

    throw ParseException(
        code: ParseException.invalidJson, message: 'invalid server response');
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic> params, Map<String, String> headers}) {
    final url = _getFullUrl(path);

    if (params != null) {
      try {
        final uri = Uri.parse(url).replace(queryParameters: params);
        return _httpClient
            .get(uri, headers: headers)
            .then((r) => parseResponse(r));
      } on FormatException catch (e) {
        throw ParseException.fromThrow(e);
      }
    }

    return _httpClient.get(url, headers: headers).then((r) => parseResponse(r));
  }

  Future<dynamic> delete(String path,
      {Map<String, String> params, Map<String, String> headers}) {
    final url = _getFullUrl(path);

    if (params != null) {
      try {
        var uri = Uri.parse(url).replace(queryParameters: params);
        return _httpClient.delete(uri, headers: headers).then((r) {
          return parseResponse(r);
        });
      } on FormatException catch (e) {
        throw ParseException.fromThrow(e);
      }
    }

    return _httpClient
        .delete(url, headers: headers)
        .then((r) => parseResponse(r));
  }

  Future<dynamic> post(String path,
      {Map<String, String> headers, dynamic body, Encoding encoding}) {
    final url = _getFullUrl(path);

    return _httpClient
        .post(url, headers: headers, body: body, encoding: encoding)
        .then((r) => parseResponse(r));
  }

  Future<dynamic> put(String path,
      {Map<String, String> headers, dynamic body, Encoding encoding}) {
    final url = _getFullUrl(path);

    return _httpClient
        .put(url, headers: headers, body: body, encoding: encoding)
        .then((r) => parseResponse(r));
  }
}

class parseBaseHTTPClient extends http.BaseClient {
  final http.Client _client;

  parseBaseHTTPClient()
      : this._client = parse.configuration.httpClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    assert(parse.applicationId != null);

    request.headers["user-agent"] = "Dart Parse SDK v${kParseSdkVersion}";
    request.headers['X-Parse-Application-Id'] = parse.applicationId;

    // client key can be null with self-hosted Parse Server
    if (parse.clientKey != null) {
      request.headers['X-Parse-Client-Key'] = parse.clientKey;
    }

    request.headers['X-Parse-Client-Version'] = "dart${kParseSdkVersion}";

    final currentUser = await ParseUser.currentUser;
    if (currentUser != null && currentUser.sessionId != null) {
      request.headers['X-Parse-Session-Token'] = currentUser.sessionId;
    }

    if (parse.enableLogging) {
      _logging(request);
    }

    return await _client.send(request);
  }

  void _logging(http.BaseRequest request) {
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
            " -d '${bodyAsText ? request.body : request.bodyBytes}' \\\n  ";
      }
    }
    curlCmd += (compressed ? " --compressed " : " ") + request.url.toString();
    print("╭-- cURL");
    printWrapped(curlCmd);
    print("╰-- (copy and paste the above line to a terminal)");
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
