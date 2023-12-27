
import 'package:flutter/material.dart';
import 'package:gigachat/AppNavigator.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/chat/chat-list-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-search-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-settings-page.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/chat-provider.dart';
import 'package:gigachat/services/events-controller.dart';


/// a home tab class to define how the chat page should look for the home
/// its also responsible for tracking the number of active chats and
/// unseen messages and updates the home notifications counter accordingly
class ChatHomeTab with HomePageTab {

  final ChatListPage page = const ChatListPage();

  @override
  Widget? getPage(BuildContext context) {
    return page;
  }

  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [
      AppBarAction(icon: Icons.settings, onClick: () {
        if (ChatSettingsPage.isOpen) return;
        NavigatorState nav = AppNavigator.getNavigator(NavigatorDirection.CHAT, NavigatorDirection.HOME);
        nav.push(MaterialPageRoute(builder: (_) => const ChatSettingsPage()));
      },),
    ];
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return AppBarSearch(hint: "Search Direct Messages", onClick: (){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const ChatSearchPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: 0.0, end: 1.0);
            var fadeAnimation = tween.animate(animation);
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

  @override
  bool isBottomNavPinned(BuildContext context) {
    return true;
  }

  int _seenCount = -1;

  void _update() async {
    if (Auth().getCurrentUser() == null) {
      //idk why
      return;
    }
    List<ChatObject> obj = await ChatProvider.instance.getChats(Auth().getCurrentUser()!.auth!);
    int count = 0;
    for (ChatObject o in obj){
      if (!o.lastMessage!.seen){
        count++;
      }
    }
    _seenCount = count;
    setHomeState(() { });
  }

  void _init() async {
    ChatProvider.instance.init();
    EventsController.instance.addEventHandler(EventsController.EVENT_CHAT_READ_COUNT_CHANGED,
      HandlerStructure(
        id: "ChatHomeTab",
        handler: (data) {
          _update();
        }
      )
    );

    _update();
  }

  @override
  int getNotificationsCount(BuildContext context) {
    return _seenCount;
  }

  @override
  void init(BuildContext context) {
    super.init(context);
    _init();
  }
}