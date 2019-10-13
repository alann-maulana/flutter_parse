import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pp;

final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  Future<String> databasePath(String dbName) async {
    final appDocDir = await pp.getApplicationDocumentsDirectory();

    return path.join(appDocDir.path, dbName);
  }
}
