import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/base.dart';

class FeedController {
  String? token;
  Map<String, dynamic>? _feedCache;
  ProviderFunction providerFunction;
  int? lastFetchedPage;

  FeedController({this.token, required this.providerFunction}) {
    _feedCache = {};
    lastFetchedPage = 0;
  }

  void setUserToken(String? userToken) {
    token = userToken;
  }

  void appendToMap(Map<String, dynamic> newData) async {
    _feedCache!.addAll({...newData});
  }

  List getCurrentData (){
    return _feedCache == null ? [] : _feedCache!.values.toList();
  }

  Future<List> fetchFeedData({bool? appendToBegin,String? username,String? tweetID}) async {

    if (token == null) {
      throw "user is not logged in -- logged from feed controller line 30 -- ";
    }

    // TODO: you can add here what ever provider you want
    switch (providerFunction) {
      case ProviderFunction.HOME_PAGE_TWEETS:
        appendToMap(
            await Tweets.getFollowingTweet(token!,
              DEFAULT_PAGE_COUNT.toString(), (lastFetchedPage! + 1).toString()
            )
        );

      case ProviderFunction.PROFILE_PAGE_TWEETS:
        appendToMap(
          await Tweets.getProfilePageTweets(
              token!,
              username!,
              DEFAULT_PAGE_COUNT.toString(),
              (lastFetchedPage! + 1).toString())
        );
      case ProviderFunction.GET_TWEET_COMMENTS:
        appendToMap(
            await Tweets.getTweetReplies(
                token!,
                tweetID!,
                DEFAULT_PAGE_COUNT.toString(),
                (lastFetchedPage! + 1).toString())
        );
      default:
        _feedCache = {};
    }

    return _feedCache!.values.toList();
  }

}

// Future<List<TweetData>> fetchAndDecodeTweets(
//     ProviderFunction providerFunction, String userToken, int page,
//     {String? userID, String? tweetID, bool? appendToBegin}) async {
//   if (_lastRequestedPage! >= page) {
//     // the list is already updated with the requested page
//     return _currentFeedData;
//   }
//   _lastRequestedPage = page;
//   List<TweetData> response = [];
//   switch (providerFunction) {
//     case ProviderFunction.HOME_PAGE_TWEETS:
//       response = await Tweets.getFollowingTweet(
//           userToken, pageCount.toString(), page.toString());
//       break;
//     case ProviderFunction.PROFILE_PAGE_TWEETS:
//       response = await Tweets.getProfilePageTweets(
//           userToken, userID!, pageCount.toString(), page.toString());
//       break;
//     case ProviderFunction.GET_TWEET_COMMENTS:
//       response = await Tweets.getTweetReplies(
//           userToken, tweetID!, pageCount.toString(), page.toString());
//       break;
//   }
//   for (var tweet in response) {
//     if (!_currentIdsFetched.contains(tweet.id)) {
//       appendToBegin == null
//           ? _currentFeedData.add(tweet)
//           : _currentFeedData.insert(0, tweet);
//       _currentIdsFetched.add(tweet.id);
//     }
//   }
//   return _currentFeedData;
// }
