import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';

class StreamSocket {
  final _s = StreamController<String>();
  void Function(String) get addResponse => _s.sink.add;

  Stream<String> get stream => _s.stream;

  void dispose(){
    _s.close();

  }
}

class WebSocketsProvider extends ChangeNotifier{
  static WebSocketsProvider getInstance(BuildContext context){
    return Provider.of<WebSocketsProvider>(context , listen: false);
  }
  WebSocketsProvider._internal();
  static WebSocketsProvider? _instance;
  factory WebSocketsProvider(){
    _instance ??= WebSocketsProvider._internal();
    return _instance!;
  }

  late IO.Socket _socket;

  Future<bool> init(String token) async {
    // var response = await http.get(
    //   Uri.parse(API_WEBSOCKS_LINK),
    // ).timeout(API_TIMEOUT);
    // print("RES: ${response.body}");
    print("WS: starting connection (${API_WEBSOCKS_LINK})");
    _socket = IO.io(API_WEBSOCKS_LINK ,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build()
    );
    Completer<bool> connected = Completer();

    _socket.onConnect((_) {
      connected.complete(true);
      _socket.clearListeners();
      print("WS: connected");

    });
    _socket.onConnectError((_) {
      connected.complete(false);
      _socket.clearListeners();
      print(_);
    });
    _socket.onConnectTimeout((_){
      connected.complete(false);
      _socket.clearListeners();
      print(_);
    });
    _socket.connect();
    return connected.future;
  }

  bool isConnected(){
    return _socket.connected;
  }

  bool destroy(){
    if (!_socket.connected) {
      return false;
    }
    _socket.disconnect();
    return true;
  }

  StreamSocket getStream(String event){
    StreamSocket s = StreamSocket();
    _socket.on(event, (data) => s.addResponse(data));
    return s;
  }

  void send(String event,[data]){
    _socket.emit(event , data);
  }

}