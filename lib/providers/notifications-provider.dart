
import 'package:flutter/cupertino.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/api/notifications-requests.dart';

class NotificationsProvider extends ChangeNotifier{
  static NotificationsProvider? _instance;

  NotificationsProvider._internal();

  factory NotificationsProvider(){
    _instance ??= NotificationsProvider._internal();
    return _instance!;
  }

  final List<NotificationObject> _notifications = [];
  int page = 1;
  int count = 25;
  int offset = 0;

  Future<List<NotificationObject>> reloadAll(String token) async {
    _notifications.clear();
    page = 1;
    return await getAllNotifications(token);
  }

  Future<List<NotificationObject>> getAllNotifications(String token) async {
    if (_notifications.isEmpty){
      await getNotifications(token);
    }
    return _notifications;
  }


  Future<List<NotificationObject>> getNotifications(String token) async {
    var k = await Notifications.apiNotifications(token, page, count);
    if (k.data == null){
      return [];
    }
    _notifications.addAll(k.data!);
    page++;
    return k.data!;
  }


}