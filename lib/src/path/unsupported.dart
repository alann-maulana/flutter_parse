import 'dart:async';

final PathProvider pathProvider = PathProvider._();

class PathProvider {
  PathProvider._();

  Future<String> databasePath(String dbName) async {
    throw 'Platform Not Supported';
  }
}