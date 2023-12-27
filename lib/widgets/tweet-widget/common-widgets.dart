import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';

/// return list of the user interaction buttons below tweet (like - comment - retweet)
/// [context] : current build context of the parent widget
/// [tweetData] : the data of the tweet for which this buttons are added
/// [singlePostView] : is the post have special view or not (main post in view post page)
/// [onCommentButtonClicked] : callback function for the comment button
/// [onRetweetButtonClicked] : callback function for the retweet button
/// [onLikeButtonClicked] callback function for the like button
List<TweetActionButton> initActionButtons({
  required BuildContext context,
  required TweetData tweetData,
  required bool singlePostView,
  required onCommentButtonClicked,
  required onRetweetButtonClicked,
  required onLikeButtonClicked,
})
{

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