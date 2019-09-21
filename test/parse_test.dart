import 'package:flutter_parse/parse.dart';
import 'package:test/test.dart';

final ParseConfiguration _configuration = ParseConfiguration(
  server: 'https://parseapi.back4app.com/',
  applicationId: 'YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP',
  clientKey: '8OELUgIMBuEVNECy3jioGmDvf7QSyshVLshqNS6N',
  enableLogging: true,
);
final Parse initializeParse = Parse.initialize(_configuration);

void main() {
  group('Parse', () {
    Parse parse;
    setUp(() {
      parse = initializeParse;
    });

    test('must be initialized', () {
      expect(parse.initialized, isTrue);
    });

    test('server must equal to https://parseapi.back4app.com', () {
      expect(parse.server == 'https://parseapi.back4app.com', isTrue);
    });

    test(
        'server not equal to https://parseapi.back4app.com/ (removed last backslash)',
        () {
      expect(parse.server == 'https://parseapi.back4app.com/', isFalse);
    });

    test('applicationId must equal to YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP',
        () {
      expect(parse.applicationId == 'YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP',
          isTrue);
    });

    test('clientKey equal to 8OELUgIMBuEVNECy3jioGmDvf7QSyshVLshqNS6N', () {
      expect(parse.clientKey == '8OELUgIMBuEVNECy3jioGmDvf7QSyshVLshqNS6N',
          isTrue);
    });

    test('enableLogging must be true', () {
      expect(parse.enableLogging, isTrue);
    });
  });
}
