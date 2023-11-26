
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
      "when i woke up ... i was riding in a flower carriage, it was my birthday,"
          "loremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremlorem",


      mediaType: MediaType.IMAGE,
      media:
      "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",

      viewsNum: 12,
      likesNum: 999,
      repliesNum: 1,
      repostsNum: 0,
      creationTime: DateTime(2022, 5, 30, 12, 24, 30),
      type: "Masterpiece", tweetOwner: User(name: "Osama",id: "Lolli-simp"),

      isLiked: false,
      isRetweeted: false
  );
}