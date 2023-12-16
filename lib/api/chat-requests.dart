import 'dart:convert';

import 'package:gigachat/api/chat-class.dart';

import 'api.dart';

class Chat {
  static Future<ApiResponse<List<ChatObject>>> apiGetChats(String token, int page , int count) async {
    ApiResponse<List<ChatObject>> res = await Api.apiGet(ApiPath.chatAll , params: {
      "page" : "$page",
      "count" : "$count",
    },
      headers: Api.getTokenHeader(token),
    );

    if (res.code == ApiResponse.CODE_SUCCESS){
      List<ChatObject> list = [];
      var data = jsonDecode(res.responseBody!)["data"];
      for (var item in data){
        var member = item["chat_members"][0];
        var lastMessage = item["lastMessage"];
        list.add(ChatObject(
          lastMessage: lastMessage["description"],
          lastMessageSeen: lastMessage["seen"],
          time: DateTime.tryParse(lastMessage["sendTime"]),
          lastMessageSender: lastMessage["sender"],
          nickname: member["nickname"],
          username: member["username"],
          profileImage: member["profileImage"],
          mongoID: member["id"],
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
}