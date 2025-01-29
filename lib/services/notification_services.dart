import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User granted provisional permission");
    }else{
      print("User denied permissions");
    }
  }

  void initLocalNotif(BuildContext context, RemoteMessage message) async {
      var androidInitializationSetting = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSetting =const DarwinInitializationSettings();

      var InitializationSetting = InitializationSettings(
        android: androidInitializationSetting,
        iOS: iosInitializationSetting,
      );

      await _flutterLocalNotificationsPlugin.initialize(
          InitializationSetting,
          onDidReceiveNotificationResponse: (payload){

          }
      );
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message){
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      initLocalNotif(context, message);
      ShowNotification(message);
    });
  }

  Future<void> ShowNotification(RemoteMessage message) async {

    // AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
    //     Random.secure().nextInt(1000).toString(),
    //     'high importance notification',
    //     importance: Importance.max
    // );
    //
    // AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    //     androidNotificationChannel.id.toString(),
    //     androidNotificationChannel.name.toString(),
    //     channelDescription: "your channel description",
    //     importance: Importance.high,
    //     priority: Priority.high,
    //     ticker: 'ticker'
    // );
    //
    // DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentSound: true,
    //   presentBadge: true,
    // );
    //
    // NotificationDetails notificationDetails = NotificationDetails(
    //   android: androidNotificationDetails,
    //   iOS: darwinNotificationDetails,
    // );
    //
    // Future.delayed(Duration.zero,(){
    //   _flutterLocalNotificationsPlugin.show(
    //       0,
    //       message.notification!.title.toString(),
    //       message.notification!.body.toString(),
    //       notificationDetails);
    // }
    // );
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', // Must match in AndroidManifest
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  Future<String?> getDeviceToken() async {
    return await messaging.getToken()!;
  }

  isTokenRefresh(){
    messaging.onTokenRefresh.listen((event){
      event.toString();
    });
  }
}