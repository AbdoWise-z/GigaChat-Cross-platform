import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/trend-data.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/trends/trend-widget.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import 'package:provider/provider.dart';

class BetterFeed extends StatefulWidget {
  final bool removeController;
  final bool removeRefreshIndicator;
  final ProviderFunction providerFunction;
  final ProviderResultType providerResultType;
  final FeedController feedController;
  final bool? cancelNavigationToUserProfile;
  final bool filterBlockedUsers;

  final String? userId,userName, tweetID, keyword;
  final TweetData? mainTweetForComments;

  const BetterFeed({
    super.key,
    required this.removeController,
    required this.removeRefreshIndicator,
    required this.providerFunction,
    required this.providerResultType,
    required this.feedController,
    this.userId,
    this.userName,
    this.tweetID,
    this.keyword,
    this.cancelNavigationToUserProfile = false,
    this.mainTweetForComments,
    this.filterBlockedUsers = false,
  });

  @override
  State<BetterFeed> createState() => _BetterFeedState();
}

class _BetterFeedState extends State<BetterFeed> {
  late FeedController _feedController;
  late Timer timer;
  ScrollController? _scrollController;

  Future<void> refreshFeed() async {
   await _feedController.fetchFeedData(
        username: widget.userId,
        tweetID: widget.tweetID,
        keyword: widget.keyword,
        mainTweet: widget.mainTweetForComments
    );
   try {
     if (context.mounted) {
       setState(() {});
     }
   } catch(e){
     if (kDebugMode) {
       print("Handled");
     }
   }
  }

  Future<void> addComment(BuildContext context,TweetData tweetData) async {
    dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
      "reply" : tweetData,
    });

    if(retArguments["success"] != null && retArguments["success"] == true){

      List<TweetData> tweetList = retArguments["tweets"];
      if(
      widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS
      &&
      widget.tweetID! == tweetData.id
      ){
        Map<String,TweetData> mappedTweets = {};
        for (TweetData tweetData in tweetList){
          mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
        }
        _feedController.appendToBegin(mappedTweets);
      }

      tweetData.repliesNum += 1;
      setState(() {});
    }
  }

  Tweet makeTweetFromData({
    required TweetData tweetData,
    required User currentUser,
    required bool isSinglePostView,
    required bool addVerticalDivider,
    required bool cancellationPosition,
    required bool sameUser
  }){
        return Tweet(
        tweetOwner: tweetData.tweetOwner,
        tweetData: tweetData,
        isRetweet: tweetData.isRetweeted,
        isSinglePostView: isSinglePostView,
        callBackToDelete: (String tweetID){
          _feedController.deleteTweet(tweetID);
          setState(() {});
        },
        showVerticalDivider: addVerticalDivider,
        deleteOnUndoRetweet: widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS && (widget.userId! == currentUser.id),
        onCommentButtonClicked: () => addComment(context, tweetData),
        parentFeed: _feedController,
        cancelSameUserNavigation: cancellationPosition && sameUser
      );
  }


  List<Widget>? wrapDataInWidget() {
    switch(widget.providerResultType){
      // The Result Of Searching For User
      case ProviderResultType.USER_RESULT:
        return wrapDataInUserWidgets();
      // The Normal View For Tweets
      case ProviderResultType.TWEET_RESULT:
        return wrapDataInTweetWidgets();
      case ProviderResultType.TREND_RESULT:
        return wrapDataInTrendWidgets();
    }
  }

  List<Widget>? wrapDataInUserWidgets(){
    List<User> userResult = _feedController.getCurrentData().cast<User>();
    if (widget.filterBlockedUsers){
      userResult.removeWhere((User user) => user.isWantedUserBlocked ?? false);
    }
    return userResult.map((User user){
      return UserResult(user: user, disableFollowButton: false);
    }).toList();
  }

  List<Widget>? wrapDataInTweetWidgets(){
    List<TweetData> tweetResult = _feedController.getCurrentData().cast<TweetData>();
    bool addVerticalDivider = true;
    List<Tweet> resultWidgets = [];
    for (TweetData tweetData in tweetResult){
      if(widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS){
        tweetData.reTweeter = User(name: widget.userName!, id: widget.userId!);
      }
      User currentUser = Auth.getInstance(context).getCurrentUser()!;

      bool cancellationPosition = (widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS || widget.cancelNavigationToUserProfile != null);
      bool sameUser = tweetData.tweetOwner.id == currentUser.id;
      bool isSinglePostView = widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS && tweetData.id == widget.mainTweetForComments!.id;

      addVerticalDivider &= (!isSinglePostView && widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS);

      resultWidgets.add(
          makeTweetFromData(
              tweetData: tweetData,
              isSinglePostView: isSinglePostView,
              addVerticalDivider: addVerticalDivider || (tweetData.replyTweet != null && widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS),
              cancellationPosition: cancellationPosition,
              sameUser: sameUser,
              currentUser: currentUser
          ));

      if (tweetData.replyTweet != null &&
          widget.providerFunction == ProviderFunction.GET_TWEET_COMMENTS &&
          !isSinglePostView){

        resultWidgets.add(
            makeTweetFromData(
                tweetData: tweetData.replyTweet!,
                isSinglePostView: false,
                addVerticalDivider: false,
                cancellationPosition: cancellationPosition,
                sameUser: sameUser,
                currentUser: currentUser
            ));
      }
    }
    return resultWidgets;
  }

  List<Widget>? wrapDataInTrendWidgets(){
    List<TrendData> trendResult = _feedController.getCurrentData().cast<TrendData>();
    return trendResult.map((trendData) => TrendWidget(trendData: trendData)).toList();
  }

  @override
  void initState() {
    super.initState();
    _feedController = widget.feedController;
    _feedController.fetchingMoreData = false;
    _feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    timer = Timer(const Duration(seconds: 1), () { });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Home.getScrollGlobalKey(context) == null){
        _scrollController = ScrollController();
      }
      else{
        _scrollController = Home.getScrollGlobalKey(context)!.currentState!.innerController;
      }
      _scrollController!.addListener(() async {
        if (_scrollController!.position.pixels == _scrollController!.position.maxScrollExtent)
        {
          _feedController.fetchingMoreData = true;
          if (context.mounted) {
            setState(() {});
          }
          await refreshFeed();
          _feedController.fetchingMoreData = false;

          if (context.mounted) {
            setState(() {});
          }
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
        builder: (_,__,___){

          if (_feedController.isLoading()){
            refreshFeed();
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(child: CircularProgressIndicator())
            );
          }

          List<Widget>? widgetList = wrapDataInWidget();

          Widget finalWidget = Container();

          if(widgetList == null || widgetList.isEmpty)
          {
            finalWidget = SingleChildScrollView(
                child: SizedBox(
                    height: 0.8 * MediaQuery.of(context).size.height,
                    child: const NothingYet()
                )
            );
          }
          else{
            finalWidget = SingleChildScrollView(
              controller: widget.removeController == true ? null : _scrollController,
              child: Column(
                  children: [
                    ...widgetList,
                    Visibility(visible: _feedController.fetchingMoreData, child: const CircularProgressIndicator()),
                    const SizedBox(height: 10,)
                  ]
              ),
            );
          }

          finalWidget = widget.removeRefreshIndicator ? finalWidget :
              RefreshIndicator(
                  child: finalWidget,
                  onRefresh: () async {
                    _feedController.resetFeed();
                    setState(() {});
                  }
              );
          return finalWidget;
        }
    );

  }

}
