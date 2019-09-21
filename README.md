# Flutter Parse   
[![Build Status](https://travis-ci.org/alann-maulana/flutter_parse.svg?branch=master)](https://travis-ci.org/alann-maulana/flutter_parse#)  [![](https://img.shields.io/pub/v/flutter_parse.svg)](https://github.com/alann-maulana/flutter_parse)  [![Coverage Status](https://coveralls.io/repos/github/alann-maulana/flutter_parse/badge.svg?branch=master)](https://coveralls.io/github/alann-maulana/flutter_parse?branch=master)

Packages for managing Parse SDK using pure Dart. 

Features:
* ParseACL
* ParseConfig
* ParseFile
* ParseObject
* ParseQuery
* ParseRole
* ParseSession
* ParseUser
    
## Installation

Add to pubspec.yaml:

```yaml
dependencies:
  flutter_parse: ^0.2.0
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
  );
  Parse.initialize(config);
  runApp(MyApp());
}
```

## Create Object

```dart
final object = ParseObject('Beacon')
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
final query = ParseQuery('Beacon')
  ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
  ..whereLessThanOrEqualTo('major', 10);
final listObjects = await query.findAsync();
```

# Author

Parse Dart plugin is developed by Alann Maulana. You can contact me at <kangmas.alan@gmail.com>.

## License

BSD License
- [See LICENSE](https://github.com/alann-maulana/flutter_parse/blob/master/LICENSE)
