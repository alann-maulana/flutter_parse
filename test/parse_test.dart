import 'package:flutter_parse/flutter_parse.dart';
import 'package:test/test.dart';

final ParseConfiguration _configuration = ParseConfiguration(
  server: 'https://parse.dashboard/',
  applicationId: 'MY_APPLICATION_ID',
  clientKey: 'MY_CLIENT_KEY',
  masterKey: 'MY_MASTER_KEY',
  enableLogging: true,
);
final Parse initializeParse = Parse.initialize(_configuration);

void main() {
  group('Parse', () {
    late Parse parse;
    setUp(() {
      parse = initializeParse;
    });

    test('must be initialized', () {
      expect(parse.initialized, isTrue);
    });

    test('server must equal to http://parse.dashboard', () {
      expect(
          ParseConfiguration(
                server: 'http://parse.dashboard',
                applicationId: '',
                enableLogging: false,
              ).uri.toString() ==
              'http://parse.dashboard',
          isTrue);
    });
  });

  group('Parse assertion', () {
    test('throw when server is not start with http or https', () {
      expect(
        () => parse.initialize(
          ParseConfiguration(
            server: 'unknown-server',
            applicationId: 'null',
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throw when live query server is not start with ws or wss', () {
      expect(
        () => parse.initialize(
          ParseConfiguration(
            server: 'unknown-live-query-server',
            applicationId: 'null',
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
