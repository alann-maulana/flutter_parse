import 'package:flutter/material.dart';

import 'package:flutter_parse/flutter_parse.dart';

void main() async {
  await FlutterParse.initialize(
      server: 'YOUR_PARSE_SERVER_URL',
      applicationId: 'YOUR_PARSE_APPLICATION_ID',
      clientKey: 'YOUR_PARSE_CLIENT_KEY');
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
    final object = ParseObject('Beacon')
      ..set('proximityUUID', '')
      ..set('major', 1)
      ..set('enabled', true)
      ..set('timestamp', DateTime.now());
    await object.saveInBackground();

    final user = ParseUser()
      ..username = 'alan'
      ..password = 'maulana';
    await user.register();

    final query = ParseQuery('Beacon')
      ..whereEqualTo('proximityUUID', 'CB10023F-A318-3394-4199-A8730C7C1AEC')
      ..whereLessThanOrEqualTo('major', 10);
    final listObjects = await query.findAsync();
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
