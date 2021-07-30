import 'package:flutter_parse/flutter_parse.dart';
import 'package:test/test.dart';

void main() {
  group('ParseQuery className check with generic class', () {
    test('className must be equal', () {
      final query = ParseQuery(className: 'ClassTest');
      expect(query.className == 'ClassTest', isTrue);
    });

    test('className must not be equal', () {
      final query = ParseQuery(className: 'ClassTest');
      expect(query.className == 'ClassName', isFalse);
    });
  });

  group('ParseQuery className check with subclass', () {
    setUp(() {
      ParseObject.registerSubclass((data) => Beacon(data));
    });

    test('className must be equal', () {
      final query = ParseQuery<Beacon>();
      expect(query.className == 'Beacon', isTrue);
    });
  });
}

class Beacon extends ParseObject {
  Beacon(dynamic json) : super(className: 'Beacon', json: json);

  String? get uuid => getString('uuid');

  num? get major => getNumber('major');

  num? get minor => getNumber('minor');
}
