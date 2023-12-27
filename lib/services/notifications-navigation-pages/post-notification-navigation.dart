import 'package:flutter/material.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-all-tab.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/posts/view-post.dart';
import 'package:gigachat/providers/auth.dart';


/// this page loads a tweet from tweet with id [target]
/// and sends the tweet data to the [ViewPostPage]
/// for navigating from the [NotificationsAllTab] to [ViewPostPage]
class PostNotificationNavigation extends StatefulWidget {
  final String target;
  const PostNotificationNavigation({super.key, required this.target});

  @override
  State<PostNotificationNavigation> createState() => _PostNotificationNavigationState();
}

class _PostNotificationNavigationState extends State<PostNotificationNavigation> {
  void _load() async {
    var tweet = await Tweets.getTweetById(Auth().getCurrentUser()!.auth!, widget.target);
    if (tweet != null){
      if (context.mounted){
        Navigator.pushReplacementNamed(context, ViewPostPage.pageRoute , arguments: {
          "cancelNavigationToUser" : false,
          "tweetOwner": tweet.tweetOwner,
          "tweetData": tweet,
        });
        print("Notification delivered");
      }
    }else{
      print("Failed to trigger notification with ID : ${widget.target}");
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }
  @override
  Widget build(BuildContext context) {
    return const LoadingPage();
  }
}
