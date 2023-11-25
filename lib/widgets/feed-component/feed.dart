import 'package:flutter/material.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/util/user-data.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/post.dart';

class FeedWidget extends StatefulWidget {
  bool showFollowingTweets;

  FeedWidget({super.key,required this.showFollowingTweets});

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}



class _FeedWidgetState extends State<FeedWidget> {
  late FeedProvider _feedProvider;
  late List<TweetData> _tweetsData;
  late bool loading;

  void fetchTweets() async{
    _tweetsData = widget.showFollowingTweets ?
    await _feedProvider.getFollowingTweets() :
    await _feedProvider.getFollowingTweets();
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    _feedProvider = FeedProvider(context);
    loading = true;
    fetchTweets();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if (loading){
      return const LoadingPage();
    }

    return
      Scaffold(
        appBar: AuthAppBar(context, leadingIcon: null),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: _tweetsData.map((tweet) => Tweet(
                tweetOwner: tweet.tweetOwner,
                tweetData: tweet,
                isRetweet: false)
            ).toList(),
          ),
        ),
      );
  }
}
