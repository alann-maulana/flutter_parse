# Flutter Parse
[![](https://img.shields.io/pub/v/flutter_parse.svg)](https://github.com/alann-maulana/flutter_parse)  

Flutter plugin for managing Parse SDK for both Android and iOS. This plugins wraps both native Parse Android SDK and Parse iOS Framework to be accessed from Flutter code.

Features:
* ParseConfig
* ParseInstallation
* ParseObject
* ParseUser
* ParseQuery
    
## Installation

Add to pubspec.yaml:

```yaml
dependencies:
  flutter_parse: ^0.1.3
```

## Import Library
```dart   
import 'package:flutter_parse/flutter_parse.dart';
```

## Initializing Library

```dart
void main() async {
  await Parse.initialize(
      server: 'YOUR_PARSE_SERVER_URL',
      applicationId: 'YOUR_PARSE_APPLICATION_ID',
      clientKey: 'YOUR_PARSE_CLIENT_KEY');
  
  // initialize parse libraru before running your app
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
await object.saveInBackground();
```

## Register User

```dart
final user = ParseUser()
  ..username = 'alan'
  ..password = 'maulana';
await user.register();
```

## Query Object

```dart
final query = ParseQuery('Beacon')
  ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
  ..whereLessThanOrEqualTo('major', 10);
final listObjects = await query.findAsync();
```

# Author

Flutter Parse plugin is developed by Alann Maulana. You can contact me at <kangmas.alan@gmail.com>.

Parse SDK Android and Parse iOS Frameworks are distributed by [Parse Community](https://github.com/parse-community).

## License

BSD License
- [Parse SDK Android](https://github.com/parse-community/Parse-SDK-Android/blob/master/LICENSE)
- [Parse SDK iOS](https://github.com/parse-community/Parse-SDK-iOS-OSX/blob/master/LICENSE)
