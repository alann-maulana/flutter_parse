# Flutter Parse   
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Feyro-labs%2Fflutter_parse.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Feyro-labs%2Fflutter_parse?ref=badge_shield)  [![Build Status](https://travis-ci.org/eyro-labs/flutter_parse.svg?branch=master)](https://travis-ci.org/eyro-labs/flutter_parse#)  [![](https://img.shields.io/pub/v/flutter_parse.svg)](https://github.com/eyro-labs/flutter_parse)  [![Coverage Status](https://coveralls.io/repos/github/eyro-labs/flutter_parse/badge.svg?branch=master)](https://coveralls.io/github/eyro-labs/flutter_parse?branch=master)

Plugin for managing and accessing Parse Server for Dart and Flutter.

Features:
* ParseACL
* ParseCloud
* ParseConfig
* ParseFile
* ParseGeoPoint
* ParseLiveQuery
* ParseObject
* ParseQuery
* ParseRole
* ParseSchema
* ParseSession
* ParseUser
    
## Installation

Add to pubspec.yaml:

```yaml
dependencies:
  flutter_parse: ^1.0.0
```

## Import Library
```dart   
import 'package:flutter_parse/flutter_parse.dart';
```

## Initializing Library

```dart
void main() {
  ParseConfiguration config = ParseConfiguration(
    server: 'YOUR_PARSE_SERVER_URL',
    applicationId: 'YOUR_PARSE_APPLICATION_ID',
    clientKey: 'YOUR_PARSE_CLIENT_KEY',
    localStorage: Storage("path/to/writable/data"),
  );
  Parse.initialize(config);
  runApp(MyApp());
}
```

## Create Object

```dart
final object = ParseObject(className: 'Beacon')
      ..set('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
      ..set('major', 1)
      ..set('enabled', true)
      ..set('timestamp', DateTime.now());
await object.save();
```

## Register User

```dart
final user = ParseUser()
  ..username = 'alan'
  ..password = 'maulana';
await user.signUp();
```

## Query Object

```dart
final query = ParseQuery(className: 'Beacon')
  ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
  ..whereLessThanOrEqualTo('major', 10);
final listObjects = await query.find();
```

# Author

Parse Dart plugin is developed by Eyro Labs. You can contact me at <maulana@cubeacon.com>.

## License

BSD License
- [See LICENSE](https://github.com/eyro-labs/flutter_parse/blob/master/LICENSE)
