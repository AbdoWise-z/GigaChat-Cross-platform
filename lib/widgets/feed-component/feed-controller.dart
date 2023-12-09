import 'package:gigachat/api/search-requests.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
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
    if(newData.isNotEmpty){
      lastFetchedPage = lastFetchedPage! + 1;
      _feedCache!.addAll({...newData});
    }
  }

  void deleteTweet(String tweetID){
    if (_feedCache == null) return;
    _feedCache!.remove(tweetID);
  }

  List getCurrentData (){
    return _feedCache == null ? [] : _feedCache!.values.toList();
  }

  Future<List> fetchFeedData(
      {bool? appendToBegin,String? username,String? tweetID,String? keyword}
      ) async
  {

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
        break;
      case ProviderFunction.PROFILE_PAGE_TWEETS:
        appendToMap(
          await Tweets.getProfilePageTweets(
              token!,
              username!,
              DEFAULT_PAGE_COUNT.toString(),
              (lastFetchedPage! + 1).toString())
        );
        break;
      case ProviderFunction.GET_TWEET_COMMENTS:
        appendToMap(
            await Tweets.getTweetReplies(
                token!,
                tweetID!,
                DEFAULT_PAGE_COUNT.toString(),
                (lastFetchedPage! + 1).toString())
        );
        break;
      case ProviderFunction.SEARCH_USERS:
        List<User> usersResponse =
          await SearchRequests.searchUsersByKeyword(
            keyword!,
            token!,
            (lastFetchedPage! + 1).toString(),
            DEFAULT_PAGE_COUNT.toString()
            );
        for (User user in usersResponse){
          _feedCache!.putIfAbsent(user.id, () => user);
        }
        print(_feedCache);
        break;
      default:
        _feedCache = {};
    }

    return _feedCache!.values.toList();
  }

}