


import 'package:flutter/material.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
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
    FeedController feedController = FeedController(providerFunction: ProviderFunction.GET_TWEET_COMMENTS);
    feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    return Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null,showDefault: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Tweet(
                tweetOwner: tweetOwner,
                tweetData: tweetData,
                isRetweet: false,
                isSinglePostView: true
            ),

            BetterFeed(
                isScrollable: false,
                providerFunction: ProviderFunction.GET_TWEET_COMMENTS,
                providerResultType: ProviderResultType.TWEET_RESULT,
                feedController: feedController,
                tweetID: tweetData.id,
            )
          ],
        ),
      ),
    );
  }
}
