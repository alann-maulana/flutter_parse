import 'package:flutter_parse/flutter_parse.dart';
import 'package:path/path.dart' as path;

final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  String databasePath(String dbName) {
    final appDocDir = parse.configuration.localStoragePath;

    final platform = parse.platform;
    if (platform.isAndroid || platform.isIOS) {
      assert(appDocDir != null && appDocDir.isNotEmpty,
          'Use packages [path_provider] and then set returned [path] from [getApplicationDocumentsDirectory()]');
    }

    if (appDocDir != null && appDocDir.isNotEmpty) {
      return path.join(appDocDir, dbName);
    }

    return dbName;
  }
}
