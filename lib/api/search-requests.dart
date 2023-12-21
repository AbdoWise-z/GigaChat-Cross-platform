
import 'dart:convert';

import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';

class SearchRequests{
  static Future<List<String>> searchTagsByKeyword(String keyword,String token) async {

    return ["wow","wo are you","wo is whom"];

    ApiPath path = ApiPath.searchTags;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers, params: {"name":keyword});
    if (response.code == ApiResponse.CODE_SUCCESS){
      //TODO: decode the response body
      return [];
    }
    else
    {
      return [];
    }
  }


  static Future<Map<String, User>> searchUsersByKeywordMapped
      (String keyword,String token,String page,String count) async {
    List<User> users = await searchUsersByKeyword(keyword, token, page, count);
    Map<String,User> mapped_users = {};
    for(User user in users){
      mapped_users.putIfAbsent(user.id, () => user);
    }
    return mapped_users;
  }

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
          followers: user["followers_num"],
          following: user["following_num"],
          iconLink: user["profile_image"]
        );
      }).toList();
    }
    else
    {
      return [];
    }
  }

  static Future<Map<String,TweetData>> searchTweetsByKeywordMapped(String keyword,String token,String page,String count) async {
    List<TweetData> tweetList = await searchTweetsByKeyword(keyword, token, page, count);
    Map<String,TweetData> mappedTweets = {};
    for(TweetData tweetData in tweetList){
      mappedTweets.putIfAbsent(tweetData.id, () => tweetData);
    }
    return mappedTweets;
  }

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

    print(response.code);

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null) {
      List tweetList = jsonDecode(response.responseBody!)["results"];
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