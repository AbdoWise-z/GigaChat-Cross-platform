
import 'dart:convert';

import 'package:gigachat/base.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/widgets/post.dart';

class TweetsInterface
{
    final String GET_FOLLOWING_TWEETS_API = "$API_LINK/api/homepage/following";
    List<Tweet>? serverResponse;

    static Future<List<TweetData>> apiGetFollowingTweet (User currentUser) async
    {
        final headers = Api.getTokenWithJsonHeader("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTBkMmY5ZjkwODhlODgzMThmZDEwYyIsImlhdCI6MTcwMTEwMzI2NywiZXhwIjoxNzA4ODc5MjY3fQ.Il_1vL2PbOE36g0wW55Lh1M7frJWx73gNIZ0uDuP5yw");
        // TODO: call the api here when http package ends
        ApiResponse response = await Api.apiGet(ApiPath.followingTweets,headers: headers);
        print(response.responseBody);
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


    static Future<List<TweetData>> GetTweetReplies (String tweetId) async
    {
      Api.apiGet(ApiPath.comments , params: {"tweetId": tweetId});
      return [getDefaultTweet(),getDefaultTweet(),getDefaultTweet()];
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