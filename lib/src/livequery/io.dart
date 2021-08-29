import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_parse/flutter_parse.dart'
    show ParseConfiguration, ParseException, parse;
import 'package:web_socket_channel/io.dart';

import 'live_query.dart';

final ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient();

class ParseLiveQueryClient extends ParseBaseLiveQueryClient {
  late WebSocket _webSocket;
  IOWebSocketChannel? _channel;
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
      _webSocket = await WebSocket.connect(server);
      if (_webSocket.readyState == WebSocket.open) {
        if (config.enableLogging == true) {
          print('Connecting io web socket');
        }
        _channel = IOWebSocketChannel(_webSocket);
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
      } else {
        callback(ParseException(message: 'Failed to connect'));
      }
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

    if (_webSocket.readyState == WebSocket.open) {
      await _webSocket.close();
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
