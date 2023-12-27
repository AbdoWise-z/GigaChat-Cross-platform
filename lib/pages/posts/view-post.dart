import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';


/// this page view the tweet in special view as main post , below the replies for this tweet
/// and all reply history for the tweet if it was a reply for another tweet
/// these arguments are required when navigating to the page
/// [tweetOwner] : owner of the main tweet in the page
/// [tweetData] : data of the main tweet in the page
/// [cancelNavigationToUser] : stop navigating to user profile when pressing on the circle avatar
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

  @override
  void initState() {
    super.initState();

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
