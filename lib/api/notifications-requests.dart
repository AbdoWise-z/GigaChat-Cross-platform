import 'dart:convert';
import 'package:gigachat/api/notification-class.dart';
import 'api.dart';


/// this class will contain all of the API functionality related to Notifications
class Notifications {

  /// get a list of notifications for a user associated with [token]
  /// [page] and [count] are used for result range selecting
  /// return a [List] of [NotificationObject] if request was successful
  /// otherwise null
  static Future<ApiResponse<List<NotificationObject>>> apiGetNotifications(String token , int page , int count) async {
    ApiResponse<List<NotificationObject>> res = await Api.apiGet(ApiPath.notifications , params: {
      "page" : "$page",
      "count" : "$count",
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    print(res.responseBody);

    if (res.code == ApiResponse.CODE_SUCCESS){
      var data = jsonDecode(res.responseBody!)["data"];
      List<NotificationObject> list = [];
      for (var k in data["notifications"]){
        list.add(NotificationObject(
          id: k["_id"],
          description: k["description"],
          type: k["type"],
          creationTime: DateTime.tryParse(k["creation_time"])!,
          img: k["notifierProfileImage"] ?? "",
          seen: k["seen"],
          targetID: k["destination"] ?? "no target",
        ));
      }

      res.data = list;
    }

    return res;
  }

  /// gets the unseen count of notifications for a user associated with [token]
  /// return [int] if request was successful
  /// otherwise null
  static Future<ApiResponse<int>> apiGetUnseenCount(String token) async {
    ApiResponse<int> res = await Api.apiGet(ApiPath.notificationsCount , params: {
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );

    if (res.code == ApiResponse.CODE_SUCCESS){
      var data = jsonDecode(res.responseBody!)["data"];
      res.data = data["notificationsCount"];
    }

    return res;
  }

  /// marks all notifications as seen for the user associated with [token]
  /// doesn't return a result
  static Future<ApiResponse<void>> apiMarkAll(String token) async {
    ApiResponse<void> res = await Api.apiPost(ApiPath.notificationsMarkALl , params: {
    },
      headers: Api.getTokenHeader("Bearer $token"),
    );
    return res;
  }


}