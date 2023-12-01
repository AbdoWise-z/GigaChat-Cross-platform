import 'package:flutter/material.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/api.dart';

class FeedProvider
{
  List<TweetData> _currentFeedData = [];
  int? _lastRequestedPage;
  int pageCount = 5;


  FeedProvider({
    required this.pageCount
  }){
    _lastRequestedPage = 0;
  }

  Future<List<TweetData>> getFollowingTweets(String userToken,int page) async
  {

    if (_lastRequestedPage! >= page)
    {
      // the list is already updated with the requested page
      return _currentFeedData;
    }

    _lastRequestedPage = page;

    List<TweetData> response = await Tweets.getFollowingTweet(
        userToken,
        pageCount.toString(),
        page.toString()
    );

    _currentFeedData.addAll(response);

    return _currentFeedData;
  }

  Future<List<TweetData>> getUserProfileTweets(String userToken,int page) async
  {
    if (page * pageCount == _currentFeedData.length)
    {
      // the list is already updated with the requested page
      return _currentFeedData;
    }

    List<TweetData>? response = await Tweets.getFollowingTweet(
        userToken,
        pageCount.toString(),
        page.toString()
    );

    _currentFeedData = [..._currentFeedData, ...response];

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


