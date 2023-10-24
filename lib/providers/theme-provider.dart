
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {

  static ThemeProvider getInstance(BuildContext ctx){
    return Provider.of<ThemeProvider>(ctx , listen: false);
  }

  ThemeData _theme;
  String _themeName;

  ThemeData get getTheme {
    return _theme;
  }

  String get getThemeName {
    return _themeName;
  }

  ThemeProvider() : _theme = ThemeData.dark() , _themeName = "dark" {
    init();
  }

  void init(){
    //TODO: load the theme data from settings (shared_prefs)

    //now assign the theme based on the name ..
    _updateTheme();
  }

  void _updateTheme(){
    if (_themeName == "dark"){
      _theme = ThemeData.dark();
    }else if (_themeName == "light"){
      _theme = ThemeData.light();
    }
  }

  void setTheme(String theme){
    _themeName = theme;
    //TODO: write the theme name to the settings

    _updateTheme();
    notifyListeners();
  }

}