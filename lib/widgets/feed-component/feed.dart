import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import "package:gigachat/api/user-class.dart";
import 'package:loading_indicator/loading_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum ProviderFunction{
  HOME_PAGE_TWEETS,
  PROFILE_PAGE_TWEETS
}


class FeedWidget extends StatefulWidget {
  final String? userID;
  final ProviderFunction providerType;

  FeedWidget({
    super.key,
    required this.providerType,
    required this.userID,
  });

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}


class _FeedWidgetState extends State<FeedWidget> {
  late List<TweetData> _tweetsData;
  late bool loading;
  late FeedProvider feedProvider;

  void fetchTweets(String? userToken,int page) async {
    if (userToken == null) {
      userToken = "blabla";
    }

    // TODO: you can add here what ever provider you want
    switch(widget.providerType){
      case ProviderFunction.HOME_PAGE_TWEETS:
        _tweetsData = await feedProvider.getFollowingTweets(
            userToken,
            page
        );
      case ProviderFunction.PROFILE_PAGE_TWEETS:
        _tweetsData = await feedProvider.getUserProfileTweets(
            userToken,
            page
        );
    }

    if(!mounted) return;
    loading = false;
    setState(() {});
  }

  List<Widget> wrapDataInWidget(){
    return _tweetsData.asMap().entries.map((tweet) =>
        VisibilityDetector(
          onVisibilityChanged: (VisibilityInfo visibilityInfo){
            if(visibilityInfo.visibleFraction * 100 > 50 && (tweet.key+1) % DEFAULT_PAGE_COUNT == 0)
            {
              fetchTweets(widget.userID, ((tweet.key + 1) ~/ DEFAULT_PAGE_COUNT) + 1);
            }
          },
          key: Key(tweet.value.id),
          child: Tweet(
            tweetOwner: tweet.value.tweetOwner,
            tweetData: tweet.value,
            isRetweet: true,
            isSinglePostView: false,
          ),
        )
    ).toList();
  }

  @override
  void initState() {
    loading = true;
    feedProvider  = FeedProvider(pageCount: 5);
    VisibilityDetectorController.instance.updateInterval = const Duration(seconds: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading){
      fetchTweets(Auth.getInstance(context).getCurrentUser()!.auth,1);
      return const LoadingIndicator(indicatorType: Indicator.orbit);
    }
    List<Widget> tweetWidgets = wrapDataInWidget();
    return Column(children: tweetWidgets);
  }
}



class ScrollableFeedWidget extends StatefulWidget {
  final String? userID;
  final ProviderFunction providerType;

  const ScrollableFeedWidget({
    super.key,
    required this.providerType,
    required this.userID
  });

  @override
  State<ScrollableFeedWidget> createState() => _ScrollableFeedWidgetState();
}

class _ScrollableFeedWidgetState extends State<ScrollableFeedWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: FeedWidget(
            userID:widget.userID,
            providerType: widget.providerType,
        ),
    );
  }
}
