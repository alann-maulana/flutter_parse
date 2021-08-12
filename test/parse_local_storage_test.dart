import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse/src/parse_local_storage.dart';
import 'package:test/test.dart';

void main() {
  group('Parse Local Storage', () {
    setUpAll(() {
      final ParseConfiguration _configuration = ParseConfiguration(
        server: 'https://SERVER',
        applicationId: 'APPLICATION_ID',
        clientKey: 'CLIENT_KEY',
        enableLogging: true,
      );
      Parse.initialize(_configuration);
    });

    const String key1 = 'default local storage must be empty';
    test(key1, () async {
      final localStorage = await parseLocalStorage.get(key1);

      expect(localStorage!.isEmpty, isTrue);
    });

    const String key2 = 'adding local storage with a map must not be empty';
    test(key2, () async {
      final localStorage = await parseLocalStorage.get(key2);
      await localStorage!.setData({'key': 'value'});

      expect(localStorage.isEmpty, isFalse);
      expect(localStorage.getData(), {'key': 'value'});
    });

    const String key3 =
        'remove after adding local storage with a value must be empty';
    test(key3, () async {
      final localStorage = await parseLocalStorage.get(key3);
      await localStorage!.setData({'key': 'value'});

      expect(localStorage.isEmpty, isFalse);
      expect(localStorage.getData(), {'key': 'value'});

      await localStorage.delete();
      expect(localStorage.isEmpty, isTrue);
    });
  });
}
