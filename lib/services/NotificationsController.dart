import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gigachat/main.dart';

class NotificationsController {
  static final NotificationsController _notificationService = NotificationsController._internal();

  NotificationsController._internal();

  factory NotificationsController() {
    return _notificationService;
  }

  static NotificationsController getInstance(){
    return NotificationsController();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      macOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _foregroundNotification,
      onDidReceiveBackgroundNotificationResponse: _backgroundNotification,
    );

    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  }

  final AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    "gigachat-channel-id",   //Required for Android 8.0 or after
    "gigachat-channel",      //Required for Android 8.0 or after
    channelDescription: "this is the gigachat app notification channel",  //Required for Android 8.0 or after
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  late final NotificationDetails platformChannelSpecifics;

  void showNotification(
      int id,
      {String? title, String? body, String? payload}
      ) async {
    await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload);
  }



  @pragma("vm-entry-point")
  static void _foregroundNotification(NotificationResponse res){
    print("forground: ${res.payload} , app : $application");
  }

  @pragma("vm-entry-point")
  static void _backgroundNotification(NotificationResponse res){
    print("background: ${res.payload} , app : $application");
  }

}