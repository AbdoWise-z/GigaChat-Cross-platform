import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

//every home page tab should implement this :)


mixin HomePageTab {

  String? getTitle(BuildContext context){
    return null;
  }
  bool isAppBarPinned(BuildContext context){return true;}
  bool isBottomNavPinned(BuildContext context){return false;}
  AppBarSearch? getSearchBar(BuildContext context){
    return AppBarSearch(hint: "search", onClick: (){Navigator.pushNamed(context, "/search");});
  }
  AppBarTabs? getTabs(BuildContext context){
    return null;
  }
  int getInitialTab(BuildContext context){return 0;}
  List<AppBarAction> getActions(BuildContext context){ return []; }
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}){
    return null;
  }
  Widget? getPage(BuildContext context){
    return null;
  }
  Widget? getFloatingActionButton(BuildContext context){
    return null;
  }
  int getNotificationsCount(BuildContext context){
    return 1;
  }

  void setHomeState(BuildContext context , void Function() callback){
    var home = context.findAncestorStateOfType<HomeState>();
    home!.update(callback);
  }
}
