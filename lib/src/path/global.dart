final ParsePathProvider parsePathProvider = ParsePathProvider._();

class ParsePathProvider {
  ParsePathProvider._();

  String databasePath(String dbName) {
    return dbName;
  }
}
