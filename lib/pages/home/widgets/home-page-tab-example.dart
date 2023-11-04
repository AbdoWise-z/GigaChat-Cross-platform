import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
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
    return ExpandableFab(
      distance: 112,
      children: [
        ActionButton(
          onPressed: () => _showAction(context, 0),
          icon: const Icon(Icons.format_size),
        ),
        ActionButton(
          onPressed: () => _showAction(context, 1),
          icon: const Icon(Icons.insert_photo),
        ),
        ActionButton(
          onPressed: () => _showAction(context, 2),
          icon: const Icon(Icons.videocam),
        ),
      ],
    );
  }
}

