
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
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

  static specialAccessObject(dynamic obj, List<String>? fullPath){
    dynamic currentObject = obj;
    if (fullPath == null){
      return null;
    }

    for (var path in fullPath) {
      currentObject = currentObject[path];
      if(path == "media"){
        List<MediaData> mediaList = [];
        for (var media in currentObject){
          MediaType mediaType = media["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO;
          mediaList.add(MediaData(mediaType: mediaType, mediaUrl: media["data"]));
        }
        return mediaList;
      }
    }

    return currentObject;
  }

  static List<TweetData> decodeTweetList(
      String token,
      ApiResponse response,
      Map<String,List<String>?> accessor
      )
  {
    if (response.responseBody == null || response.responseBody!.isEmpty){
      return [];
    }
    //print(response.responseBody);
    final List tweets = specialAccessObject(json.decode(response.responseBody!), accessor["data"]);
    return tweets.map((tweet){
      List<dynamic>? tweetMedia = accessor["base"] == null ? tweet["media"] : tweet[accessor["base"]![0]]["media"];
      bool hasMedia = tweetMedia != null && tweetMedia.isNotEmpty;
      return TweetData(
          id: specialAccessObject(tweet, accessor["id"]!),
          referredTweetId: specialAccessObject(tweet, accessor["referredTweetId"]!),
          description: specialAccessObject(tweet, accessor["description"]!) ?? "",
          viewsNum: specialAccessObject(tweet, accessor["viewsNum"]) ?? 0,
          likesNum: specialAccessObject(tweet, accessor["likesNum"]!) ?? 0,
          repliesNum: specialAccessObject(tweet, accessor["repliesNum"]!),
          repostsNum: specialAccessObject(tweet, accessor["repostsNum"]!),
          creationTime: DateTime.parse(specialAccessObject(tweet, accessor["creationTime"]!)),
          type: specialAccessObject(tweet, accessor["type"]!),

          tweetOwner: User(
            id: specialAccessObject(tweet, accessor["tweetOwnerID"]!),
            name: specialAccessObject(tweet, accessor["tweetOwnerName"]!),
            auth: token,
            isFollowed: specialAccessObject(tweet, accessor["tweetOwnerIsFollowed"]) ?? true,
            bio : specialAccessObject(tweet, accessor["tweetOwnerBio"]) ?? "",
            iconLink : specialAccessObject(tweet, accessor["tweetOwnerIcon"]!) ?? USER_DEFAULT_PROFILE,
            followers : specialAccessObject(tweet, accessor["tweetOwnerFollowers"]),
            following : specialAccessObject(tweet, accessor["tweetOwnerFollowing"]!),
            active : true,
          ),

          reTweeter: accessor["tweetRetweeter"] == null ? null : User(
            id: specialAccessObject(tweet, accessor["tweetRetweeterID"]!),
            name: specialAccessObject(tweet, accessor["tweetRetweeterName"]!),
            auth: token,
            isFollowed: specialAccessObject(tweet, accessor["tweetRetweeterIsFollowed"]) ?? false,
            bio : specialAccessObject(tweet, accessor["tweetRetweeterBio"]) ?? "",
            iconLink : specialAccessObject(tweet, accessor["tweetRetweeterIcon"]!) ?? USER_DEFAULT_PROFILE,
            followers : specialAccessObject(tweet, accessor["tweetRetweeterFollowers"]),
            following : specialAccessObject(tweet, accessor["tweetRetweeterFollowing"]!),
            active : true,
          ),

          isLiked: specialAccessObject(tweet, accessor["isLiked"]!),
          isRetweeted: specialAccessObject(tweet, accessor["isRetweeted"]!),
          media: hasMedia ? specialAccessObject(tweet, accessor["media"]!) : null
      );
    }).toList();
  }
  /// returns list of the posts that the current logged in user following their owners,
  /// if the request failed to fetch new posts it should load the cached tweets to achieve availability

  static Future<Map<String,TweetData>> getFollowingTweet (String token,String count, String page) async
  {
    return await fetchTweetsWithApiInterface(token, count, page, {
          "data" : ["tweetList"],
          "base" : ["tweetDetails"],
          "id": ["tweetDetails","_id"],
          "referredTweetId": ["tweetDetails","referredTweetId"],
          "description": ["tweetDetails","description"],
          "viewsNum": null,
          "likesNum": ["tweetDetails", "likesNum"],
          "repliesNum": ["tweetDetails", "repliesNum"],
          "repostsNum": ["tweetDetails", "repostsNum"],
          "creationTime": ["tweetDetails","createdAt"],
          "type": ["type"],

          "tweetOwnerID": ["tweetDetails", "tweet_owner", "username"],
          "tweetOwnerName": ["tweetDetails", "tweet_owner", "nickname"],
          "tweetOwnerIsFollowed": ["tweetDetails","isFollowed"],
          "tweetOwnerBio": null,
          "tweetOwnerIcon": ["tweetDetails", "tweet_owner", "profile_image"],
          "tweetOwnerFollowers": ["tweetDetails", "tweet_owner", "followers_num"],
          "tweetOwnerFollowing": ["tweetDetails", "tweet_owner", "following_num"],

          "tweetRetweeter" : ["followingUser"],
          "tweetRetweeterID": ["followingUser", "username"],
          "tweetRetweeterName": ["followingUser", "nickname"],
          "tweetRetweeterIsFollowed": null,
          "tweetRetweeterBio": null,
          "tweetRetweeterIcon": ["followingUser", "profile_image"],
          "tweetRetweeterFollowers": ["followingUser", "followers_num"],
          "tweetRetweeterFollowing": ["followingUser", "following_num"],


          "isLiked": ["isLiked"],
          "isRetweeted": ["isRtweeted"],
          "media": ["tweetDetails","media"],
        }, ApiPath.followingTweets);
  }

  static Future<Map<String,TweetData>> getProfilePageTweets (String token,String userID, String count, String page) async
  {
    return await fetchTweetsWithApiInterface(token, count, page, {
      "data" : ["posts"],
      "base" : null,
      "id": ["id"],
      "referredTweetId": ["referredTweetId"],
      "description": ["description"],
      "viewsNum": null,
      "likesNum": ["likesNum"],
      "repliesNum": ["repliesNum"],
      "repostsNum": ["repostsNum"],
      "creationTime": ["creation_time"],
      "type": ["type"],

      "tweetOwnerID": ["tweet_owner", "username"],
      "tweetOwnerName": ["tweet_owner", "nickname"],
      "tweetOwnerIsFollowed": ["isFollowed"],
      "tweetOwnerBio": null,
      "tweetOwnerIcon": ["tweet_owner", "profile_image"],
      "tweetOwnerFollowers": ["tweet_owner", "followers_num"],
      "tweetOwnerFollowing": ["tweet_owner", "following_num"],

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRetweeted"],
      "media": ["media"]
    }, ApiPath.userProfileTweets.format([userID]));
  }

  static Future<Map<String, TweetData>> getTweetReplies (String token,String tweetID, String count, String page) async
  {
    return await fetchTweetsWithApiInterface(token, count, page, {
      "data" : ["data"],
      "base" : null,
      "id": ["id"],
      "referredTweetId": ["referredTweetId"],
      "description": ["description"],
      "viewsNum": null,
      "likesNum": ["likesNum"],
      "repliesNum": ["repliesNum"],
      "repostsNum": ["repostsNum"],
      "creationTime": ["creation_time"],
      "type": ["type"],

      "tweetOwnerID": ["tweet_owner", "username"],
      "tweetOwnerName": ["tweet_owner", "nickname"],
      "tweetOwnerIsFollowed": null,
      "tweetOwnerBio": null,
      "tweetOwnerIcon": ["tweet_owner", "profile_image"],
      "tweetOwnerFollowers": ["tweet_owner", "followers_num"],
      "tweetOwnerFollowing": ["tweet_owner", "following_num"],

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRetweeted"],
      "media": ["media"]
    }, ApiPath.comments.format([tweetID]));
  }

  static Future<TweetData?> getTweetById(String token, String tweetID) async {
    ApiPath endPointPath = ApiPath.getTweet.format([tweetID]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        endPointPath,
        headers: headers
    );
    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      dynamic tweet = jsonDecode(response.responseBody!)["data"];
      return TweetData(
          id: tweet["id"],
          referredTweetId: tweet["referredTweetId"],
          description: tweet["description"],
          viewsNum: tweet["viewsNum"] ?? 0,
          likesNum: tweet["likesNum"] ?? 0,
          repliesNum: tweet["repliesNum"] ?? 0,
          repostsNum: tweet["repostsNum"] ?? 0,
          creationTime: DateTime.parse(tweet["creation_time"]),
          type: tweet["type"],
          tweetOwner: User(
            id: tweet["tweet_owner"]["username"],
            name: tweet["tweet_owner"]["nickname"],
            iconLink: tweet["tweet_owner"]["profile_image"],
            isFollowed: false,
            followers: tweet["tweet_owner"]["followers_num"],
            following: tweet["tweet_owner"]["following_num"],
          ),
          isLiked: tweet["isLiked"],
          isRetweeted: tweet["isRetweeted"],
          media: tweet["media"].map((media){
            return MediaData(
                mediaType: media["data"],
                mediaUrl: media["type"],
            ) ;
          }).toList().cast<MediaData>()
      );
    }

    return null;
  }

  static Future<Map<String,TweetData>> fetchTweetsWithApiInterface
      (
        String token,
        String count,
        String page,
        Map<String,List<String>?> accessor,
        ApiPath endPointPath
      ) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        endPointPath,
        headers: headers,
        params: {"page":page,"count":count}
    );

    if (response.code == ApiResponse.CODE_SUCCESS){
      List<TweetData> responseTweets = decodeTweetList(
        token,
        response,
        accessor
      );
      Map<String,TweetData> mappedIdTweets = {};
      for(TweetData tweet in responseTweets){
        mappedIdTweets.putIfAbsent(tweet.id, () => tweet);
      }

      return mappedIdTweets;
    }
    else{
      //TODO: load cached tweets
      return {};
    }
  }


  static Future<List<User>> getTweetLikers(String token, String tweetId,String page, String count) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.tweetLikers.appendDirectory(tweetId),
        headers: headers,
        params: {"page": page, "count": count}
    );
    if (response.code == ApiResponse.CODE_SUCCESS){
      dynamic jsonResponse = json.decode(response.responseBody!);
      List<dynamic> users = jsonResponse["data"];
      return users.map(
              (user) => User(
              id: user["username"] ?? "",
              name: user["nickname"],
              bio: user["bio"] ?? "",
              isFollowed: user["isFollowed"],
              iconLink: user["profile_image"] ?? "https://i.imgur.com/C1bPcWq.png"
          )
      ).toList();
    }
    return [];
  }
  static Future<List<User>> getTweetRetweeters(String token, String tweetId,String page,String count) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        ApiPath.tweetRetweeters.format([tweetId]),
        headers: headers,
        params: {"page": page,"count": count}
    );
    if (response.code == ApiResponse.CODE_SUCCESS){
      dynamic jsonResponse = json.decode(response.responseBody!);
      List<dynamic> users = jsonResponse["data"];
      return users.map(
              (user) => User(
              id: user["username"] ?? "",
              name: user["nickname"],
              bio: user["bio"] ?? "",
              isFollowed: user["isFollowed"],
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
    ApiResponse response = await Api.apiPost(endPoint,headers: headers);
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

  static Future<bool> deleteTweetById(String token,String tweetId) async {
    ApiPath endPoint = ApiPath.deleteTweet.format([tweetId]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiDelete(endPoint,headers: headers);
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
        media: [MediaData(mediaType: mediaType, mediaUrl: mediaType == MediaType.VIDEO ?
        "https://i.imgur.com/rLr8Swh.mp4"
            :
        "https://i.imgur.com/cufIziI.gif")],
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


      media: [MediaData(mediaType: mediaType, mediaUrl: mediaType == MediaType.VIDEO ?
      "https://i.imgur.com/rLr8Swh.mp4"
          :
      "https://i.imgur.com/cufIziI.gif")],
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