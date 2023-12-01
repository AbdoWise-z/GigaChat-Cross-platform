
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gigachat/api/tweet-data.dart';

import 'api.dart';
import "package:gigachat/api/user-class.dart";

class Tweets {

  static Future<ApiResponse<String>> apiSendTweet(String token , IntermediateTweetData tweet) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    List<Map<String,String>> media = [];
    for (var m in tweet.media){
      media.add({
        "data": m.link,
        "type": m.type == MediaType.IMAGE ? "jpg" : "video",
      });
    }

    //print(media);

    Map body = {
      "description": tweet.description,
      "media": media,
      "type": tweet.type == TweetType.TWEET ? "tweet" : "reply",
    };

    if (tweet.referredTweetId != null){
      body.addAll({
        "referredTweetId" : tweet.referredTweetId
      });
    }

    //print("JSON : ${json.encode(body)}");

    var k = await Api.apiPost<String>(
      ApiPath.createTweet,
      body: json.encode(body),
      headers: headers,
    );

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED){
      k.data = json.decode(k.responseBody!)["data"]["id"];
      return k;
    }
    return k;
  }

  //final String GET_FOLLOWING_TWEETS_API = "$API_LINK/api/homepage/following";
  //List<Tweet>? serverResponse;

  static List<TweetData> cachedTweets = loadCache();
  static List<TweetData> loadCache() {
    // TODO: load cache here later
    return [
      getDefaultTweet("1",MediaType.IMAGE),
      getDefaultTweet("2",MediaType.IMAGE),
      getDefaultTweet("3",MediaType.IMAGE),
      getDefaultTweet("4",MediaType.IMAGE),
      getDefaultTweet("5",MediaType.IMAGE),
    ];
  }

  /// returns list of the posts that the current logged in user following their owners,
  /// if the request failed to fetch new posts it should load the cached tweets to achieve availability
  static Future<List<TweetData>> getFollowingTweet (String token,String count, String page) async
  {
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTBkMmY5ZjkwODhlODgzMThmZDEwYyIsImlhdCI6MTcwMTEwMzI2NywiZXhwIjoxNzA4ODc5MjY3fQ.Il_1vL2PbOE36g0wW55Lh1M7frJWx73gNIZ0uDuP5yw";
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.followingTweets,
        headers: headers,
        params: {"page":page,"count":count}
    );

    if (response.code == ApiResponse.CODE_SUCCESS){
      final tweets = json.decode(response.responseBody!);
      List<dynamic> responseTweets = tweets["tweetList"];

      responseTweets =
          responseTweets.map((tweet) =>
              TweetData(
                  id: tweet["tweetDetails"]["_id"],
                  referredTweetId: tweet["tweetDetails"]["referredTweetId"],
                  description: tweet["tweetDetails"]["description"],
                  viewsNum: 0,
                  likesNum: tweet["tweetDetails"]["likesNum"],
                  repliesNum: tweet["tweetDetails"]["repliesNum"],
                  repostsNum: tweet["tweetDetails"]["repostsNum"],
                  creationTime: DateTime.parse(tweet["tweetDetails"]["createdAt"]),
                  type: tweet["type"],

                  mediaType: tweet["tweetDetails"]["media"][0]["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO,
                  media: tweet["tweetDetails"]["media"][0]["data"],
                  tweetOwner: User(
                    id: tweet["followingUser"]["username"],
                    name: tweet["followingUser"]["nickname"],
                    auth: token,
                    //bio : "sad",
                    iconLink : tweet["followingUser"]["profile_image"],
                    followers : tweet["followingUser"]["followers_num"],
                    following : tweet["followingUser"]["following_num"],
                    active : true,

                  ),
                  isLiked: tweet["isLiked"],
                  isRetweeted: tweet["isRtweeted"]
              )
          ).toList();
      cachedTweets = responseTweets.cast();
    }
    else{
      //TODO: load cached tweets
      // i will assume this is the cached tweets for now
      loadCache();
    }
    return cachedTweets;
  }


  static Future<List<User>> getTweetLikers(String token, String tweetId,String page) async
  {
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTBkMmY5ZjkwODhlODgzMThmZDEwYyIsImlhdCI6MTcwMTEwMzI2NywiZXhwIjoxNzA4ODc5MjY3fQ.Il_1vL2PbOE36g0wW55Lh1M7frJWx73gNIZ0uDuP5yw";
    tweetId = "654c193b688f342c88a547e8";

    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.tweetLikers.appendDirectory(tweetId),
        headers: headers,
        params: {"page": page}
    );
    if (response.code == ApiResponse.CODE_SUCCESS){
      dynamic jsonResponse = json.decode(response.responseBody!);
      List<dynamic> users = jsonResponse["data"];
      return users.map(
              (user) => User(
                    id: user["username"] ?? "",
                    name: user["nickname"],
                    bio: user["bio"] ?? "",
                    iconLink: user["profile_image"] ?? "https://i.imgur.com/C1bPcWq.png"
                )
      ).toList();
    }
    return [];
  }


  /// returns true if the tweet is successfully liked, false if it failed
  static Future<bool> likeTweetById(String token,String tweetId) async {
      ApiPath endPoint = (ApiPath.likeTweet).appendDirectory(tweetId);
      var headers = Api.getTokenWithJsonHeader("Bearer $token");
      ApiResponse response = await Api.apiPatch(endPoint,headers: headers);
      if(response.code == 201)
      {
        return true;
      }
      else
      {
        debugPrint(response.code.toString());
        return false;
      }
  }

  /// returns true if the tweet is successfully unliked, false if it failed
  static Future<bool> unlikeTweetById(String token,String tweetId) async {
    ApiPath endPoint = (ApiPath.unlikeTweet).appendDirectory(tweetId);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiPatch(endPoint,headers: headers);
    if(response.code == 201){
      return true;
    }
    else
    {
      if (kDebugMode) {
        print(response.code);
      }
      return false;
    }
  }


  /// returns true if the tweet is successfully retweeted, false if it failed
  static Future<bool> retweetTweetById(String token,String tweetId) async {
    ApiPath endPoint = (ApiPath.retweet).appendDirectory(tweetId);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiPatch(endPoint,headers: headers);
    if(response.code == 204){
      return true;
    }
    else
    {
      if (kDebugMode) {
        print(response.code);
      }
      return false;
    }
  }

  /// returns list to the users who liked a certain post, if the request failed
  /// it should return null to indicate the failure
  static Future<List<User>?> getTweetLiker(String token,String tweetId) async {
    //TODO: for testing the dummy data
    tweetId = "tweet123";
    ApiPath endPoint = (ApiPath.unlikeTweet).appendDirectory(tweetId);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiPatch(endPoint,headers: headers);
    if(response.code == 200 && response.responseBody != null){
      return json.decode(response.responseBody!)["data"];
    }
    else
    {
      if (kDebugMode) {
        print(response.code);
      }
      return null;
    }
  }
}


TweetData getDefaultTweet(String id,MediaType mediaType){
  return TweetData(
      id: id,
      referredTweetId: '',

      description:
      "Bonjour, friends.According to the the prophecy: “The people will all be dissolved into the waters. And only the Hydro Archon will remain, weeping on her throne.” Let me take you back about 500 years ago in fontaine, where the main characters are The (previous) Hydro Archon, Dragon Neuvillette and an important person named Furina. The Hydro Archon created the Oratrice to deliver proper justice. They all lived happily until the cataclysm (I would like to make a note here that this cataclysm might be or might not be the khaenriahn one), which befelled the beloved Hydro Archon.",


      mediaType: mediaType,
      media:
      mediaType == MediaType.VIDEO ?
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      :
      "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
      viewsNum: 10,
      likesNum: 20,
      repliesNum: 30,
      repostsNum: 40,
      creationTime: DateTime.parse("2013-10-02T01:11:18.965+00:00"),
      type: "Masterpiece", tweetOwner: User(name: "Moa",id: "DedInside"),

      isLiked: false,
      isRetweeted: false
  );
}