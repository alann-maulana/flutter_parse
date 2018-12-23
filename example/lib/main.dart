import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_parse/flutter_parse.dart';

void main() async {
  await FlutterParse.initialize(server: 'https://parseapi.back4app.com/',
      applicationId: 'YtoxICpUQVRdQT96DUAdkGuk85unFzfuOUomHALP',
      clientKey: '8OELUgIMBuEVNECy3jioGmDvf7QSyshVLshqNS6N');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterParse.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
//      final object = ParseObject('Dummy')
//        ..set('parseObject', ParseObject('Dummy', objectId: 'tNEWRRYD7I'))
//        ..set('geopoint', ParseGeoPoint.set(44, 55))
//        ..set('string', 'Flutter test')
//        ..set('integer', 123)
//        ..set('double', 1.23)
//        ..set('timestamp', DateTime.now())
//        ..set('object', {'number': 123, 'string': 'hello'})
//        ..set('array', [12,34,56,78,90])
//      ;
//      final saved = await object.saveInBackground();
//      print(saved);
//
//       final objectUpdated = ParseObject('Dummy', objectId: 'pzGP6Zk9jJ')
//         ..set('double', 4.56)
//         ..set('integer', 456)
//       ;
//       final savedUpdated = await objectUpdated.saveInBackground();
//       print(savedUpdated);
//       final fetch = await ParseUser(objectId: '1Iaa9l6uJP').fetchInBackground();
//       fetch.selectedKeys.forEach((key) {
//         print("$key->${fetch.get(key)}");
//       });

//       final deleted = ParseObject('Dummy', objectId: 'I9jCDHyZn5');
//       await deleted.deleteInBackground();

//      final user = await ParseUser.currentUser;
//      print(user ?? 'null');

//      final user = await ParseUser.login(username: 'arbalest', password: 'mechanical');
//      print(user ?? 'null');

//      await ParseUser.logout();

//      final user2 = await ParseUser.currentUser;
//      print(user2 ?? 'null');

      var newUser = ParseUser()
        ..username = 'harist'
        ..password = 'alfatih'
        ..email = 'harist.alfatih@gmail.com'
        ..set('phone', '081234567890');
      newUser = await newUser.register();
      print(newUser ?? 'null');
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
