
import 'package:gigachat/base.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/util/user-data.dart';
import 'package:gigachat/widgets/post.dart';

class TweetsInterface
{
    final String GET_FOLLOWING_TWEETS_API = "$API_LINK/api/homepage/following";
    List<Tweet>? serverResponse;

    static Future<List<TweetData>> apiGetFollowingTweet (User currentUser) async
    {
        // TODO: call the api here when http package ends
        return [getDefaultTweet(),getDefaultTweet(),getDefaultTweet(),getDefaultTweet()];
    }

}
