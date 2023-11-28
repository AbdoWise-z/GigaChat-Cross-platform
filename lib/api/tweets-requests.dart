
import 'dart:convert';

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

  static Future<List<TweetData>> apiGetFollowingTweet (User currentUser) async
  {
    // TODO: call the api here when http package ends
    ApiResponse response = await Api.apiGet(ApiPath.followingTweets);
    if (response.code == ApiResponse.CODE_SUCCESS){
      final tweets = json.decode(response.responseBody!);
      List<dynamic> responseTweets = tweets["data"];
      responseTweets =
          responseTweets.map((tweet) =>
              TweetData(
                  id: tweet["id"],
                  referredTweetId: tweet["referredTweetId"],
                  description: tweet["description"],
                  viewsNum: tweet["viewsNum"],
                  likesNum: tweet["likesNum"],
                  repliesNum: tweet["repliesNum"],
                  repostsNum: tweet["repostsNum"],
                  creationTime: DateTime.parse(tweet["creation_time"]),
                  type: tweet["type"],

                  mediaType: tweet["media"]["type"] == "photo" ? MediaType.IMAGE : MediaType.VIDEO,
                  media: tweet["media"]["data"],
                  tweetOwner: User(
                    id: tweet["tweet_owner"]["id"],
                    name: tweet["tweet_owner"]["nickname"],
                    auth: currentUser.auth,
                    bio : tweet["tweet_owner"]["bio"],
                    iconLink : tweet["tweet_owner"]["profile_image"],
                    followers : tweet["tweet_owner"]["followers_num"],
                    following : tweet["tweet_owner"]["following_num"],
                    active : true,

                  ),
                  isLiked: tweet["isLiked"],
                  isRetweeted: tweet["isRetweeted"]
              )
          ).toList();
      return responseTweets.cast();
    }
    else{
      //TODO: load cached tweets
      // i will assume this is the cached tweets for now
      return [getDefaultTweet(),getDefaultTweet(),getDefaultTweet()];
    }
    return [];
  }
}


TweetData getDefaultTweet(){
  return TweetData(
      id: '1',
      referredTweetId: '',

      description:
      "Bonjour, friends.According to the the prophecy: “The people will all be dissolved into the waters. And only the Hydro Archon will remain, weeping on her throne.” Let me take you back about 500 years ago in fontaine, where the main characters are The (previous) Hydro Archon, Dragon Neuvillette and an important person named Furina. The Hydro Archon created the Oratrice to deliver proper justice. They all lived happily until the cataclysm (I would like to make a note here that this cataclysm might be or might not be the khaenriahn one), which befelled the beloved Hydro Archon.",


      mediaType: MediaType.IMAGE,
      media:
      "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",

      viewsNum: 10,
      likesNum: 20,
      repliesNum: 30,
      repostsNum: 40,
      creationTime: DateTime.parse("2013-10-02T01:11:18.965+00:00"),
      type: "Masterpiece", tweetOwner: User(name: "Osama",id: "Lolli-simp"),

      isLiked: false,
      isRetweeted: false
  );
}