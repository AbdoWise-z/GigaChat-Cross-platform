
import 'dart:convert';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';

/// This class is responsible for dealing with the search api endpoints
/// and decode the result into tweet data class or user class
class SearchRequests{

  /// get all tags that matches the given keyword
  /// [token] : currently logged in user token
  /// [keyword] : the keyword that is being searched
  /// returns a list of maximum of [DEFAULT_PAGE_COUNT] tags that matches the given keyword
  /// if there is no match or error occurred an empty list will be returned
  static Future<List<String>> searchTagsByKeyword(String keyword,String token) async {
    ApiPath path = ApiPath.searchTags;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "word":keyword,
          "type": "hashtag",
          "page": "1",
          "count": DEFAULT_PAGE_COUNT.toString()
        }
    );
    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      List<String>? tagList = [];
      List<dynamic> res = jsonDecode(response.responseBody!)["results"];
      tagList = res.map((result) => result["title"]).toList().cast<String>();
      return tagList;
    }
    else
    {
      return [];
    }
  }


  /// get all users that matches the given keyword
  /// [token] : currently logged in user token
  /// [keyword] : the keyword that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to fetch
  /// returns a map of maximum of [DEFAULT_PAGE_COUNT] {username, user} where their username matches the given keyword
  /// if there is no match or error occurred an empty map will be returned
  static Future<Map<String, User>> searchUsersByKeywordMapped
      (String keyword,String token,String page,String count) async {
    List<User> users = await searchUsersByKeyword(keyword, token, page, count);
    Map<String,User> mappedUsers = {};
    for(User user in users){
      mappedUsers.putIfAbsent(user.id, () => user);
    }
    return mappedUsers;
  }

  /// get all users that matches the given keyword
  /// [token] : currently logged in user token
  /// [keyword] : the keyword that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to fetch
  /// returns a list of maximum of [DEFAULT_PAGE_COUNT] users where their username matches the given keyword
  /// if there is no match or error occurred an empty list will be returned
  static Future<List<User>> searchUsersByKeyword(String keyword,String token,String page,String count) async {
    ApiPath path = ApiPath.searchUsers;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "word":keyword,
          "type": "user",
          "page": page,
          "count" : count
    }
    );

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      List usersResponse = json.decode(response.responseBody!)["results"];
      return usersResponse.map((user) {
        return User(
          id: user["username"],
          name: user["nickname"],
          isFollowed: user["isFollowedbyMe"],
          isWantedUserBlocked: user["isBlocked"],
          bio: user["bio"] ?? "",
          followers: user["followers_num"],
          following: user["following_num"],
          iconLink: user["profile_image"] ?? USER_DEFAULT_PROFILE
        );
      }).toList();
    }
    else
    {
      return [];
    }
  }

  /// get all tweets that their description contains the given trend
  /// [token] : currently logged in user token
  /// [trend] : the trend that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to fetch
  /// returns a map of maximum of [DEFAULT_PAGE_COUNT] {tweetId, tweet} where their description contains the given trend
  /// if there is no match or error occurred an empty map will be returned
  static Future<Map<String,TweetData>> searchTweetsByTrendsMapped
      (String trend, String token, String page, String count) async {
    List<TweetData> tweetList = await searchTweetsByTrends(trend, token, page, count);
    Map<String,TweetData> mappedTweets = {};
    for(TweetData tweetData in tweetList){
      mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
    }
    return mappedTweets;
  }

  /// get all tweets that their description contains the given trend
  /// [token] : currently logged in user token
  /// [trend] : the trend that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to be fetched
  /// returns a list of maximum of [DEFAULT_PAGE_COUNT] tweet where their description contains the given trend
  /// if there is no match or error occurred an empty list will be returned
  static Future<List<TweetData>> searchTweetsByTrends
      (String trend, String token, String page, String count) async {
    ApiPath path = ApiPath.searchTrends.format([trend]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "page": page,
          "count" : count
        }
    );

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null) {
      return Tweets.decodeTweetList(token, response, {
        "data" : ["data"],
        "base" : null,
        "id": ["_id"],
        "referredTweetId": ["referredTweetId"],
        "description": ["description"],
        "viewsNum": null,
        "likesNum": ["likesNum"],
        "repliesNum": ["repliesNum"],
        "repostsNum": ["repostsNum"],
        "creationTime": ["createdAt"],
        "type": ["type"],

        "tweetOwnerID": [ "tweet_owner", "username"],
        "tweetOwnerName": [ "tweet_owner", "nickname"],
        "tweetOwnerIsFollowed": ["isFollowed"],
        "tweetOwnerBio": null,
        "tweetOwnerIcon": [ "tweet_owner", "profile_image"],
        "tweetOwnerFollowers": ["tweet_owner", "followers_num"],
        "tweetOwnerFollowing": ["tweet_owner", "following_num"],

        "tweetRetweeter" : null,
        "tweetRetweeterID": null,
        "tweetRetweeterName": null,
        "tweetRetweeterIsFollowed": null,
        "tweetRetweeterBio": null,
        "tweetRetweeterIcon": null,
        "tweetRetweeterFollowers": null,
        "tweetRetweeterFollowing": null,


        "isLiked": ["isLiked"],
        "isRetweeted": ["isRtweeted"],
        "media": ["media"],
      });
    }
    else{
      return [];
    }
  }

  /// get all tweets that their description contains the given keyword
  /// [token] : currently logged in user token
  /// [trend] : the trend that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to fetch
  /// returns a map of maximum of [DEFAULT_PAGE_COUNT] {tweetId, tweet} where their description contains the given keyword
  /// if there is no match or error occurred an empty map will be returned
  static Future<Map<String,TweetData>> searchTweetsByKeywordMapped(String keyword,String token,String page,String count) async {
    List<TweetData> tweetList = await searchTweetsByKeyword(keyword, token, page, count);
    Map<String,TweetData> mappedTweets = {};
    for(TweetData tweetData in tweetList){
      mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
    }
    return mappedTweets;
  }

  /// get all tweets that their description contains the given trend
  /// [token] : currently logged in user token
  /// [trend] : the trend that is being searched
  /// [page] : page number to be fetched
  /// [count] : number of users to be fetched
  /// returns a list of maximum of [DEFAULT_PAGE_COUNT] tweet where their description contains the given trend
  /// if there is no match or error occurred an empty list will be returned
  static Future<List<TweetData>> searchTweetsByKeyword(String keyword,String token,String page,String count) async {
    ApiPath path = ApiPath.searchUsers;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "word":keyword,
          "type": "tweet",
          "page": page,
          "count" : count
    }
    );

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null) {
      return Tweets.decodeTweetList(token, response, {
        "data" : ["results"],
        "base" : null,
        "id": ["_id"],
        "referredTweetId": ["referredTweetId"],
        "description": ["description"],
        "viewsNum": null,
        "likesNum": ["likesNum"],
        "repliesNum": ["repliesNum"],
        "repostsNum": ["repostsNum"],
        "creationTime": ["createdAt"],
        "type": ["type"],

        "tweetOwnerID": [ "tweet_owner", "username"],
        "tweetOwnerName": [ "tweet_owner", "nickname"],
        "tweetOwnerIsFollowed": ["isFollowed"],
        "tweetOwnerBio": null,
        "tweetOwnerIcon": [ "tweet_owner", "profile_image"],
        "tweetOwnerFollowers": ["tweet_owner", "followers_num"],
        "tweetOwnerFollowing": ["tweet_owner", "following_num"],

        "tweetRetweeter" : null,
        "tweetRetweeterID": null,
        "tweetRetweeterName": null,
        "tweetRetweeterIsFollowed": null,
        "tweetRetweeterBio": null,
        "tweetRetweeterIcon": null,
        "tweetRetweeterFollowers": null,
        "tweetRetweeterFollowing": null,


        "isLiked": ["isLiked"],
        "isRetweeted": ["isRtweeted"],
        "media": ["media"],
      });
    }
    else{
      return [];
    }
  }
}