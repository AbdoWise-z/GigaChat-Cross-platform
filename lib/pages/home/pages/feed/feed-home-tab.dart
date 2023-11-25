
import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/home/widgets/app-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/util/user-data.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';
import 'package:gigachat/widgets/post.dart';

class FeedHomeTab with HomePageTab {
  @override
  String? getTitle(BuildContext context) {
    // TODO: implement getTitle
    return super.getTitle(context);
  }

  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [];
  }

  @override
  int getInitialTab(BuildContext context) {
    return 0;
  }

  @override
  int getNotificationsCount(BuildContext context) {
    return 0;
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return null;
  }

  @override
  AppBarTabs? getTabs(BuildContext context) {
    return AppBarTabs(tabs: ["For you" , "Following"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }

  TweetData tweet = getDefaultTweet();

  @override
  List<Widget>? getTabsWidgets(BuildContext context) {
    if (Auth.getInstance(context).isLoggedIn){
      return [
        FeedWidget(showFollowingTweets: true),
        FeedWidget(showFollowingTweets: true)
      ];
    }
    return const [
      Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("Login to view :)"),
      ),
      Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("Login to view :)"),
      ),
    ];
  }

  @override
  Widget? getPage(BuildContext context) {
    return null; //will never be called since taps is not null
  }

  @override
  Widget? getFloatingActionButton(BuildContext context) {
    return FloatingActionMenu(
      icon: const Icon(Icons.add),
      tappedIcon: const Icon(Icons.post_add_rounded),
      title: const Padding(
        padding: EdgeInsets.only(right: 25),
        child: Text(
          "Post" ,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      onTab: () {
        //print("you clicked me ?");
      } ,
      items: [
        FloatingActionMenuItem(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              splashRadius: 25,
              color: Colors.blue,
              icon: const Icon(Icons.photo_camera_back_outlined),
              onPressed: () {
                //print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "Photos" ,
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
              icon: const Icon(Icons.mic_rounded),
              onPressed: () {
                //print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "Spaces" ,
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
              icon: const Icon(Icons.camera_outlined),
              onPressed: () {
                //print("that worked !");
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "GoLive" ,
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