import 'package:flutter/cupertino.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/internal-home-page.dart';

import 'main.dart';

/// this class defines global variables for the entire application
class Globals{

  /// the gigachat application instance
  static late final GigaChat application;

  /// the main app navigator
  static final GlobalKey<NavigatorState> appNavigator = GlobalKey();

  /// the chat pages navigator
  static final GlobalKey<NavigatorState> chatNavigator = GlobalKey();

  /// the internal home pages navigator
  static final GlobalKey<NavigatorState> homeNavigator = GlobalKey();

  /// the internal home page global key
  static final GlobalKey<InternalHomePageState> homeKey = GlobalKey();

  /// these variables are calculated at [Home] and define
  /// how much each portion of the app takes from the screen
  static double HomeScreenWidth = 0;
  static double get HomeWideScreenWidth {
    return isWideVersion ? HomeScreenWidth + 302 : HomeScreenWidth;
  }
  static double ChatScreenWidth = 0;
  static bool isWideVersion   = false;
  static bool isChatSeparated = false;
  static bool isLoadingChat   = false;

  /// the current profile page stack
  static final List<String> profileStack = [];

  /// the current active chat ID
  static String? currentActiveChat;

}