import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class ViewPostPage extends StatefulWidget {
  static const String pageRoute = "/post/view";
  static const String feedID = "PostRepliesFeed/";


  ViewPostPage({super.key});

  @override
  State<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  late User tweetOwner;
  late FeedController feedController;
  late TweetData tweetData;


  Future<void> addComment(BuildContext context) async {
    dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
      "reply" : tweetData,
    });

    if(retArguments["success"] != null && retArguments["success"] == true){

      List<TweetData> tweetList = retArguments["tweets"];
      Map<String,TweetData> mappedTweets = {};
      for (TweetData tweetData in tweetList){
        mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
      }



      feedController.appendToBegin(mappedTweets);
      tweetData.repliesNum += 1;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    //FeedProvider.getInstance(context).removeFeedByObject(feedController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    tweetOwner = args["tweetOwner"];
    tweetData = args["tweetData"];
    bool cancelNavigationToUser = args["cancelNavigationToUser"];

    feedController = FeedProvider.getInstance(context).getFeedControllerById(
        context: context,
        id: ViewPostPage.feedID + tweetData.id,
        providerFunction: ProviderFunction.GET_TWEET_COMMENTS,
        clearData: true
    );

    feedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    return Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null,showDefault: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BetterFeed(
              mainTweetForComments: tweetData,
              providerFunction: ProviderFunction.GET_TWEET_COMMENTS,
              providerResultType: ProviderResultType.TWEET_RESULT,
              feedController: feedController,
              tweetID: tweetData.id,
              removeController: false,
              removeRefreshIndicator: false,
              cancelNavigationToUserProfile: cancelNavigationToUser ? cancelNavigationToUser : null,
            )
          ],
        ),
      ),
    );
  }
}
