
import 'package:gigachat/api/api.dart';

class SearchRequests{
  static Future<List<String>> searchTagsByKeyword(String keyword,String token) async {

    return ["wow","wo are you","wo is whom"];

    ApiPath path = ApiPath.searchTags;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers, params: {"name":keyword});
    if (response.code == ApiResponse.CODE_SUCCESS){
      //TODO: decode the response body
      return [];
    }
    else
    {
      return [];
    }
  }

  static Future<List<String>> searchUsersByKeyword(String keyword,String token) async {
    ApiPath path = ApiPath.searchUsers;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers, params: {"name":keyword});
    if (response.code == ApiResponse.CODE_SUCCESS){
      //TODO: decode the response body
      return [];
    }
    else
    {
      return [];
    }
  }

  static Future<List<String>> searchTweetsByKeyword(String keyword,String token) async {
    ApiPath path = ApiPath.searchTweets.format([keyword]);
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers);
    if (response.code == ApiResponse.CODE_SUCCESS){
      //TODO: decode the response body
      return [];
    }
    else
    {
      return [];
    }
  }
}