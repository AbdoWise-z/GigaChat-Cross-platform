import 'package:flutter/material.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/api.dart';

class FeedProvider
{
  late List<TweetData> _currentFeedData;
  //late User _currentUser;
  static FeedProvider? _instance;


  // Private Constructor
  FeedProvider._internal(BuildContext context){
    //_currentUser = Auth.getInstance(context).getCurrentUser()!;
    _currentFeedData = [];
  }

  // Getting An Instance Of The Object
  factory FeedProvider(BuildContext context){
    _instance ??= FeedProvider._internal(context);
    return _instance!;
  }


  Future<List<TweetData>> getFollowingTweets(User user) async
  {
    List<TweetData>? response = await Tweets.getFollowingTweet(user.auth);

    _currentFeedData = response ?? [];
    // TODO: Response must be formatted here but we will move on for now
    return _currentFeedData;
  }

  List<TweetData> getCurrentTweets()
  {
    return _currentFeedData;
  }

  void likeTweet(String tweetId) async
  {
    // TODO: CALL THE API HERE
  }

  Future<bool> retweetTweet(String tweetId) async
  {
    // TODO: Call The api here
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> undoRetweet(String tweetId) async
  {
    // TODO: Call The api here
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> sendTweet(User from , IntermediateTweetData data , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Tweets.apiSendTweet(from.auth! , data);
    if (res.data != null){
      if (success != null) success(res);
      return true;
    }else{
      if (error != null) error(res);
      return false;
    }
  }
}


