import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';

List<TweetActionButton> initActionButtons({
  required BuildContext context,
  required TweetData tweetData,
  required bool singlePostView,
  required onCommentButtonClicked,
  required onRetweetButtonClicked,
  required onLikeButtonClicked,
})
{
  String? userToken = Auth.getInstance(context).getCurrentUser()!.auth;

  return [
    TweetActionButton(
      icon: FontAwesomeIcons.comment,
      count: singlePostView ? null : tweetData.repliesNum,
      isLikeButton: false,
      isLiked: false,
      isRetweet: false,
      isRetweeted: false,
      onPressed: onCommentButtonClicked,
    ),
    TweetActionButton(
        icon: FontAwesomeIcons.retweet,
        count: singlePostView ? null : tweetData.repostsNum,
        isLikeButton: false,
        isLiked: tweetData.isRetweeted,
        isRetweet: true,
        isRetweeted: tweetData.isRetweeted,
        onPressed: onRetweetButtonClicked
    ),
    TweetActionButton(
        icon: FontAwesomeIcons.heart,
        count: singlePostView ? null : tweetData.likesNum,

        isLikeButton: true,
        isLiked: tweetData.isLiked,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: onLikeButtonClicked
    ),
    TweetActionButton(
        icon: Icons.bar_chart,
        count: singlePostView ? null : tweetData.viewsNum,

        isLikeButton: false,
        isLiked: false,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: (){}
    ),
    TweetActionButton(
        icon: Icons.share_outlined,
        count: null,

        isLikeButton: false,
        isLiked: false,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: () {}
    ),
  ];
}