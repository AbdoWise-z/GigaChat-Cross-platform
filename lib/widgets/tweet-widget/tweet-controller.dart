import 'dart:js';

import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

import '../../base.dart';
import '../../pages/profile/user-profile.dart';
import '../../providers/feed-provider.dart';

/// likes a tweet if it was not liked and vice versa
/// [context] : buildContext of the parent widget
/// [token] : currently logged in user token
/// [tweetData] : data of the tweet that is being liked
/// returns true if the operation succeeded,
/// increases/decreases number of tweet likes
/// add / remove it to the likes tweet feed in current user profile
/// if failed will return false and show error message
Future<bool> toggleLikeTweet(BuildContext context,String? token,TweetData tweetData) async {
  if (token == null) {
    Navigator.popUntil(context, (route) => route.isFirst);
    return false;
  }
  User currentUser = Auth.getInstance(context).getCurrentUser()!;

  bool isLikingTweet = !tweetData.isLiked;
  try {
    bool success = isLikingTweet ?
    await Tweets.likeTweetById(token, tweetData.id) :
    await Tweets.unlikeTweetById(token, tweetData.id);

    if (success) {
      tweetData.isLiked = isLikingTweet;
      tweetData.likesNum += tweetData.isLiked ? 1 : -1;

      if(context.mounted){
        if (isLikingTweet){
          FeedProvider.getInstance(context).getFeedControllerById(
              context: context,
              id: UserProfile.profileFeedLikes + currentUser.id,
              providerFunction: ProviderFunction.PROFILE_PAGE_LIKES,
              clearData: false
          ).appendToBegin({tweetData.id: tweetData});
        }
        else
        {
          FeedProvider.getInstance(context).getFeedControllerById(
              context: context,
              id: UserProfile.profileFeedLikes + currentUser.id,
              providerFunction: ProviderFunction.PROFILE_PAGE_LIKES,
              clearData: false
          ).deleteTweet(tweetData.id);
        }
      }
    }
    return success;
  }
  catch(e){
    if (context.mounted) {
      Toast.showToast(context, e.toString());
    }
    return false;
  }
}

/// retweets a tweet if it was not liked and vice versa
/// [context] : buildContext of the parent widget
/// [token] : currently logged in user token
/// [tweetData] : data of the tweet that is being liked
/// returns true if the operation succeeded,
/// increases/decreases number of tweet retweets
Future<bool> toggleRetweetTweet(String? token,TweetData tweetData) async {
  if (token == null){
    return false;
  }

  bool isRetweeting = !tweetData.isRetweeted;
  bool success = isRetweeting ?
  await Tweets.retweetTweetById(token, tweetData.id) :
  await Tweets.unretweetTweetById(token, tweetData.id);
  if (success)
  {
    tweetData.isRetweeted = isRetweeting;
    tweetData.repostsNum += tweetData.isRetweeted ? 1 : -1;
  }
  return success;
}

bool canBeAppended(String tweetID, String parentFeedId, String currentUserId){
  List<String> splittedPath = parentFeedId.split("/");
  if (splittedPath.length > 1 && (splittedPath[1] == tweetID || splittedPath[1] == currentUserId)){
    return true;
  }
  else{
    return false;
  }

}

Future<int> commentTweet(BuildContext context, TweetData tweetData, FeedController? targetFeed) async {
  User currentUser = Auth.getInstance(context).getCurrentUser()!;
  dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
    "reply" : tweetData,
  });
  if(retArguments["success"] != null && retArguments["success"] == true){
    tweetData.repliesNum += 1;
    List<TweetData> tweets = retArguments["tweets"];
    if(targetFeed != null && canBeAppended(tweetData.id, targetFeed.id, currentUser.id)) {
      Map<String, TweetData> mappedTweets = {};
      for (TweetData tweetData in tweets) {
        mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
      }
      targetFeed.appendToLast(mappedTweets);
    }
  }
  return tweetData.repliesNum;
}
