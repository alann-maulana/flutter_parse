import 'dart:io';

import 'package:flutter_parse/flutter_parse.dart';
import 'package:path/path.dart' as path;

final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  String databasePath(String dbName) {
    final appDocDir = parse.configuration.localStoragePath;
    if (Platform.isAndroid || Platform.isIOS) {
      assert(appDocDir != null || appDocDir.isEmpty,
          'Use packages [path_provider] and then set returned [path] from [getApplicationDocumentsDirectory()]');
    }

    if (appDocDir != null || appDocDir.isNotEmpty) {
      return path.join(appDocDir, dbName);
    }

    return dbName;
  }
}
