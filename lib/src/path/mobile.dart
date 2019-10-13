import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pp;

final PathProvider pathProvider = PathProvider._();

class PathProvider {
  PathProvider._();

  Future<String> databasePath(String dbName) async {
    final appDocDir = await pp.getApplicationDocumentsDirectory();

    return path.join(appDocDir.path, dbName);
  }
}