import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/AppNavigator.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/chat/chat-home-tab.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/home/pages/internal-home-page.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-home-tab.dart';
import 'package:gigachat/pages/home/pages/search/search-home-tab.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/home/widgets/nav-drawer.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/pages/search/search.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/services/notifications-controller.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';


class Home extends StatefulWidget {
  static const String pageRoute = "/home";
  static const String feedID = "HomeFeed";
  static const String mentionsFeedID = "MentionsFeed";
  const Home({super.key});

  static final List<HomePageTab> Pages = [
    FeedHomeTab(),
    Explore(),
    NotificationsHomeTab(),
    ChatHomeTab(),
  ];

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

  void _triggerNotification() async{
    TriggerNotification? t = await NotificationsController.getLaunchNotification();
    if (t != null){
      if (context.mounted) {
        NotificationsController.dispatchNotification(t, context);
      }
    }
  }


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

    Globals.isWideVersion   = width / height > 1.6;
    Globals.isChatSeparated = width / height > 1;
    //print(width / height);

    Globals.HomeScreenWidth = width;
    Globals.ChatScreenWidth = width;
    if (Globals.isChatSeparated){
      Globals.HomeScreenWidth -= 400;
      Globals.ChatScreenWidth = 400;
    }

    if (Globals.isWideVersion){
      Globals.HomeScreenWidth -= 300;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Navigator(
            key: Globals.homeNavigator,
            onGenerateRoute: AppNavigator.onBuildHomeRoute,
          ),
        ),

        VerticalDivider(width: 2,thickness: 2,),

        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
          child: Visibility(
            visible: Globals.isChatSeparated,
            child: SizedBox(
              width: 400,
              height: double.infinity,
              child: Navigator(
                key: Globals.chatNavigator,
                onGenerateRoute: AppNavigator.onBuildChatRoute,
              ),
            ),
          ),
        )

      ],
    );
  }
}


