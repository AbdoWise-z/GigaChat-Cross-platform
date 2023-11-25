import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';

//every home page tab should implement this :)


mixin HomePageTab {

  String? getTitle(BuildContext context){}
  bool isAppBarPinned(BuildContext context){return true;}
  AppBarSearch? getSearchBar(BuildContext context){}
  AppBarTabs? getTabs(BuildContext context){}
  int getInitialTab(BuildContext context){return 0;}
  List<AppBarAction> getActions(BuildContext context){ return []; }
  List<Widget>? getTabsWidgets(BuildContext context){}
  Widget? getPage(BuildContext context){}
  Widget? getFloatingActionButton(BuildContext context){}
  int getNotificationsCount(BuildContext context){
    return 1;
  }
}
