import 'dart:convert';

import 'package:gigachat/api/chat-class.dart';

import 'api.dart';

class Chat {
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
        list.add(ChatObject(
          lastMessage: lastMessage["description"] ?? "Sent Media",
          lastMessageSeen: lastMessage["seen"],
          time: DateTime.tryParse(lastMessage["sendTime"]),
          lastMessageSender: lastMessage["sender"],
          nickname: member["nickname"],
          username: member["username"],
          profileImage: member["profile_image"],
          mongoID: member["id"],
          blocked: item["isBlocked"],
          followed: item["isFollowed"],
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


  Future<ApiResponse<List<ChatObject>>> apiSearchChat(String token, String keyword) async {
    ApiResponse<List<ChatObject>> res = await Api.apiGet(ApiPath.chatAll,
      headers: Api.getTokenHeader("Bearer $token"),
    );

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        var member = item["chat_members"][0];
        var lastMessage = item["lastMessage"];
        list.add(ChatObject(
          lastMessage: lastMessage["description"] ?? "Sent Media",
          lastMessageSeen: lastMessage["seen"],
          time: DateTime.tryParse(lastMessage["sendTime"]),
          lastMessageSender: lastMessage["sender"],
          nickname: member["nickname"],
          username: member["username"],
          profileImage: member["profile_image"],
          mongoID: member["id"],
          blocked: item["isBlocked"],
          followed: item["isFollowed"],
        ));
      }
      res.data = list;
      return res;
    }

    return res;
  }

}