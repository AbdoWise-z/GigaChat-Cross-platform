import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';

class FeedProvider
{
  List<TweetData> _currentFeedData = [];
  List<String> _currentIdsFetched = [];
  int? _lastRequestedPage;
  int pageCount = 5;


  FeedProvider({
    required this.pageCount
  }){
    _lastRequestedPage = 0;
  }

  Future<List<TweetData>> getFollowingTweets(String userToken,int page) async
  {
    return fetchAndDecodeTweets(ProviderFunction.HOME_PAGE_TWEETS, userToken, page);
  }

  Future<List<TweetData>> getUserProfileTweets(String userToken,int page,String userID) async
  {
    return fetchAndDecodeTweets(ProviderFunction.PROFILE_PAGE_TWEETS, userToken, page,userID: userID);
  }

  Future<List<TweetData>> getTweetReplies(String userToken,int page,String tweetID) async
  {
    return fetchAndDecodeTweets(ProviderFunction.GET_TWEET_COMMENTS, userToken, page,tweetID: tweetID);
  }

  Future<List<TweetData>> fetchAndDecodeTweets(
      ProviderFunction providerFunction,
      String userToken,
      int page,
      {
        String? userID,
        String? tweetID
      }
      ) async {

    if (_lastRequestedPage! >= page)
    {
      // the list is already updated with the requested page
      return _currentFeedData;
    }
    _lastRequestedPage = page;
    List<TweetData> response = [];
    switch(providerFunction){
      case ProviderFunction.HOME_PAGE_TWEETS:
        response = await Tweets.getFollowingTweet(
            userToken,
            pageCount.toString(),
            page.toString()
        );
        break;
      case ProviderFunction.PROFILE_PAGE_TWEETS:
        response = await Tweets.getProfilePageTweets(
            userToken,
            userID!,
            pageCount.toString(),
            page.toString()
        );
        break;
      case ProviderFunction.GET_TWEET_COMMENTS:
        response = await Tweets.getTweetReplies(
            userToken,
            tweetID!,
            pageCount.toString(),
            page.toString()
        );
        break;
    }
    for (var tweet in response) {
      if(!_currentIdsFetched.contains(tweet.id)){
        _currentFeedData.add(tweet);
        _currentIdsFetched.add(tweet.id);
      }
    }
    return _currentFeedData;
  }

  List<TweetData> getCurrentTweets()
  {
    return _currentFeedData;
  }

  void likeTweet(String tweetId) async
  {
    // TODO: CALL THE API HERE
  }

  Future<bool> retweetTweet(String tweetId) async
  {
    // TODO: Call The api here
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> undoRetweet(String tweetId) async
  {
    // TODO: Call The api here
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> sendTweet(User from , IntermediateTweetData data , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Tweets.apiSendTweet(from.auth! , data);
    if (res.data != null){
      if (success != null) success(res);
      return true;
    }else{
      if (error != null) error(res);
      return false;
    }
  }
}


