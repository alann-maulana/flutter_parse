import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

final ParseDB parseDB = ParseDB._();

class ParseDB {
  ParseDB._();

  DatabaseFactory get databaseFactory => databaseFactoryMemory;
}
