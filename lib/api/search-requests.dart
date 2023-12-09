
import 'dart:convert';

import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/user-class.dart';

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

  static Future<List<User>> searchUsersByKeyword(String keyword,String token,String page,String count) async {
    ApiPath path = ApiPath.searchUsers;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "word":keyword,
          "type": "user",
          "page": page,
          "count" : count
    }
    );

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      List usersResponse = json.decode(response.responseBody!)["users"];
      print("users say $usersResponse");
      return usersResponse.map((user) {
        return User(
          id: user["username"],
          name: user["nickname"],
          isFollowed: user["isFollowedbyMe"],
          followers: user["followers_num"],
          following: user["following_num"],
          iconLink: user["profile_image"]
        );
      }).toList();
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