import 'package:sembast/sembast.dart';

import 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.html) 'storage_html.dart';

export 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.html) 'storage_html.dart';

/// Local storage manager for internal library use
abstract class Storage {
  /// Factory constructor with writable path to store the database location
  factory Storage(String path) => getStorage(path);

  /// Return the [DatabaseFactory] instance for current platform
  DatabaseFactory get databaseFactory;

  /// Return the [Database] instance
  Future<Database> get database;

  /// Return the [Map] from a key
  Future<Map<String, dynamic>?> get(String key);

  /// Set [Map] data using current key
  Future<bool> put(String key, Map<String, dynamic> data);

  /// Clear current key data, or all of it if key is not set
  Future<bool> clear({String? key});
}
