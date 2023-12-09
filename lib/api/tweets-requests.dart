
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';

import '../base.dart';
import 'api.dart';
import "package:gigachat/api/user-class.dart";

class Tweets {

  //fixme: don't cache everything into the last list

  static Future<ApiResponse<String>> apiSendTweet(String token , IntermediateTweetData tweet) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    List<Map<String,String>> media = [];
    for (var m in tweet.media){
      media.add({
        "data": m.link,
        "type": m.type == MediaType.IMAGE ? "jpg" : "mp4",
      });
    }

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

  static List<TweetData> decodeTweetList(String token, ApiResponse response, ProviderFunction providerFunction){
    final tweets = json.decode(response.responseBody!);
    //print(response.responseBody!);

    if (providerFunction == ProviderFunction.HOME_PAGE_TWEETS) {
      List<dynamic> responseTweets = tweets["tweetList"];
      return responseTweets.map((tweet) {
        List<dynamic>? tweetMedia = tweet["tweetDetails"]["media"];
        print(tweet);
          return TweetData(
            id: tweet["tweetDetails"]["_id"],
            referredTweetId: tweet["tweetDetails"]["referredTweetId"] ?? "",
            description: tweet["tweetDetails"]["description"] ?? "ERR NOT DISC",
            viewsNum: 0,
            likesNum: tweet["tweetDetails"]["likesNum"],
            repliesNum: tweet["tweetDetails"]["repliesNum"],
            repostsNum: tweet["tweetDetails"]["repostsNum"],
            creationTime: DateTime.parse(tweet["tweetDetails"]["createdAt"]),
            type: tweet["type"],

            mediaType: tweetMedia == null || tweetMedia.isEmpty ? MediaType.IMAGE : (tweetMedia[0]["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO),
            media: tweetMedia == null || tweetMedia.isEmpty ? null : tweetMedia[0]["data"],
            tweetOwner: User(
              id: tweet["followingUser"]["username"],
              name: tweet["followingUser"]["nickname"],
              auth: token,
              isFollowed: true,
              //bio : "sad",
              iconLink : tweet["followingUser"]["profile_image"] ?? USER_DEFAULT_PROFILE,
              followers : tweet["followingUser"]["followers_num"],
              following : tweet["followingUser"]["following_num"],
              active : true,

            ),
            isLiked: tweet["isLiked"],
            //who tf made this ?
            isRetweeted: tweet["isRtweeted"],
          );
        }).toList();
    }
    if (providerFunction == ProviderFunction.PROFILE_PAGE_TWEETS) {
      List<dynamic> responseTweets = tweets["posts"];
      return responseTweets.map((tweet) {
        List<dynamic>? tweetMedia = tweet["media"];
        print(tweet);
        return TweetData(
          id: tweet["id"],
          description: tweet["description"] ?? "ERR NOT DISC",
          viewsNum: 0,
          likesNum: tweet["likesNum"] ?? 0,
          repliesNum: tweet["repliesNum"] ?? 0,
          repostsNum: tweet["repostsNum"] ?? 0,
          creationTime: DateTime.parse(tweet["creation_time"]),
          type: tweet["type"],

          mediaType: tweetMedia == null || tweetMedia.isEmpty ? MediaType.IMAGE : (tweetMedia[0]["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO),
          media: tweetMedia == null || tweetMedia.isEmpty ? null : tweetMedia[0]["data"],
          tweetOwner: User(
            id: tweet["tweet_owner"]["username"],
            name: tweet["tweet_owner"]["nickname"],
            auth: null,
            //bio : "sad",
            iconLink : tweet["tweet_owner"]["profile_image"] ?? USER_DEFAULT_PROFILE,
            followers : tweet["tweet_owner"]["followers_num"],
            following : tweet["tweet_owner"]["following_num"],
            active : true,

          ),
          isLiked: tweet["isLiked"],
          //who tf made this ?
          isRetweeted: tweet["isRetweeted"],
          referredTweetId: '',
        );
      }).toList();
    }
    if (providerFunction == ProviderFunction.GET_TWEET_COMMENTS) {
      List<dynamic> responseTweets = tweets["data"];
      return responseTweets.map((tweet) {
        List<dynamic>? tweetMedia = tweet["media"];
        return TweetData(
          id: tweet["id"],
          description: tweet["description"] ?? "ERR NOT DISC",
          viewsNum: 0,
          likesNum: tweet["likesNum"],
          repliesNum: tweet["repliesNum"],
          repostsNum: tweet["repostsNum"],
          creationTime: DateTime.parse(tweet["creation_time"]),
          type: tweet["type"],

          mediaType: tweetMedia == null || tweetMedia.isEmpty ? MediaType.IMAGE : (tweetMedia[0]["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO),
          media: tweetMedia == null || tweetMedia.isEmpty ? null : tweetMedia[0]["data"],
          tweetOwner: User(
            id: tweet["tweet_owner"][0]["username"],
            name: tweet["tweet_owner"][0]["nickname"],
            auth: null,
            //bio : "sad",
            iconLink : tweet["tweet_owner"][0]["profile_image"] ?? USER_DEFAULT_PROFILE,
            followers : tweet["tweet_owner"][0]["followers_num"],
            following : tweet["tweet_owner"][0]["following_num"],
            active : true,

          ),
          isLiked: tweet["isLiked"],
          //who tf made this ?
          isRetweeted: tweet["isRetweeted"],
          referredTweetId: '',
        );
      }
      ).toList();
    }

    return [];
  }
  /// returns list of the posts that the current logged in user following their owners,
  /// if the request failed to fetch new posts it should load the cached tweets to achieve availability

  static Future<List<TweetData>> getFollowingTweet (String token,String count, String page) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.followingTweets,
        headers: headers,
        params: {"page":page,"count":count}
    );

    if (response.code == ApiResponse.CODE_SUCCESS){

      if (response.responseBody!.isEmpty){
        return [getDefaultTweet("System", MediaType.IMAGE)]; //TODO: backend fix this pls ?
      }
      List<dynamic> responseTweets = decodeTweetList(token,response,ProviderFunction.HOME_PAGE_TWEETS);
      cachedTweets = responseTweets.cast();
    }
    else{
      //TODO: load cached tweets
      // i will assume this is the cached tweets for now
      loadCache();
    }
    return cachedTweets.where((element) => element.type == "tweet").toList();
  }

  static Future<List<TweetData>> getProfilePageTweets (String token,String userID, String count, String page) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.userProfileTweets.format([userID]),
        headers: headers,
        params: {"page":page,"count":count}
    );
    //print(response.responseBody);
    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody!.isNotEmpty){
      List<dynamic> responseTweets = decodeTweetList(token,response,ProviderFunction.PROFILE_PAGE_TWEETS);
      cachedTweets = responseTweets.cast();
    }
    else
    {
      //TODO: load cached tweets
      // i will assume this is the cached tweets for now
      loadCache();
    }
    return cachedTweets.where((element) => element.type == "tweet").toList();
  }

  static Future<List<TweetData>> getTweetReplies (String token,String tweetID, String count, String page) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.comments.format([tweetID]),
        headers: headers,
        params: {"page":page,"count":count}
    );
    if (response.code == ApiResponse.CODE_SUCCESS){
      if (response.responseBody!.isEmpty){
        return [];
      }
      List<dynamic> responseTweets = decodeTweetList(token,response,ProviderFunction.GET_TWEET_COMMENTS);
      cachedTweets = responseTweets.cast();
    }
    else
    {
      //TODO: load cached tweets
      // i will assume this is the cached tweets for now
      loadCache();
    }
    return cachedTweets;
  }

  static Future<List<User>> getTweetLikers(String token, String tweetId,String page) async
  {
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
                    iconLink: user["profile_image"] ?? "https://i.imgur.com/C1bPcWq.png",
                    isFollowed: user["isFollowed"],
                )
      ).toList();
    }
    return [];
  }
  static Future<List<User>> getTweetRetweeters(String token, String tweetId,String page) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.tweetRetweeters.format([tweetId]),
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
                    iconLink: user["profile_image"] ?? "https://i.imgur.com/C1bPcWq.png",
                    isFollowed: user["isFollowed"],
                )
      ).toList();
    }
    return [];
  }


  /// returns true if the tweet is successfully liked, false if it failed
  static Future<bool> likeTweetById(String token,String tweetId) async {
      ApiPath endPoint = (ApiPath.likeTweet).appendDirectory(tweetId);
      var headers = Api.getTokenWithJsonHeader("Bearer $token");
      ApiResponse response = await Api.apiPost(endPoint,headers: headers);
      //print(response.code);
      switch(response.code){
        case ApiResponse.CODE_SUCCESS_NO_BODY:
          return true;
        case ApiResponse.CODE_NO_INTERNET:
        case ApiResponse.CODE_BAD_REQUEST:
        case ApiResponse.CODE_TIMEOUT:
          throw "something went wrong, check your connection and try again";
        default:
          throw "something went wrong";
      }
  }

  /// returns true if the tweet is successfully unliked, false if it failed
  static Future<bool> unlikeTweetById(String token,String tweetId) async {
    ApiPath endPoint = (ApiPath.unlikeTweet).appendDirectory(tweetId);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiPost(endPoint,headers: headers);
    switch(response.code){
      case ApiResponse.CODE_SUCCESS_CREATED:
      case ApiResponse.CODE_SUCCESS_NO_BODY:
        return true;
      case ApiResponse.CODE_NO_INTERNET:
      case ApiResponse.CODE_BAD_REQUEST:
      case ApiResponse.CODE_TIMEOUT:
        throw "something went wrong, check your connection and try again";
      default:
        throw "something went wrong";
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
        //print(response.code);
      }
      return false;
    }
  }

  static Future<bool> unretweetTweetById(String token,String tweetId) async {
    ApiPath endPoint = (ApiPath.unretweet).appendDirectory(tweetId);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiPatch(endPoint,headers: headers);
    if(response.code == 204){
      return true;
    }
    else
    {
      if (kDebugMode) {
        //print(response.code);
      }
      return false;
    }
  }
}


TweetData getDefaultTweet(String id,MediaType mediaType){
  if (id == "System"){
    return TweetData(
        id: id,
        referredTweetId: '',

        description: "Searching for others users is not supported at the moment, will add this in the future",

        mediaType: mediaType,
        media:
        mediaType == MediaType.VIDEO ?
        "https://i.imgur.com/rLr8Swh.mp4"
            :
        "https://i.imgur.com/cufIziI.gif",
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