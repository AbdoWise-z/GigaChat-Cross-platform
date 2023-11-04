import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/post-class.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/post.dart';



class FeedWidget extends StatefulWidget {
  const FeedWidget({super.key});

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  TweetData tweet = TweetData(
      id: '1',
      description: "this is post guys",
      media: "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
      views: 12,
      date: DateTime(2022,5,30,12,24,30),
      type: "Masterpiece"
  );

  User user = User();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: LoginAppBar(context),
      body: Column(
        children: [
          Tweet(tweetOwner: user, tweetData: tweet),
          Tweet(tweetOwner: user, tweetData: tweet),
        ],
      ),
    );
  }
}
