import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_parse/flutter_parse.dart';

void main() async {
  // await FlutterParse.initialize(
  //     server: 'YOUR_PARSE_SERVER_URL',
  //     applicationId: 'YOUR_PARSE_APPLICATION_ID',
  //     clientKey: 'YOUR_PARSE_CLIENT_KEY');
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
  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    try {
      // var object = ParseObject('Beacon')
      //   ..set('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
      //   ..set('major', 1)
      //   ..set('enabled', true)
      //   ..set('Position', new ParseGeoPoint())
      //   ..set('timestamp', DateTime.now());
      // object = await object.saveInBackground();
      // print(object);

      // var currentUser = await ParseUser.currentUser;
      // print(currentUser);

      // await ParseUser.logOut();

      // var user = ParseUser()
      //   ..username = 'alfatih'
      //   ..password = 'AlFatih2014';
      // user = await user.register();
      // print(user);

      // currentUser = await ParseUser.currentUser;
      // print(currentUser);

      // var user = await ParseUser.logIn(username: 'alfatih', password: 'AlFatih2014');
      // print(user);

      // currentUser = await ParseUser.currentUser;
      // print(currentUser);

      final query = ParseQuery('Beacon')
        ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
        ..whereLessThanOrEqualTo('major', 10);
      // final listObjects = await query.findAsync();
      // print(listObjects);
      final count = await query.countAsync();
      print(count);
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Flutter Parse Example'),
        ),
      ),
    );
  }
}
