import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse_storage_interface/flutter_parse_storage_interface.dart';

main() async {
  // initialize storage interface using in memory parse storage (default)
  FlutterParseStorageInterface.instance = InMemoryFlutterParseStorage.empty();

  // create configuration
  ParseConfiguration config = ParseConfiguration(
    server: 'YOUR_PARSE_SERVER_URL',
    applicationId: 'YOUR_PARSE_APPLICATION_ID',
    clientKey: 'YOUR_PARSE_CLIENT_KEY',
    masterKey: 'YOUR_PARSE_MASTER_KEY',
  );
  // initialize parse using configuration
  Parse.initialize(config);

  // create and save object
  final object = ParseObject(className: 'Beacon')
    ..set('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
    ..set('major', 1)
    ..set('enabled', true)
    ..set('timestamp', DateTime.now());
  await object.save();

  // query for objects
  final query = ParseQuery(className: 'Beacon')
    ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
    ..whereLessThanOrEqualTo('major', 10);
  final beacons = await query.find();
  print(beacons.length);
}
