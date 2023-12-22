import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gigachat/firebase_options.dart';
import 'package:gigachat/main.dart';
import 'package:gigachat/providers/auth.dart';

class TriggerNotification{
  final Map<String,dynamic> payload;
  final String? actionID;
  final String? input;

  TriggerNotification({required this.payload, required this.actionID, required this.input});

  static TriggerNotification fromFirebase(RemoteMessage msg){
    return TriggerNotification(payload: msg.data, actionID: 'firebase', input: null);
  }

  static TriggerNotification fromLocal(NotificationResponse res){
    return TriggerNotification(payload: res.payload == null || res.payload!.isEmpty ? {} : jsonDecode(res.payload!), actionID: res.actionId, input: res.input);
  }
}

class NotificationsController {

  static final NotificationsController _notificationService = NotificationsController._internal();
  NotificationsController._internal();

  factory NotificationsController() {
    return _notificationService;
  }

  static NotificationsController getInstance(){
    return NotificationsController();
  }

  static void _dispatchNotification(TriggerNotification note){
    NavigatorState? state = appNavigator.currentState;
    if (state != null){
      if (Auth().getCurrentUser() == null){
        return; //not logged in
      }
      doDispatchNotification(note, state.context);
    }
  }

  static void doDispatchNotification(TriggerNotification note , BuildContext context){
    //TODO: trigger the navigator to the right page
    //TODO: waiting for the backend to see their format ..
  }

  static Future<TriggerNotification?> getLaunchNotification() async {
    RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null){
      return TriggerNotification.fromFirebase(msg);
    }
    NotificationAppLaunchDetails? l = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (l != null && l.didNotificationLaunchApp){
      return TriggerNotification.fromLocal(l.notificationResponse!);
    }

    return null;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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

    //Initialize the firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    final token = await firebaseMessaging.getToken();
    print("Firebase Token : $token");

    //this will handle the messages when the app is background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("firebase: ${event.data} , app : $application");
      TriggerNotification note = TriggerNotification(payload: event.data, actionID: 'firebase', input: null);
      _dispatchNotification(note);
    });

    //this will handle them when the app is in foreground
    FirebaseMessaging.onMessage.listen((event) {
      print("Firebase Message : ${event.notification}");
      final RemoteNotification? note = event.notification;
      if (note == null) return;
      showNotification(-1 , title: note.title , body: note.body , payload: jsonEncode(event.data));
    });

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
    TriggerNotification note = TriggerNotification(payload: res.payload == null || res.payload!.isEmpty ? {} : jsonDecode(res.payload!), actionID: res.actionId, input: res.input);
    _dispatchNotification(note);
  }

  @pragma("vm-entry-point")
  static void _backgroundNotification(NotificationResponse res){
    print("background: ${res.payload} , app : $application");
    //nothing to do here
    //AppTriggerNotification = TriggerNotification(payload: res.payload == null || res.payload!.isEmpty ? {} : jsonDecode(res.payload!), actionID: res.actionId, input: res.input);
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessage(RemoteMessage message) async {
    print("background message : $message");
    // firebase should already create the notification ..
    // await NotificationsController().init();
    // RemoteNotification note = message.notification!;
    // NotificationsController().showNotification(-1 , title: note.title , body: note.body , payload: jsonEncode(message.data));
  }

}