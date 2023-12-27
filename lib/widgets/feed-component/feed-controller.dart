import 'package:flutter/cupertino.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/search-requests.dart';
import 'package:gigachat/api/trend-requests.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/feed-provider.dart';

/// responsible for caching and fetching the feed data and returns it to the feed if needed
/// [id] : feed controller id
/// [feedProvider] : reference to feed provider (internally initialized)
/// [token] : currently logged in user token
/// [_feedData] : cache for the current feed data
/// [_feedKeys] : cache for the current feed keys for eliminating duplicates
/// [loading] : state of the feed controller , true if it's fetching data for the first time
/// [fetchingMoreData] : state of the feed controller after the first fetch, true if it's trying to fetch more data
/// [providerFunction] : selects the function that will fetch the data from the endpoint
/// [lastFetchedPage] : last fetched page to the controller
class FeedController {

  String id;
  FeedProvider? feedProvider;
  String? token;
  List<dynamic>? _feedData;
  List<String>? _feedKeys;

  bool loading = true;
  bool fetchingMoreData = false;
  ProviderFunction providerFunction;
  int lastFetchedPage = 0;
  bool? isInProfile;


  FeedController(BuildContext context, {required this.id, this.token, required this.providerFunction,this.isInProfile}) {
    _feedData = [];
    _feedKeys = [];
    loading = true;
    feedProvider = FeedProvider.getInstance(context);
  }

  /// Sets the token of the currently logged in user
  void setUserToken(String? userToken) {
    token = userToken;
  }

  /// return the loading state of the feed controller
  bool isLoading(){
    return loading;
  }

  /// place the new data at the end of the list of the current feed data
  /// [newData] mapped dynamic object with some identifier {id: obj}
  /// [noRefresh] : if true the feed will not refresh
  void appendToLast(Map<String, dynamic> newData,{bool noRefresh = false}) {
    newData.forEach((key, value) {
      if(! _feedKeys!.contains(key)){
        _feedKeys!.add(key);
        _feedData!.add(value);
      }
    });
    if (noRefresh) {
      return;
    }
    updateFeeds();
  }

  /// reset the feed controller data to it's initial state
  void resetFeed(){
    _feedData = [];
    _feedKeys = [];
    lastFetchedPage = 0;
    loading = true;
  }

  /// place the new data at the end of the list of the current feed data
  /// [newData] mapped dynamic object with some identifier {id: obj}
  /// [noRefresh] : if true the feed will not refresh
  void appendToBegin(Map<String, dynamic> newData, {bool noRefresh = false}) {
    newData.forEach((key, value) {
      if(! _feedKeys!.contains(key)){
        _feedKeys!.insert(0,key);
        _feedData!.insert(0,value);
      }
    });
    if (noRefresh)
      return;
    updateFeeds();
  }

  /// remove a tweet from the feed by it's id
  /// this function can be used to remove any type of data just pass the id
  /// [newData] mapped dynamic object with some identifier {id: obj}
  /// [noRefresh] : if true the feed will not refresh
  void deleteTweet(String tweetID){
    if (_feedData == null) return;
    int idx = _feedKeys!.indexOf(tweetID);
    if (idx == -1) {
      return;
    }
    _feedData!.removeAt(idx);
    _feedKeys!.removeAt(idx);
    updateFeeds();
  }

  /// update the feed to follow the changes happened
  void updateFeeds(){
    feedProvider!.updateFeeds();
  }

  /// ASSUMING THE FEED DEALS WITH TWEETS
  /// delete a tweet of a certain user by it's username
  void deleteUserTweets(String username){
    try{
      List<TweetData> targetTweets = _feedData!.cast<TweetData>()
          .where((tweetData) => tweetData.tweetOwner.id == username).toList();
      List<String> targetIds = _feedData!.cast<TweetData>()
          .map((tweetData) => tweetData.id).toList();
      _feedData!.removeWhere((tweetData) => targetTweets.contains(tweetData));
      _feedKeys!.removeWhere((tweetId) => targetIds.contains(tweetId));
      if (_feedData!.isEmpty){
        resetFeed();
      }
    } catch(e){
      return;
    }
  }

  /// return the current feed data
  List getCurrentData () {
    return _feedData!;
  }

