import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';

class StreamSocket<T> {
  final _s = StreamController<T>();
  void Function(T) get addResponse => _s.sink.add;

  Stream<T> get stream => _s.stream;
  StreamController<T> get streamController => _s;


  void dispose(){
    _s.close();
  }
}

class WebSocketsProvider extends ChangeNotifier{
  static WebSocketsProvider get instance{
    return WebSocketsProvider();
  }
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
    //"http://10.0.2.2:3000"
    _socket = IO.io(API_WEBSOCKS_LINK ,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .setExtraHeaders({'token': token}).build()
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

  StreamSocket getStream<T>(String event){
    StreamSocket s = StreamSocket<T>();
    _socket.on(event, (data) {
      if (s.streamController.isClosed){
        return;
      }
      s.addResponse(data);
    });
    return s;
  }

  void send(String event,[data]){
    _socket.emit(event , data);
  }

}