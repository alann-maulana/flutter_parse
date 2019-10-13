import 'dart:async';

final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  Future<String> databasePath(String dbName) async {
    return dbName;
  }
}