  /// converts a list of users into a map of {username, user}
  /// [users] list of users to be converted
  Map<String,User> mapUserListIntoMap(List<User> users){
    Map<String,User> mappedUsers = {};
    for (User user in users){
      mappedUsers.putIfAbsent(user.id, () => user);
    }
    return mappedUsers;
  }


  /// this functions keep getting the replied tweet of the current tweet until it reaches the root tweet
  /// [mainTweetForComments] the first tweet of the tree
  Future<List<TweetData>> fetchRepliesTree(mainTweetForComments) async {
    TweetData? tweetData = mainTweetForComments!;
    List<TweetData> response = [tweetData!];
    while(tweetData != null && tweetData.referredTweetId != null)
    {
      tweetData = await Tweets.getTweetById(token!, tweetData.referredTweetId!);
      if (tweetData == null) break;
      response = [...response,tweetData];
    }
    return response;
  }

  /// request new data from the api and add it to the current feed data
  /// if the providerFunction is [ProviderFunction.GET_TWEET_COMMENTS] it will fetch extra data for the tweet reply tree
  /// [toBegin] : specify whether to add data to the begin of the feed or the end
  /// [username] : {required for apis dealing with username only} username to be passed to the api
  /// [tweetID] : {required for apis dealing with tweetID only} tweetID to be passed to the api
  /// [keyword] : {required for apis dealing with keyword only} keyword to be passed to the api
  /// [mainTweet] : {required for get tweet comments feed} start of the reply tree
  Future<void> fetchFeedData({
    bool? toBegin,
    String? username,
    String? tweetID,
    String? keyword,
    TweetData? mainTweet
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

        if (keyword!.split(" ").length == 1 && keyword[0] == '#'){
            response = {};
        }
        else{
          response = await SearchRequests.searchUsersByKeywordMapped(
              keyword,
              token!,
              nextPage.toString(),
              DEFAULT_PAGE_COUNT.toString()
          );
        }


        break;


      case ProviderFunction.SEARCH_TWEETS:

        if (keyword!.split(" ").length == 1 && keyword[0] == '#'){
          String trend = keyword.substring(1);
          response = await SearchRequests.searchTweetsByTrendsMapped(
              trend,
              token!,
              nextPage.toString(),
              DEFAULT_PAGE_COUNT.toString()
          );
        }
        else {
          response = await SearchRequests.searchTweetsByKeywordMapped(
              keyword,
              token!,
              nextPage.toString(),
              DEFAULT_PAGE_COUNT.toString()
          );
        }
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

      case ProviderFunction.GET_USER_BLOCKLIST:
        List<User> users = (
            await Account.getUserBlockedList(
                token!,
                nextPage,
                DEFAULT_PAGE_COUNT
            )
        ).data!;
        response = mapUserListIntoMap(users);
        break;

      case ProviderFunction.GET_USER_MUTEDLIST:
        List<User> users = (
            await Account.getUserMutedList(
                token!,
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

      case ProviderFunction.PROFILE_PAGE_LIKES:
        if (username == null) return;
        response = await Tweets.getProfilePageLikes(
            token!,
            username,
            DEFAULT_PAGE_COUNT.toString(),
            nextPage.toString()
        );
        break;

      case ProviderFunction.HOME_PAGE_MENTIONS:
        response = await Tweets.getMentionTweets(
            token!,
            DEFAULT_PAGE_COUNT.toString(),
            nextPage.toString()
        );
        break;
      case ProviderFunction.GET_TRENDS:
        response = await TrendRequests.getAllTrends(token!, nextPage.toString(), DEFAULT_PAGE_COUNT.toString());
        break;

      default:
    }


    if (response.isNotEmpty){
      lastFetchedPage = nextPage;
    }

    if (toBegin != null && toBegin == true){
      appendToBegin(response,noRefresh: true);
    }
    else {
      appendToLast(response, noRefresh: true);
    }

    if (providerFunction == ProviderFunction.GET_TWEET_COMMENTS){
      List<TweetData> parents = await fetchRepliesTree(mainTweet!);
      for (TweetData tweetData in parents){
        print(tweetData.description);
        appendToBegin({tweetData.id : tweetData},noRefresh: true);
      }
    }
    loading = false;
    updateFeeds();
  }

}