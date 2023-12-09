import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';

class BetterFeed extends StatefulWidget {
  final bool isScrollable;
  final ProviderFunction providerFunction;
  final ProviderResultType providerResultType;
  final FeedController feedController;
  String? username, tweetID;

  BetterFeed({
    super.key,
    required this.isScrollable,
    required this.providerFunction,
    required this.providerResultType,
    required this.feedController,
    this.username,
    this.tweetID
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
    await _feedController.fetchFeedData(username: widget.username,tweetID: widget.tweetID);
    loading = false;
    setState(() {});
  }



  List<Widget>? wrapDataInWidget() {
    switch(widget.providerResultType){
      // The Result Of Searching For User
      case ProviderResultType.USER_RESULT:
        List<User> userResult = _feedController.getCurrentData().cast<User>();
        return userResult.map((User user){
                  return UserResult(user: User());
        }).toList();
      // The Normal View For Tweets
      case ProviderResultType.TWEET_RESULT:
        List<TweetData> userResult = _feedController.getCurrentData().cast<TweetData>();
        return userResult.map((TweetData tweetData){
                  return Tweet(
                      tweetOwner: tweetData.tweetOwner,
                      tweetData: tweetData,
                      isRetweet: tweetData.isRetweeted,
                      isSinglePostView: false
                  );
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
      result = SingleChildScrollView(child: result);
    }

    return result;
  }

}
