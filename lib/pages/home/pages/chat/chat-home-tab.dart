
import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/chat/chat-list-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-settings-page.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';

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
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatSettingsPage()));
      },),
    ];
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return AppBarSearch(
      hint: "Search Direct Messages",
      onClick: () {
        //TODO: open search page
      },
    );
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

  @override
  bool isBottomNavPinned(BuildContext context) {
    return true;
  }
}