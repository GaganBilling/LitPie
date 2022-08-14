import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/Screens/Information.dart';
import 'package:litpie/Screens/my_post/myPost.dart';
import 'package:litpie/constants.dart';

import '../main.dart';
import '../models/createAccountData.dart';

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotification() {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _onSelectNotification(var data) async {
    var dataItem=json.decode(data);
    print(dataItem['screen']);
    switch (dataItem['screen']) {
      case "PLANS":
        {
          navigateToPlanRequestandLitPieAndMatchedScreenInfo(
              dataItem['requestSendBy'], dataItem['pdataOwnerID']);
          /*navigatorKey.currentState.push(MaterialPageRoute(
              builder: (ctx) => BottomNav(
                    tabRedirectIndex: 2,
                    notificationTabRedirectIndex: 1,
                  )));*/
        }
        break;
      case "LIKE_POST":
        {
          print("opening Like Notification");
          navigatorKey.currentState
              .push(MaterialPageRoute(builder: (ctx) => MyPollScreen()));
        }
        break;
      case "COMMENT_POST":
        {
          print("opening COMMENT_POST Notification");
          navigatorKey.currentState
              .push(MaterialPageRoute(builder: (ctx) => MyPollScreen()));
        }
        break;
      case "COMMENT_LIKE":
        {
          print("opening Like Notification");
          navigatorKey.currentState
              .push(MaterialPageRoute(builder: (ctx) => MyPollScreen()));
        }
        break;
      case "MATCHES":
        {
          navigateToPlanRequestandLitPieAndMatchedScreenInfo(
            dataItem['matchedWith'],
            dataItem['currentUser'],
          );
        }
        break;
      case "chat_notification":
        {
          navigatorKey.currentState.push(MaterialPageRoute(
              builder: (ctx) => BottomNav(
                    tabRedirectIndex: 3,
                  )));
        }
        break;
      case "wave_notification":
        {
          navigatorKey.currentState.push(MaterialPageRoute(
              builder: (ctx) => BottomNav(
                    homeTabRedirectIndex: 3,
                  )));
        }
        break;
      case "LIT_PIE":
        {
          navigateToPlanRequestandLitPieAndMatchedScreenInfo(
            dataItem['litPieTo'],
            dataItem['litPieBy'],
          );
        }
        break;
    }
  }

  Future<void> navigateToPlanRequestandLitPieAndMatchedScreenInfo(
    String otherUserData,
    String currentUser,
  ) async {
    CreateAccountData _matchedUserData;
    CreateAccountData _currentUserUserData;
    var otherUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserData)
        .get();
    var currentUserUserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get();

    if (otherUser != null) {
      _matchedUserData = CreateAccountData.fromDocument(otherUser.data());
    }
    if (currentUserUserData != null) {
      _currentUserUserData =
          CreateAccountData.fromDocument(currentUserUserData.data());
    }

    if (_matchedUserData != null && _currentUserUserData != null) {
      _matchedUserData.distanceBW = Constants()
          .calculateDistance(
              currentUser: _currentUserUserData, anotherUser: _matchedUserData)
          .round();

      showDialog(
          context: navigatorKey.currentState.context,
          builder: (thisContext) {
            return Info(
              _matchedUserData,
              _currentUserUserData,
            );
          }).whenComplete(() async {});
    }
  }

  Future<void> showFcmNotification(
      {@required String title,
      @required String msg,
      @required String screen,
      @required bool sound,
      @required bool vibrate,
      @required Map<String,dynamic> data}) async {
    print("Showing Notification From Package..");
    final android = AndroidNotificationDetails(
      '${Random().nextInt(9999)}',
      'litpie notification name',

      priority: Priority.high,
      importance: Importance.high,
      playSound: sound,
      enableLights: true,
      enableVibration: vibrate,
      sound: RawResourceAndroidNotificationSound('tone'),
      // sound: RawResourceAndroidNotificationSound('litpie_tone_sound'),
    );
    final iOS = IOSNotificationDetails(
      sound: sound ? "tone.wav" : null,
      presentBadge: false,
      presentSound: sound,
    );
    final platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        Random().nextInt(9999), // notification id
        title,
        msg,
        platform,
        payload: json.encode(data));
  }
}
