import 'package:flutter/cupertino.dart';
import 'package:gigachat/pages/home/pages/internal-home-page.dart';

import 'main.dart';

class Globals{

  static late final GigaChat application;

  static final GlobalKey<NavigatorState> appNavigator = GlobalKey();
  static final GlobalKey<NavigatorState> chatNavigator = GlobalKey();
  static final GlobalKey<NavigatorState> homeNavigator = GlobalKey();
  static final GlobalKey<InternalHomePageState> homeKey = GlobalKey();

  static double HomeScreenWidth = 0;
  static double get HomeWideScreenWidth {
    return isWideVersion ? HomeScreenWidth + 300 : HomeScreenWidth;
  }
  static double ChatScreenWidth = 0;


  static bool isWideVersion   = false;
  static bool isChatSeparated = false;
  static bool isLoadingChat   = false;

  static final List<String> profileStack = [];
  static String? currentActiveChat;

}