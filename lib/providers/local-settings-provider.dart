
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class LocalSettings extends ChangeNotifier {
  static LocalSettings getInstance(BuildContext context , {bool listen = false}){
    return Provider.of<LocalSettings>(context , listen: listen);
  }

  Map<String,dynamic> _values = {};

  static final LocalSettings _localSettings = LocalSettings._internal();
  LocalSettings._internal();

  factory LocalSettings() {
    return _localSettings;
  }

  static LocalSettings get instance{
    return LocalSettings();
}

  ///
  /// this function must be called before the application starts
  /// it loads the settings.json file from disk into the dynamic
  /// [_values] map
  ///
  Future<void> init() async {
    Directory path = await getApplicationDocumentsDirectory();
    File settingsFile = File("${path.path}/settings.json");
    if (! await settingsFile.exists()) return;
    var text = await settingsFile.readAsString();
    if (text.isEmpty) return;
    _values = jsonDecode(text);

    // no need to update since this will be called before the app runs
    // notifyListeners();
  }

  ///
  /// returns a value that's already saved in the settings file
  /// if such value doesn't exist [def] will be returned instead
  ///
  T? getValue<T>({required String name , required T? def}){
    if (_values.containsKey(name)) {
      //print(_values);
      return _values[name] as T;
    }
    return def;
  }

  ///
  /// write a value to the settings map
  /// if the value doesn't exist it creates a new one and sets it
  /// if the value exists then its updated with the new value
  /// if the value exists and [val] was null , then the value will
  /// be removed from the settings map
  ///
  /// [notify] indicates if the function should trigger an event in the the widget tree
  void setValue<T>({required String name , required T? val , bool notify = false}){
    if (val == null){
      _values.remove(name);
    }else{
      _values[name] = val;
    }

    if (notify) {
      notifyListeners();
    }
  }


  ///
  /// writes the settings map to the device storage
  ///
  /// [notify] indicates if the function should trigger an event in the the widget tree
  Future<void> apply({bool notify = false}) async {
    Directory path = await getApplicationDocumentsDirectory();
    File settingsFile = File("${path.path}/settings.json");
    //print("Writing file : ${settingsFile.path} \n with : $_values");
    if (! await settingsFile.exists()) await settingsFile.create(recursive: true);
    var writer = settingsFile.openWrite();
    writer.write(jsonEncode(_values));
    await writer.flush();
    await writer.close();

    if (notify) {
      notifyListeners();
    }
  }


}