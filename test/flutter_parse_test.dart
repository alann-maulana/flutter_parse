import 'package:flutter_parse/parse.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Parse parse;
    setUp(() {
      parse = Parse.initialize(
        server: 'PARSE_SERVER',
        applicationId: 'PARSE_APPLICATION_ID',
        clientKey: 'PARSE_CLIENT_KEY',
      );
    });

    test('Parse initialization', () {
      expect(parse.initialized, isTrue);
    });
  });
}
