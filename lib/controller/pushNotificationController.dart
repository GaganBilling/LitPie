import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:litpie/controller/localNotificationController.dart';

class PushNotificationController {
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  NotificationSettings setting;
  LocalNotification _localNotificationController;

  void fcmInitialization({GlobalKey<NavigatorState> navigatorKey}) async {
    _localNotificationController =
        LocalNotification();
    if (Platform.isIOS) requestNotificationPermission();

    await fcm.getToken().then((value) {
      print("FCM TOKEN: $value");
    }).catchError((e) {
      print("GET TOKEN ERROR: $e");
    });

    /// For iOS only, setting values to show the notification when the app is in foreground state.
    await fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['screen'] != "notifications") {
        bool soundOn = message.data["sound"] == "true" ? true : false;
        bool vibrateOn = message.data["vibrate"] == "true" ? true : false;
      }
    }).onError((e) {
      print("OnMessage Error: $e");
    });

    //On Foreground FCM
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {

    });

    //OnClickNotification FCM
    FirebaseMessaging.onMessageOpenedApp.listen((message) {

    });
  }

  Future<void> messageHandler(RemoteMessage message) async {}

  void fcmSubscribe() {
    fcm.subscribeToTopic('all');
  }

  void fcmUnSubscribe() {
    fcm.unsubscribeFromTopic('all');
  }

  void requestNotificationPermission() async {
    setting = await fcm.requestPermission(
        badge: true, sound: true, alert: true, provisional: true);
    print('User granted permission: ${setting.authorizationStatus}');
  }
}
