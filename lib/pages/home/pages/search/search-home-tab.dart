import 'package:flutter/material.dart';
import 'package:gigachat/pages/Search/search.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';

class SearchHomeTab with HomePageTab
{
  @override
  String? getTitle(BuildContext context){
    return null;
  }

  @override
  bool isAppBarPinned(BuildContext context){
      return true;
  }

  @override
  bool isBottomNavPinned(BuildContext context){
    return false;
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context){
    return AppBarSearch(hint: "search", onClick: (){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SearchPage();
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
  AppBarTabs? getTabs(BuildContext context){
    return null;
  }

  @override
  int getInitialTab(BuildContext context){
    return 0;
  }

  @override
  List<AppBarAction> getActions(BuildContext context){
    return [];
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context){
    return null;
  }

  @override
  Widget? getPage(BuildContext context){
    return Container(
      color: Colors.white,
    );
  }

  @override
  Widget? getFloatingActionButton(BuildContext context){
    return null;
  }

  @override
  int getNotificationsCount(BuildContext context){
    return 1;
  }
}