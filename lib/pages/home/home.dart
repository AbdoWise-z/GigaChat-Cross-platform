
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/AppNavigator.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/chat/chat-home-tab.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-home-tab.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/services/notifications-controller.dart';

/// This class is a wrapper around the real home class
/// we use this wrapper to adapt to screen size changes
/// the real home is managed by [InternalHomePage]
/// which will be responsible for managing the various tabs / buttons
/// in the home page
class Home extends StatefulWidget {
  static const String pageRoute = "/home";
  static const String feedID = "HomeFeed";
  static const String mentionsFeedID = "MentionsFeed";

  const Home({super.key});

  /// the pages inside this home widgets
  /// static final cuz we only need one instance
  /// of each home tab page
  static final List<HomePageTab> Pages = [
    FeedHomeTab(),
    Explore(),
    NotificationsHomeTab(),
    ChatHomeTab(),
  ];

  /// controllers defined the tab controller for every page inside the home page
  /// in case the page doesn't have tabs, we just use null
  static final List<TabController?> Controllers = [
    null,
    null,
    null,
    null,
  ];

  @override
  State<Home> createState() => HomeState();

}

class HomeState extends State<Home> with TickerProviderStateMixin {

  /// if the app started from a notification
  /// we try to trigger this notification to open
  /// the app into the right page
  void _triggerNotification() async{
    TriggerNotification? t = await NotificationsController.getLaunchNotification();
    if (t != null){
      if (context.mounted) {
        NotificationsController.dispatchNotification(t, context);
      }
    }
  }

  /// initialized everything :)
  @override
  void initState() {
    super.initState();

    for (int i = 0;i < Home.Pages.length;i++){
      Home.Pages[i].init(context);
      AppBarTabs? tabs = Home.Pages[i].getTabs(context);
      if (tabs != null && tabs.tabs.isNotEmpty){
        Home.Controllers[i] = TabController(
          initialIndex: Home.Pages[i].getInitialTab(context),
          length: tabs.tabs.length,
          vsync: this,
        );
      }
    }

    EventsController.instance.addEventHandler(EventsController.EVENT_LOGOUT, HandlerStructure(id: "home", handler: (map) {
      if (!Auth.getInstance(context).isLoggedIn){
        Navigator.popUntil(context, (route) => false);
        Navigator.pushNamed(context, LandingLoginPage.pageRoute);
        FeedProvider.getInstance(context).resetAllFeeds();
      }
    }));

    _triggerNotification();
  }


  @override
  Widget build(BuildContext context) {


    double width  = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Globals.isWideVersion   = width / height > 1.6 && Platform.isWindows;
    Globals.isChatSeparated = width / height > 1 && Platform.isWindows;
    //print(width / height);

    Globals.HomeScreenWidth = width;
    Globals.ChatScreenWidth = width;
    if (Globals.isChatSeparated){
      Globals.HomeScreenWidth -= 402;
      Globals.ChatScreenWidth = 400;
    }

    if (Globals.isWideVersion){
      Globals.HomeScreenWidth -= 302; // +2 for the Divider
    }

    return WillPopScope(
      onWillPop: () async {
        if (Globals.homeNavigator.currentState != null){
          if (Globals.homeNavigator.currentState!.canPop()){
            Globals.homeNavigator.currentState!.pop();
            return false;
          }
        }
        return true;
      },
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ScaffoldMessenger(
              child: Navigator(
                key: Globals.homeNavigator,
                onGenerateRoute: AppNavigator.onBuildHomeRoute,
              ),
            ),
          ),

          Visibility(
            visible: Globals.isChatSeparated,
            child: VerticalDivider(width: 2,thickness: 2,),
          ),

          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
            child: Visibility(
              visible: Globals.isChatSeparated,
              child: SizedBox(
                width: 400,
                height: double.infinity,
                child: ScaffoldMessenger(
                  child: Navigator(
                    key: Globals.chatNavigator,
                    onGenerateRoute: AppNavigator.onBuildChatRoute,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


