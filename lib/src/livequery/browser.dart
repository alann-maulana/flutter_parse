import 'dart:async';
import 'dart:convert';

import 'package:flutter_parse/flutter_parse.dart'
    show parse, ParseConfiguration, ParseException;
import 'package:web_socket_channel/html.dart';

import 'live_query.dart';

final ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient();

class ParseLiveQueryClient extends ParseBaseLiveQueryClient {
  HtmlWebSocketChannel? _channel;
  bool _userDisconnected = false;

  ParseConfiguration get config {
    if (parse.configuration == null) {
      throw 'Parse SDK not initialized.';
    }
    return parse.configuration!;
  }

  Future<void> connect(ParseLiveQueryCallback callback) async {
    assert(config.liveQueryServer != null);
    _userDisconnected = false;
    final server = config.liveQueryServer!;
    try {
      if (config.enableLogging == true) {
        print('Connecting web socket');
      }
      if (config.enableLogging == true) {
        print('Connecting html web socket');
      }
      _channel = HtmlWebSocketChannel.connect(server);
      if (config.enableLogging == true) {
        print('Listening to stream');
      }
      _channel!.stream.listen(
        (dynamic message) {
          if (config.enableLogging == true) {
            print('RECEIVE: $message');
          }

          try {
            final Map<String, dynamic> result = json.decode(message);
            callback(result);
          } catch (e) {
            callback(ParseException.fromThrow(e));
          }
        },
        onDone: () {
          if (config.enableLogging == true) {
            print('Listening done');
          }

          if (!_userDisconnected) {
            if (config.enableLogging == true) {
              print('Reconnecting');
            }
            connect(callback);
          }
        },
        onError: (error) {
          if (config.enableLogging == true) {
            print('Listening error: $error');
          }

          if (!_userDisconnected) {
            if (config.enableLogging == true) {
              print('Reconnecting');
            }
            connect(callback);
          } else {
            callback(ParseException(message: error.toString()));
          }
        },
      );
    } catch (e) {
      callback(ParseException.fromThrow(e));
    }
  }

  bool get isConnected => _channel != null && !_userDisconnected;

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    _userDisconnected = true;
  }

  @override
  void sendMessage(dynamic message) {
    if (config.enableLogging == true) {
      print('SEND: $message');
    }

    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }
}
