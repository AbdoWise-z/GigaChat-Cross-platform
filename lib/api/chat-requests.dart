import 'dart:convert';
import 'package:gigachat/api/chat-class.dart';
import 'api.dart';

/// this class contains all chat-related API requests
class Chat {

  /// returns the current active chats for the user associated with [token]
  /// [page] and [count] are used for selecting the return range
  /// return a [list] of [ChatObject] if the request was successful
  /// or null if failed
  static Future<ApiResponse<List<ChatObject>>> apiGetChats(String token, int page , int count) async {
    ApiResponse<List<ChatObject>> res = await Api.apiGet(ApiPath.chatAll , params: {
      "page" : "$page",
      "count" : "$count",
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    //print("res.body: ${res.responseBody}");

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        var member = item["chat_members"][0];
        var lastMessage = item["lastMessage"];
        var lM = ChatMessageObject();
        lM.fromDirectMap(lastMessage);
        list.add(ChatObject(
          time: DateTime.tryParse(lastMessage["sendTime"]),
          nickname: member["nickname"],
          username: member["username"],
          profileImage: member["profile_image"],
          mongoID: member["id"],
          blocked: item["isBlocked"],
          followed: item["isFollowed"],
          isFollowingMe: item["isFollowingMe"],
          lastMessage: lM,
        ));
      }
      res.data = list;
      return res;
    }

    if (res.code == ApiResponse.CODE_NOT_FOUND){
      res.data = [];
      return res;
    }

    return res;
  }

  /// loads message of the chat with id [id] for user associated with [token]
  /// [page] and [count] are used for selecting the return range
  /// return a [list] of [ChatMessageObject] if the request was successful
  /// or null if failed
  static Future<ApiResponse<List<ChatMessageObject>>> apiGetChatMessages(String token, String id, int page , int count) async {
    ApiResponse<List<ChatMessageObject>> res = await Api.apiGet(ApiPath.chatMessages.format([id]) , params: {
      "page" : "$page",
      "count" : "$count",
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    //print("res.body: ${res.responseBody}");

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatMessageObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        ChatMessageObject obj = ChatMessageObject();
        obj.fromDirectMap(item);
        list.add(obj);
      }

      res.data = list;
      return res;
    }

    return res;
  }

  /// loads message of the chat with id [id] for user associated with [token] before certain [time]
  /// [page] and [count] are used for selecting the return range
  /// return a [list] of [ChatMessageObject] if the request was successful
  /// or null if failed
  static Future<ApiResponse<List<ChatMessageObject>>> apiGetChatMessagesBefore(String token, String id, int page , int count, DateTime time) async {
    ApiResponse<List<ChatMessageObject>> res = await Api.apiGet(ApiPath.chatMessagesBefore.format([id]) , params: {
      "page" : "$page",
      "count" : "$count",
      "time" : time.toIso8601String(),
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    //print("res.body: ${res.responseBody}");

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatMessageObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        ChatMessageObject obj = ChatMessageObject();
        obj.fromDirectMap(item);
        list.add(obj);
      }

      res.data = list;
      return res;
    }

    return res;
  }

  /// loads message of the chat with id [id] for user associated with [token] after certain [time]
  /// [page] and [count] are used for selecting the return range
  /// return a [list] of [ChatMessageObject] if the request was successful
  /// or null if failed
  static Future<ApiResponse<List<ChatMessageObject>>> apiGetChatMessagesAfter(String token, String id, int page , int count, DateTime time) async {
    ApiResponse<List<ChatMessageObject>> res = await Api.apiGet(ApiPath.chatMessagesAfter.format([id]) , params: {
      "page" : "$page",
      "count" : "$count",
      "time" : time.toIso8601String(),
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    //print("res.body: ${res.responseBody}");

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatMessageObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        ChatMessageObject obj = ChatMessageObject();
        obj.fromDirectMap(item);
        list.add(obj);
      }

      res.data = list;
      return res;
    }

    return res;
  }


  /// search all of the user's associated with [token] chats using keyword [keyword]
  /// return a [list] of [ChatObject] if the request was successful
  /// or null if failed
  static Future<ApiResponse<List<ChatObject>>> apiSearchChat(String token, String keyword) async {
    ApiResponse<List<ChatObject>> res = await Api.apiGet(ApiPath.chatSearch,
      params: {
        "word" : keyword,
      },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        var member = item["chat_members"][0];
        var lastMessage = item["lastMessage"];
        var lM = ChatMessageObject();
        lM.fromDirectMap(lastMessage);
        list.add(ChatObject(
          time: DateTime.tryParse(lastMessage["sendTime"]),
          nickname: member["nickname"],
          username: member["username"],
          profileImage: member["profile_image"],
          mongoID: member["id"],
          blocked: item["isBlocked"],
          followed: item["isFollowed"],
          isFollowingMe: item["isFollowingMe"],
          lastMessage: lM,
        ));
      }
      res.data = list;
      return res;
    }

    return res;
  }

}