
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import '../base.dart';
import 'api.dart';
import "package:gigachat/api/user-class.dart";


/// This class is responsible for dealing with the tweets api endpoints
/// and decode the result into tweet data class
class Tweets {


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
    return [
      getDefaultTweet("1",MediaType.IMAGE),
      getDefaultTweet("2",MediaType.IMAGE),
      getDefaultTweet("3",MediaType.IMAGE),
      getDefaultTweet("4",MediaType.IMAGE),
      getDefaultTweet("5",MediaType.IMAGE),
    ];
  }

  /// a function that follows the given path [fullPath] and navigate throw the object untill it reaches the desired location
  /// EX: let [obj] = {data:{data1 : {data2 : 0}}} and the [fullPath] be [data,data1,data2]
  /// Then the function will do the following => [obj] = {data1: {data2 : 0}} => [obj] = {data2 : 0} => [obj] = 0 and 0 is returned
  /// [obj] dynamic object
  /// [fullPath] : List of Strings specifying the required path
  /// Note: if the path contained a media as string then a list of TweetMedia will be returned
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

  /// Responsible For Decoding The Tweet's Reply That Is Passed with the tweet as it's first reply to be shown
  /// [replyObject] the reply object inside the tweet response
  /// Return: TweetData object of the reply data
  static TweetData? decodeTweetReply(dynamic replyObject){
    if (replyObject.isEmpty){
      return null;
    }
      return TweetData(
          id: replyObject["id"],
          referredTweetId: replyObject["referredTweetId"],
          description: replyObject["description"],
          viewsNum: replyObject["viewsNum"],
          likesNum: replyObject["likesNum"],
          repliesNum: replyObject["repliesNum"],
          repostsNum: replyObject["repostsNum"],
          creationTime: DateTime.parse(replyObject["creation_time"]),
          type: replyObject["type"],
          tweetOwner: User(
            name: replyObject["tweet_owner"]["nickname"],
            id: replyObject["tweet_owner"]["username"],
            bio: replyObject["tweet_owner"]["nickname"],
            iconLink: replyObject["tweet_owner"]["profile_image"],
            following:replyObject["tweet_owner"]["following_num"],
            followers: replyObject["tweet_owner"]["followers_num"],
            isFollowed: replyObject["tweet_owner"]["isFollowed"],
          ),
          isLiked: replyObject["isLiked"],
          isRetweeted: replyObject["isRetweeted"],
          media: specialAccessObject(replyObject, ["media"]),
          isFollowingMe: replyObject["tweet_owner"]["isFollowingMe"],
      );
  }

  /// This Functions handle getting replied tweet tweet owner to show it for user as (Replying to @...)
  /// [tweetID] id of the reply tweet
  /// [token] currently logged in user id
  static Future<String?> getRepliedTweetUserId(String token, String tweetID) async {
    ApiPath endPointPath = ApiPath.tweetOwnerId.format([tweetID]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        endPointPath,
        headers: headers
    );
    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      dynamic res = jsonDecode(response.responseBody!);
      return res["data"]["tweet_owner"];
    }
    else {
      return null;
    }
  }

  /// Responsible For Decoding The List Of Tweets Responded By Server
  /// [token] currently logged in user token
  /// [response] the response object (stringified JSON object)
  /// [accessor] Map that maps each tweetData property to its own path
  /// returns Future List Of Tweet Data for the responded Tweets
  /// in case of failure, empty list is returned
  static Future<List<TweetData>> decodeTweetList(
      String token,
      ApiResponse response,
      Map<String,List<String>?> accessor,
      {
        bool fetchReplyTweet = false
      }) async
  {
    if (response.responseBody == null || response.responseBody!.isEmpty){
      return [];
    }
    //print(response.responseBody);
    final List tweets =
    accessor["data"] != null ?
    specialAccessObject(json.decode(response.responseBody!), accessor["data"])
    :
    jsonDecode(response.responseBody!);
    List<TweetData> tweetList = tweets.map((tweet) {
      List<dynamic>? tweetMedia = accessor["base"] == null ? tweet["media"] : tweet[accessor["base"]![0]]["media"];
      bool hasMedia = tweetMedia != null && tweetMedia.isNotEmpty;
      TweetData tweetData =  TweetData(
          id: specialAccessObject(tweet, accessor["id"]!),
          referredTweetId: specialAccessObject(tweet, accessor["referredTweetId"]!),
          description: specialAccessObject(tweet, accessor["description"]!) ?? "",
          viewsNum: specialAccessObject(tweet, accessor["viewsNum"]) ?? 0,
          likesNum: specialAccessObject(tweet, accessor["likesNum"]!) ?? 0,
          repliesNum: specialAccessObject(tweet, accessor["repliesNum"]!),
          repostsNum: specialAccessObject(tweet, accessor["repostsNum"]!),
          creationTime: DateTime.parse(specialAccessObject(tweet, accessor["creationTime"]!)),
          type: specialAccessObject(tweet, accessor["type"]!) ?? "tweet",

          tweetOwner: User(
            id: specialAccessObject(tweet, accessor["tweetOwnerID"]!),
            name: specialAccessObject(tweet, accessor["tweetOwnerName"]!),
            auth: token,
            isFollowed: specialAccessObject(tweet, accessor["tweetOwnerIsFollowed"]) ?? true,
            bio : specialAccessObject(tweet, accessor["tweetOwnerBio"]) ?? "",
            iconLink : specialAccessObject(tweet, accessor["tweetOwnerIcon"]!) ?? USER_DEFAULT_PROFILE,
            followers : specialAccessObject(tweet, accessor["tweetOwnerFollowers"]),
            following : specialAccessObject(tweet, accessor["tweetOwnerFollowing"]!),
            isWantedUserMuted : specialAccessObject(tweet, accessor["tweetOwnerIsMuted"]) ?? false,
            isWantedUserBlocked : specialAccessObject(tweet, accessor["tweetOwnerIsBlocked"]) ?? false,
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
          isRetweeted: specialAccessObject(tweet, accessor["isRetweeted"]!) ?? false,
          isFollowingMe: specialAccessObject(tweet, accessor["isFollowingMe"]) ?? false,
          media: hasMedia ? specialAccessObject(tweet, accessor["media"]!) : null,

          replyTweet:  fetchReplyTweet ? decodeTweetReply(tweet["reply"]) : null,
      );
      return tweetData;
    }).toList();
    for (TweetData tweetData in tweetList){
      if (tweetData.referredTweetId != null){
        tweetData.replyingUserId = await getRepliedTweetUserId(token, tweetData.referredTweetId!);
        if (tweetData.replyTweet != null){
          tweetData.replyTweet!.replyingUserId = tweetData.tweetOwner.id;
        }
      }
    }
    return tweetList;
  }

  /// returns list of the posts that the current logged in user following their owners,
  /// if the request failed an empty list will be returned
  /// [token] currently logged in user id
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
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
          "tweetOwnerIsFollowed": ["isFollowed"],
          "tweetOwnerBio": null,
          "tweetOwnerIcon": ["tweetDetails", "tweet_owner", "profile_image"],
          "tweetOwnerFollowers": ["tweetDetails", "tweet_owner", "followers_num"],
          "tweetOwnerFollowing": ["tweetDetails", "tweet_owner", "following_num"],
          "tweetOwnerIsBlocked" : null,
          "tweetOwnerIsMuted" : null,

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
          "isFollowingMe" : ["isFollowingMe"],
          "media": ["tweetDetails","media"],
        }, ApiPath.followingTweets);
  }

  /// gets the profile page tweets of a certain user
  /// [token] currently logged in user id
  /// [userID] username of the user to show his/her profile
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
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
      "tweetOwnerIsBlocked" : null,
      "tweetOwnerIsMuted" : null,

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRetweeted"],
      "isFollowingMe" : ["isFollowingMe"],
      "media": ["media"]
    }, ApiPath.userProfileTweets.format([userID]));
  }


  /// gets certain user liked tweets
  /// [token] currently logged in user id
  /// [userID] username of the user to show his/her liked tweets
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
  static Future<Map<String,TweetData>> getProfilePageLikes (String token,String userID, String count, String page) async
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
      "tweetOwnerIsBlocked" : null,
      "tweetOwnerIsMuted" : null,

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRetweeted"],
      "isFollowingMe" : ["isFollowingMe"],
      "media": ["media"]
    }, ApiPath.userProfileLikes.format([userID]));
  }


  /// gets tweets that the current user was mentioned in
  /// [token] currently logged in user id
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
  static Future<Map<String,TweetData>> getMentionTweets (String token,String count, String page) async
  {
    return await fetchTweetsWithApiInterface(token, count, page, {
      "data" : ["tweetList"],
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
      "tweetOwnerIsFollowed": ["tweet_owner","isFollowed"],
      "tweetOwnerBio": null,
      "tweetOwnerIcon": ["tweet_owner", "profile_image"],
      "tweetOwnerFollowers": ["tweet_owner", "followers_num"],
      "tweetOwnerFollowing": ["tweet_owner", "following_num"],
      "tweetOwnerIsBlocked" : null,
      "tweetOwnerIsMuted" : null,

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRtweeted"],
      "isFollowingMe" : ["isFollowingMe"],
      "media": ["media"],
    }, ApiPath.mentions);
  }


  /// get certain tweets reply list
  /// [token] currently logged in user id
  /// [tweetID] tweet id of the replied tweet
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
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
      "tweetOwnerIsBlocked" : null,
      "tweetOwnerIsMuted" : null,

      "isLiked": ["isLiked"],
      "isRetweeted": ["isRetweeted"],
      "media": ["media"]
    }, ApiPath.comments.format([tweetID]),fetchAdditionalReply: true);
  }


  /// gets a tweet by its id
  /// [token] currently logged in user id
  /// [tweetID] id of the tweet to be fetched
  /// return a TweetData object with the tweet data
  /// return null if failure happened
  static Future<TweetData?> getTweetById(String token, String tweetID) async {
    ApiPath endPointPath = ApiPath.getTweet.format([tweetID]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        endPointPath,
        headers: headers
    );
    print(response.responseBody);

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      dynamic tweet = jsonDecode(response.responseBody!)["data"];
      TweetData tweetData = TweetData(
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
            isWantedUserBlocked: false,
            isWantedUserMuted: false
          ),
          isLiked: tweet["isLiked"],
          isRetweeted: tweet["isRetweeted"],
          isFollowingMe: tweet["isFollowingMe"] ?? false,
          media: tweet["media"].map((media){
            return MediaData(
                mediaType: media["type"] == "jpg" ? MediaType.IMAGE : MediaType.VIDEO,
                mediaUrl: media["data"],
            ) ;
          }).toList().cast<MediaData>()
      );
      if (tweetData.referredTweetId != null){
        tweetData.replyingUserId = await getRepliedTweetUserId(token, tweetData.referredTweetId!);
      }
      return tweetData;
    }

    return null;
  }


  /// general function to fetch all types of tweet lists
  /// all this class functions uses this function to access the endpoint and fetch data
  /// [token] currently logged in user id
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// [accessor] Map object that maps every tweet data attribute to its path in the response
  /// [endPointPath] uri to be connected to
  /// [fetchAdditionalReply] {optional} : fetch a reply with each tweet if found
  /// return a mapped list of tweetId vs tweetData
  /// if failed an empty map will be returned
  static Future<Map<String,TweetData>> fetchTweetsWithApiInterface
      (
        String token,
        String count,
        String page,
        Map<String,List<String>?> accessor,
        ApiPath endPointPath,
      {
        bool fetchAdditionalReply = false
      }
      ) async
  {
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(
        endPointPath,
        headers: headers,
        params: {"page":page,"count":count}
    );

    if (response.code == ApiResponse.CODE_SUCCESS){
      List<TweetData> responseTweets = await decodeTweetList(
        token,
        response,
        accessor,
        fetchReplyTweet : fetchAdditionalReply,
      );
      Map<String,TweetData> mappedIdTweets = {};
      for(TweetData tweet in responseTweets){
        mappedIdTweets.putIfAbsent(tweet.id, () => tweet);
      }

      return mappedIdTweets;
    }
    else{
      return {};
    }
  }


  /// gets the users the liked a certain tweet
  /// [token] currently logged in user id
  /// [tweetId] id of the target tweet
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a List of users
  /// if failed an empty list will be returned
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

  /// gets the users that retweeted a certain tweet
  /// [token] currently logged in user id
  /// [tweetId] id of the target tweet
  /// [count] number of tweets to be fetched
  /// [page] number of page to be fetched
  /// return a List of users
  /// if failed an empty list will be returned
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

  /// unretweet the tweet by its id
  /// [token] currently logged in user id
  /// [tweetId] id of the target tweet
  /// return true if the tweet was unretweeted, false if failed
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

  /// delete a tweet by its id
  /// [token] currently logged in user id
  /// [tweetId] id of the target tweet
  /// return true if the tweet was successfully deleted or false any case else
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
        isFollowingMe: false,
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
      isRetweeted: false,
      isFollowingMe: false,
  );
}