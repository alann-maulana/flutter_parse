import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

final ParseDB parseDB = ParseDB._();

class ParseDB {
  ParseDB._();

  DatabaseFactory get databaseFactory => databaseFactoryIo;
}
