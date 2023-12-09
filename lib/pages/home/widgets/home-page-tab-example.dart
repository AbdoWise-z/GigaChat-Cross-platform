import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/home/widgets/app-bar.dart';

import 'menu-fab.dart';

class DummyPage with HomePageTab{

  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [
      AppBarAction(icon: Icons.settings, onClick: () => {})
    ];
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return AppBarSearch(hint: "This is a search bar", onClick: () => {
    });
  }

  @override
  AppBarTabs? getTabs(BuildContext context) {
    //return null;
    return AppBarTabs(tabs: ["tab-0" , "tab-1" , "tab-2"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }


  @override
  String? getTitle(BuildContext context) {
    return null;
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context) {
    return const <Widget>[
      Placeholder(),
      Center(child: Text("مفيش حاجة فعلية لسه")),
      Center(child: Text("Ayyy this is tab-2")),
    ];
  }

  @override
  Widget? getPage(BuildContext context) {
    //if I didn't use tabs .. this will be called instead of getTabsWidgets()
    return Placeholder();
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget? getFloatingActionButton(BuildContext context) {
    return FloatingActionMenu(
      icon: const Icon(Icons.add),
      tappedIcon: const Icon(Icons.arrow_back),
      title: const Padding(
        padding: EdgeInsets.only(right: 25),
        child: Text(
          "Main Title" ,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      onTab: () {
        print("you clicked me ?");
      } ,
      items: [
        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.accessible_forward_outlined),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "life" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.account_tree_sharp),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "my" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),

        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.access_alarm_outlined),
              onPressed: () {
                print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "fk" ,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

