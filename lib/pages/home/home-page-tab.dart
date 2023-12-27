import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

/// this class represents a home page inside the home
/// the home calls functions defined here to know how
/// exactly it should render this page
mixin HomePageTab {

  /// if this page uses a test title it should return
  /// it to the home page though this function
  /// the home will pass only one parameter [context] which is
  /// the current build context of this state
  String? getTitle(BuildContext context){
    return null;
  }

  /// should the home pin the app bar for this page ?
  bool isAppBarPinned(BuildContext context){return true;}

  /// should the home pin the Bottom navigation bar for this page ?
  /// on desktop version this will value will be overridden with (false)
  bool isBottomNavPinned(BuildContext context){return false;}

  /// how does the search bar for this page look like ?
  /// in case of no search par, just return null
  AppBarSearch? getSearchBar(BuildContext context){
    return AppBarSearch(hint: "search", onClick: (){Navigator.pushNamed(context, "/search");});
  }

  /// defined how the tabs for this page should look like
  /// in case this page doesn't have any tabs, then return null
  AppBarTabs? getTabs(BuildContext context){
    return null;
  }

  /// gets the initial tab for this page, called only once
  /// when the page is switched to by the user
  int getInitialTab(BuildContext context){return 0;}

  /// gets the actions that should be added to the app bar of this page
  /// cannot be null
  List<AppBarAction> getActions(BuildContext context){ return []; }

  /// if this page has tabs, it should return a list of widget each entry of this
  /// list represents one of these tabs, home will pass [feedController] if this page
  /// is the feed page
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}){
    return null;
  }

  /// if this page is only one page preview and has no tabs, then use this function to
  /// define how the page looks like
  /// return null otherwise
  Widget? getPage(BuildContext context){
    return null;
  }

  /// defines the floating action button for this page
  Widget? getFloatingActionButton(BuildContext context){
    return null;
  }

  /// should return a number to indicate how many notifications does this page
  /// has
  /// must be one of :
  /// * -1 : indicates an understatement number of notifications _loading state_
  /// * 0 : no notifications
  /// * >0 : the number of notifications
  ///
  int getNotificationsCount(BuildContext context){
    return 0;
  }

  /// updates the home state
  void setHomeState(void Function() callback){
    // if (homeKey.currentState == null){
    //   print("Bad call to home setState");
    // }

    Future.delayed(Duration.zero , (){ //delay by zero to ensure a build was complete
      var home = Globals.homeKey.currentState;
      if (home != null) {
        home.update(callback);
      }
    });

  }

  /// called once will the home being build for the first time
  /// the [HomePageTab] should use this function to initialize any
  /// handlers / variables it needs
  /// this will always be called before any other function
  void init(BuildContext context) {}

  /// called when a reload action is triggered by the user
  /// for example clicking the page button while the user is
  /// already on that page
  void reload(BuildContext context) {}
}
