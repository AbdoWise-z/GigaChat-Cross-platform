import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/firebase_options.dart';
import 'package:gigachat/main.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/services/notifications-navigation-pages/post-notification-navigation.dart';
import 'package:gigachat/services/notifications-navigation-pages/profile-notification-navigation.dart';

class TriggerNotification{
  final Map<String,dynamic> payload;
  final String? actionID;
  final String? input;
  final String id;

  TriggerNotification(this.id, {required this.payload, required this.actionID, required this.input});

  static TriggerNotification fromFirebase(RemoteMessage msg){
    var data = msg.data["notification"];
    if (data.runtimeType == String){ //fk firebase ig
      data = jsonDecode(data);
    }
    return TriggerNotification(msg.messageId ?? "no-id", payload: data, actionID: 'firebase', input: null);
  }

  static TriggerNotification fromLocal(NotificationResponse res){
    var payload = res.payload;
    Map<String,dynamic> map = {};
    if (payload != null && payload.isNotEmpty){
      try {
        map = jsonDecode(payload);
      } catch (e){
        print("can't decode : $e");
      }
    }
    return TriggerNotification(map["_id"], payload: map, actionID: res.actionId, input: res.input);
  }

  static TriggerNotification fromNotificationsList(NotificationObject note){
    return TriggerNotification(note.id , payload: {
      "_id" : note.id,
      "destination" : note.targetID,
      "type" : note.type,
    }, actionID: "local", input: null);
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

  static void _DoDispatchNotificationFollow(String target) async {
    if (appNavigator.currentState != null){
      appNavigator.currentState!.push(MaterialPageRoute(builder: (context) => ProfileNotificationNavigation(target: target,)));
    }
  }

  static void _DoDispatchNotificationLike(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationReply(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationQuote(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationRetweet(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationMention(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchTypePost(String target) async {
    if (appNavigator.currentState != null){
      appNavigator.currentState!.push(MaterialPageRoute(builder: (context) => PostNotificationNavigation(target: target,)));
    }else{
      print("app navigator was null");
    }
  }

  static void _DoDispatchNotification(TriggerNotification note) {
    NavigatorState? state = appNavigator.currentState;

    //print("Dispatching Note: ${note.payload}" );
    if (note.actionID != 'local') {
      LocalSettings.instance.setValue<String>(
          name: "last_note_id", val: note.id);
      LocalSettings.instance.apply();
    }


    if (state != null){
      if (Auth().getCurrentUser() == null){
        return; //not logged in
      }
      // trigger the notification
      switch (note.payload["type"]){
        case "follow" :
          _DoDispatchNotificationFollow(note.payload["destination"]);
          break;
        case "like"   :
          _DoDispatchNotificationLike(note.payload["destination"]);
          break;
        case "reply"  :
          _DoDispatchNotificationReply(note.payload["destination"]);
          break;
        case "quote"  :
          _DoDispatchNotificationQuote(note.payload["destination"]);
          break;
        case "retweet":
          _DoDispatchNotificationRetweet(note.payload["destination"]);
          break;
        case "mention":
          _DoDispatchNotificationMention(note.payload["destination"]);
          break;
      }
    } else {
      print("State was null");
    }
  }

  static void dispatchNotification(TriggerNotification note , BuildContext context){
    _DoDispatchNotification(note);
  }

  static Future<TriggerNotification?> getLaunchNotification() async {
    RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null){
      TriggerNotification note = TriggerNotification.fromFirebase(msg);
      String? id = LocalSettings.instance.getValue<String>(name: "last_note_id", def: null);
      if (id != note.id){
        return note;
      }
    }

    NotificationAppLaunchDetails? l = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (l != null && l.didNotificationLaunchApp){
      TriggerNotification note = TriggerNotification.fromLocal(l.notificationResponse!);
      String? id = LocalSettings.instance.getValue<String>(name: "last_note_id", def: null);
      if (id == null || id != note.id){ //because this stupid thing doesn't return null
        return note;
      }
    }
    return null;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? FirebaseToken;
  static int _counter = 1;
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
    FirebaseToken = await firebaseMessaging.getToken();
    print("Firebase Token : $FirebaseToken");

    //this will handle the messages when the app is background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("firebase: ${event.data} , app : $application");
      TriggerNotification note = TriggerNotification.fromFirebase(event);
      _DoDispatchNotification(note);
    });

    //this will handle them when the app is in foreground
    FirebaseMessaging.onMessage.listen((event) {
      print("Firebase Message : ${event.notification}");
      final RemoteNotification? note = event.notification;
      if (note == null) return;
      showNotification(_counter++ , title: note.title , body: note.body , payload: event.data["notification"]);
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
    TriggerNotification note = TriggerNotification.fromLocal(res);
    _DoDispatchNotification(note);
  }

  @pragma("vm-entry-point")
  static void _backgroundNotification(NotificationResponse res){
    print("background: ${res.payload} , app : $application");
    //this runs on the background without the app
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