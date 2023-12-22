import 'dart:convert';

import 'package:gigachat/api/notification-class.dart';

import 'api.dart';

class Notifications {
  static Future<ApiResponse<List<NotificationObject>>> apiNotifications(String token , int page , int count) async {
    ApiResponse<List<NotificationObject>> res = await Api.apiGet(ApiPath.notifications , params: {
      "page" : "$page",
      "count" : "$count",
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    if (res.code == ApiResponse.CODE_SUCCESS){
      var data = jsonDecode(res.responseBody!)["data"];
      List<NotificationObject> list = [];
      for (var k in data["notifications"]){
        list.add(NotificationObject(
          id: k["_id"],
          description: k["description"],
          type: k["type"],
          creation_time: DateTime.tryParse(k["creation_time"])!,
          img: k["notifierProfileImage"],
        ));
      }

      res.data = list;
    }

    return res;
  }
}