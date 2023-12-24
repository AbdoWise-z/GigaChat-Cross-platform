import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({Key? key, this.tabController,this.onTap}) : super(key: key);

  final TabController? tabController;
  static const List<String> tabs = [
    "Posts" , "Likes",
  ];
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: tabs.map((e) => Text(e)).toList(),
      onTap: onTap,
      tabAlignment: TabAlignment.fill,
    );
  }
}
