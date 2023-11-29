


import 'package:flutter/material.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';

class ViewPostPage extends StatelessWidget {
  static const String pageRoute = "/post/view";

  late User tweetOwner;
  late TweetData tweetData;

  ViewPostPage({super.key});


  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    tweetOwner = args["tweetOwner"];
    tweetData = args["tweetData"];

    return Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null,showDefault: true),
      body: FeedWidget(
          tweetDataSource: FeedProvider(context).getFollowingTweets,
        specialTweet: Tweet(
          tweetOwner: tweetOwner,
          tweetData: tweetData,
          isRetweet: false,
          isSinglePostView: true
      ),),
    );
  }
}
