
import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:provider/provider.dart';

class FeedHomeTab with HomePageTab {

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
    return AppBarTabs(tabs: ["Following"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    if (Auth.getInstance(context).isLoggedIn){
      FeedProvider feedProvider = FeedProvider.getInstance(context);
      FeedController homeFeedController =
          feedProvider.getFeedControllerById(
              context: context,
              id: Home.feedID,
              providerFunction: ProviderFunction.NONE,
              clearData: false
          );
      return [
       BetterFeed(
                  providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                  providerResultType: ProviderResultType.TWEET_RESULT,
                  feedController: feedController ?? homeFeedController,
                  removeController: false,
                  removeRefreshIndicator: false,
       ),

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
      icon: const Icon(Icons.add,color: Colors.white,),
      tappedIcon: const Icon(Icons.post_add_rounded,color: Colors.white,),
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
      onTab: () async {
        dynamic returnArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {});
        if (returnArguments != null && returnArguments["success"] != null && returnArguments["success"] == true){
          List<TweetData> tweetData =  returnArguments["tweets"];

          Map<String,TweetData> mappedTweets = {};
          for(TweetData tweet in tweetData){
            mappedTweets.putIfAbsent(tweet.id, () => tweet);
          }

          if(!context.mounted) return;

          FeedProvider.getInstance(context).getFeedControllerById(
              context: context,
              id: UserProfile.profileFeedPosts + Auth.getInstance(context).getCurrentUser()!.id,
              providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
              clearData: false
          ).appendToBegin(mappedTweets);
        }

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
    );
  }

  @override
  void reload(BuildContext context) {
    super.reload(context);
    FeedProvider feedProvider = FeedProvider.getInstance(context);
    FeedController homeFeedController =
    feedProvider.getFeedControllerById(
        context: context,
        id: Home.feedID,
        providerFunction: ProviderFunction.NONE,
        clearData: false
    );
    homeFeedController.resetFeed();
    homeFeedController.updateFeeds();
  }
}