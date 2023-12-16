import 'package:flutter/cupertino.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/search-requests.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/feed-provider.dart';

class FeedController {

  FeedProvider? feedProvider;
  String? token;
  List<dynamic>? _feedData;
  List<String>? _feedKeys;

  bool loading = true;
  ProviderFunction providerFunction;
  int lastFetchedPage = 0;


  FeedController(BuildContext context, {this.token, required this.providerFunction}) {
    _feedData = [];
    _feedKeys = [];
    loading = true;
    feedProvider = FeedProvider.getInstance(context);
  }

  void setUserToken(String? userToken) {
    token = userToken;
  }

  bool isLoading(){
    return loading;
  }

  void appendToLast(Map<String, dynamic> newData) {
    newData.forEach((key, value) {
      if(! _feedKeys!.contains(key)){
        _feedKeys!.add(key);
        _feedData!.add(value);
      }
    });
    updateFeeds();
  }

  void resetFeed(){
    _feedData = [];
    _feedKeys = [];
    lastFetchedPage = 0;
    loading = true;
  }

  void appendToBegin(Map<String, dynamic> newData) {
    newData.forEach((key, value) {
      if(! _feedKeys!.contains(key)){
        _feedKeys!.insert(0,key);
        _feedData!.insert(0,value);
      }
    });
    updateFeeds();
  }

  void deleteTweet(String tweetID){
    if (_feedData == null) return;
    int idx = _feedKeys!.indexOf(tweetID);
    _feedData!.removeAt(idx);
    _feedKeys!.removeAt(idx);
    updateFeeds();
  }

  void updateFeeds(){
    feedProvider!.updateFeeds();
  }

  List getCurrentData () {
    return _feedData!;
  }

  Map<String,User> mapUserListIntoMap(List<User> users){
    Map<String,User> mappedUsers = {};
    for (User user in users){
      mappedUsers.putIfAbsent(user.id, () => user);
    }
    return mappedUsers;
  }

  Future<void> fetchFeedData({
    bool? toBegin,
    String? username,
    String? tweetID,
    String? keyword
  }) async
  {
    if (token == null) {
      throw "user is not logged in -- logged from feed controller line 30 -- ";
    }

    int nextPage = lastFetchedPage + 1;

    Map<String,dynamic> response = {};
    switch(providerFunction){


      case ProviderFunction.HOME_PAGE_TWEETS:
        response = await Tweets.getFollowingTweet(
            token!,
            DEFAULT_PAGE_COUNT.toString(),
            nextPage.toString()
        );
        break;


      case ProviderFunction.PROFILE_PAGE_TWEETS:
        if (username == null) return;
        response = await Tweets.getProfilePageTweets(
            token!,
            username,
            DEFAULT_PAGE_COUNT.toString(),
            nextPage.toString()
        );
        break;


      case ProviderFunction.GET_TWEET_COMMENTS:
        response = await Tweets.getTweetReplies(
            token!,
            tweetID!,
            DEFAULT_PAGE_COUNT.toString(),
            nextPage.toString()
        );
        break;


      case ProviderFunction.SEARCH_USERS:
        response = await SearchRequests.searchUsersByKeywordMapped(
            keyword!,
            token!,
            nextPage.toString(),
            DEFAULT_PAGE_COUNT.toString()
        );
        break;


      case ProviderFunction.SEARCH_TWEETS:
        response = await SearchRequests.searchTweetsByKeywordMapped(
            keyword!,
            token!,
            nextPage.toString(),
            DEFAULT_PAGE_COUNT.toString()
        );
        break;


      case ProviderFunction.GET_USER_FOLLOWERS:
        List<User> users = (
            await Account.getUserFollowers(
                token!,
                username!,
                nextPage,
                DEFAULT_PAGE_COUNT
            )
        ).data!;
        response = mapUserListIntoMap(users);
        break;

      case ProviderFunction.GET_USER_FOLLOWINGS:
        List<User> users = (
            await Account.getUserFollowings(
                token!,
                username!,
                nextPage,
                DEFAULT_PAGE_COUNT
            )
        ).data!;
        response = mapUserListIntoMap(users);
        break;


      case ProviderFunction.GET_TWEET_LIKERS:
        List<User> users = await Tweets.getTweetLikers(
            token!,
            tweetID!,
            nextPage.toString(),
            DEFAULT_PAGE_COUNT.toString()
        );
        response = mapUserListIntoMap(users);
        break;


      case ProviderFunction.GET_TWEET_REPOSTERS:
        List<User> users = await Tweets.getTweetRetweeters(
            token!,
            tweetID!,
            nextPage.toString(),
            DEFAULT_PAGE_COUNT.toString()
        );
        response = mapUserListIntoMap(users);
        break;

      default:
    }


    if (response.isNotEmpty){
      lastFetchedPage = nextPage;
    }

    if (toBegin != null && toBegin == true){
      appendToBegin(response);
    }
    else {
      appendToLast(response);
    }

    loading = false;
  }

}