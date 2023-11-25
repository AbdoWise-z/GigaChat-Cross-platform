import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/util/user-data.dart';
import 'package:gigachat/api/tweets.dart';

class FeedProvider
{
      late List<TweetData> _currentFeedData;
      late User _currentUser;
      static FeedProvider? _instance;


      // Private Constructor
      FeedProvider._internal(BuildContext context){
        _currentUser = Auth.getInstance(context).getCurrentUser()!;
        _currentFeedData = [];
      }

      // Getting An Instance Of The Object
      factory FeedProvider(BuildContext context){
        _instance ??= FeedProvider._internal(context);
        return _instance!;
      }


      Future<List<TweetData>> getFollowingTweets() async
      {
          _currentFeedData =  await TweetsInterface.apiGetFollowingTweet(_currentUser);

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
        await Future.delayed(Duration(seconds: 1));
        return true;
      }

      Future<bool> undoRetweet(String tweetId) async
      {
        // TODO: Call The api here
        await Future.delayed(Duration(seconds: 1));
        return true;
      }
}


