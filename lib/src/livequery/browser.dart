import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter_parse/flutter_parse.dart' show parse, ParseException;
import 'package:web_socket_channel/html.dart';

import 'live_query.dart';

final ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient();

class ParseLiveQueryClient extends ParseBaseLiveQueryClient {
  WebSocket _webSocket;
  HtmlWebSocketChannel _channel;

  Future<void> connect(ParseLiveQueryCallback callback) async {
    final server = parse.configuration.liveQueryServer;
    try {
      if (parse.enableLogging == true) {
        print('Connecting web socket');
      }
      _webSocket = await WebSocket(server);
      if (_webSocket != null && _webSocket.readyState == WebSocket.OPEN) {
        if (parse.enableLogging == true) {
          print('Connecting html web socket');
        }
        _channel = HtmlWebSocketChannel(_webSocket);
        if (parse.enableLogging == true) {
          print('Listening to stream');
        }
        _channel.stream.listen(
              (dynamic message) {
            if (parse.enableLogging == true) {
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
            if (parse.enableLogging == true) {
              print('Listening done');
            }
          },
          onError: (error) {
            if (parse.enableLogging == true) {
              print('Listening error: $error');
            }
            callback(ParseException(message: error.toString()));
          },
        );
      } else {
        callback(ParseException(message: 'Failed to connect'));
      }
    } catch (e) {
      callback(ParseException.fromThrow(e));
    }
  }

  bool get isConnected => _channel != null && _webSocket != null;

  Future<void> disconnect() async {
    if (_channel != null && _channel.sink != null) {
      await _channel.sink.close();
      _channel = null;
    }

    if (_webSocket != null && _webSocket.readyState == WebSocket.OPEN) {
      await _webSocket.close();
      _webSocket = null;
    }
  }

  @override
  void sendMessage(dynamic message) {
    if (parse.enableLogging == true) {
      print('SEND: $message');
    }

    if (_channel != null) {
      _channel.sink.add(message);
    }
  }
}
