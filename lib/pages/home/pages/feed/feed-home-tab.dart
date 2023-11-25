
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/post-class.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/providers/auth.dart';
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

  TweetData tweet = TweetData(
      id: '1',
      description:
      "when i woke up ... i was riding in a flower carriage, it was my birthday",
      media:
      "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
      views: 12,
      date: DateTime(2022, 5, 30, 12, 24, 30),
      type: "Masterpiece");

  User user = User(name: "Osama", id: "Lolli-Simp2225");

  @override
  List<Widget>? getTabsWidgets(BuildContext context) {
    if (Auth.getInstance(context).isLoggedIn){
      return [
        SingleChildScrollView(
          child: Column(
            children: [
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
            ],
          ),
        )
        ,
        SingleChildScrollView(
          child: Column(
            children: [
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
              Tweet(
                tweetOwner: user,
                tweetData: tweet,
                isRetweet: true,
              ),
            ],
          ),
        )
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
        Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {});
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
                print("that worked !");
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
                print("that worked !");
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
                print("that worked !");
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
    );;
  }
}