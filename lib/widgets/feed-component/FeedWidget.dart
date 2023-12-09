import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BetterFeed extends StatefulWidget {
  final bool isScrollable;
  final ProviderFunction providerFunction;
  final ProviderResultType providerResultType;
  final FeedController feedController;
  String? userId,userName, tweetID, keyword;

  BetterFeed({
    super.key,
    required this.isScrollable,
    required this.providerFunction,
    required this.providerResultType,
    required this.feedController,
    this.userId,
    this.userName,
    this.tweetID,
    this.keyword,
  });

  @override
  State<BetterFeed> createState() => _BetterFeedState();
}

class _BetterFeedState extends State<BetterFeed> {
  bool? loading;
  late FeedController _feedController;

  @override
  void initState() {
    loading = true;
    _feedController = widget.feedController;
    super.initState();
  }

  void refreshFeed() async {
    await _feedController.fetchFeedData(
        username: widget.userId,
        tweetID: widget.tweetID,
        keyword: widget.keyword
    );
    loading = false;
    if(mounted) {
      setState(() {});
    }
  }



  List<Widget>? wrapDataInWidget() {
    switch(widget.providerResultType){
      // The Result Of Searching For User
      case ProviderResultType.USER_RESULT:
        List<User> userResult = _feedController.getCurrentData().cast<User>();
        return userResult.map((User user){
                  return UserResult(user: user);
        }).toList();
      // The Normal View For Tweets
      case ProviderResultType.TWEET_RESULT:
        List<TweetData> tweetResult = _feedController.getCurrentData().cast<TweetData>();
        int i = 0;
        return tweetResult.map((TweetData tweetData){
                  if(widget.providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS){
                    tweetData.reTweeter = User(name: widget.userName!, id: widget.userId!);
                  }
                  i = i + 1;
                  Tweet noDetector = Tweet(
                    tweetOwner: tweetData.tweetOwner,
                    tweetData: tweetData,
                    isRetweet: tweetData.isRetweeted,
                    isSinglePostView: false,
                    callBackToDelete: (String tweetID){
                      _feedController.deleteTweet(tweetID);
                      setState(() {});
                    },
                  );
                  if (i == tweetResult.length) {
                    return VisibilityDetector(
                      key: Key(_feedController.lastFetchedPage.toString()),
                      child: noDetector,
                      onVisibilityChanged: (VisibilityInfo info){
                        if (info.visibleFraction * 100 >= 50){
                          refreshFeed();
                        }
                      }
                  );
                  }
                  else {
                    return noDetector;
                  }
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading!){
      refreshFeed();
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget>? tweetWidgets = wrapDataInWidget();

    if(tweetWidgets == null){
      return const Column(
        children: [
          Text("nothing to see here go get some life")
        ],
      );
    }

    Widget result = Column(children: tweetWidgets);

    if (widget.isScrollable) {
      result = RefreshIndicator(
          onRefresh: () async {refreshFeed();},
          child: SingleChildScrollView(child: result)
      );
    }

    return result;
  }

}
