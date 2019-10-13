import 'dart:async';

import 'package:flutter_parse/flutter_parse.dart';
import 'package:path/path.dart' as path;

final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  Future<String> databasePath(String dbName) async {
    final appDocDir = parse.configuration.localStoragePath;
    assert(appDocDir != null || appDocDir.isEmpty);

    return path.join(appDocDir, dbName);
  }
}
