import 'dart:async';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/more.dart';
import 'package:litpie/Screens/BottomNavigation/notifications/notification_provider.dart';

import 'package:litpie/Screens/blockUserScreen.dart';
import 'package:litpie/Screens/hiddenUserScreen.dart';
import 'package:litpie/Screens/splashScreen.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/UploadMedia/UploadImages/uplopad_videosFirebase.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/chatBadgeController.dart';
import 'package:litpie/controller/localNotificationController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/notificationCounter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Chat/RealtimeChat/RTChatHome.dart';
import 'Home/home.dart';
import 'notifications/notifications.dart';
import 'package:easy_localization/easy_localization.dart';

import 'user/UserProfile.dart';

class BottomNav extends StatefulWidget {
  final int tabRedirectIndex;
  final int notificationTabRedirectIndex;
  final int homeTabRedirectIndex;

  const BottomNav(
      {Key key,
      this.tabRedirectIndex = 0,
      this.notificationTabRedirectIndex = 0,
      this.homeTabRedirectIndex = 0})
      : super(key: key);

  @override
  BottomNavState createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {
  FirebaseController _firebaseController = FirebaseController();

  // double _maxScreenWidth;
  int _index = 0;

  CreateAccountData currentUser;
  List<CreateAccountData> users = [];
  NotificationProvider notificationProvider;
  SharedPreferences prefs;

  void initState() {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('background message ${message.data}');
      bool soundOn = message.data["sound"] == "true" ? true : false;
      bool vibrateOn = message.data["vibrate"] == "true" ? true : false;
      print(
          "Vibrate For This Notification BG: ${message.data["vibrate"]} -> $vibrateOn");

      LocalNotification().showFcmNotification(
          title: message.data['title'],
          msg: message.data['body'],
          sound: soundOn,
          vibrate: vibrateOn,
          screen: message.data["screen"],
          data: message.data);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('background message ${message.data}');
      bool soundOn = message.data["sound"] == "true" ? true : false;
      bool vibrateOn = message.data["vibrate"] == "true" ? true : false;
      print(
          "Vibrate For This Notification BG: ${message.data["vibrate"]} -> $vibrateOn");

      LocalNotification().showFcmNotification(
          title: message.data['title'],
          msg: message.data['body'],
          sound: soundOn,
          vibrate: vibrateOn,
          screen: message.data["screen"],
          data: message.data);
    });
    _getCurrentUser();
    _index = widget.tabRedirectIndex;
    getAllNotificationData(notificationProvider);
  }

  Widget findWidget(int index) {
    if (index == 0)
      return Home(
        homeRedirectIndex: widget.homeTabRedirectIndex,
      );
    else if (index == 1)
      return UserProfile(FirebaseAuth.instance.currentUser,
          imageList: [], currentIndex: 0);
    else if (index == 2)
      return Notifications(
        currentUser: currentUser,
        tabRedirectIndex: widget.notificationTabRedirectIndex,
      );
    else if (index == 3)
      return RTChatHomeScreen(currentUser);
    else
      return More();
  }

  Future _getCurrentUser() async {
    User user = _firebaseController.firebaseAuth.currentUser;
    return _firebaseController.userColReference
        .doc(user.uid)
        .get()
        .then((data) async {
      currentUser = CreateAccountData.fromDocument(data.data());
      if (mounted) setState(() {});
      users.clear();
      // userRemoved.clear();
      loadImages();
      loadVideos();

      // configurePushNotification(currentUser);
      return currentUser;
    });
  }

  Future<UserImagesModel> loadImages() async {
    var imageList = await ImageController().getAllImages(uid: currentUser.uid);
    List<Images> image = [];
    if(imageList.length>0) {
      imageList.forEach((element) {
        Images images = Images.fromJson(element);
        image.add(images);
      });
      userImagesModel.images = image;
      if (mounted) setState(() {});
    }else{
      userImagesModel.images = image;
      if (mounted) setState(() {});
    }
    return userImagesModel;
  }

  Future<UserVideosModel> loadVideos() async {
    var list = await VideoController().getAllVideos(currentUser.uid);

    List<Videos> lis = [];
    if (list.length > 0) {
      list.forEach((element) {
        Videos video = Videos.fromJson(element);
        lis.add(video);
      });
    }
    print(lis);
    userVideosModel.videos = lis;
    // if (mounted) setState(() {});
    return userVideosModel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        //backgroundColor: mRed,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          //backgroundColor: mRed,
          //systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mRed,
          //systemOverlayStyle: SystemUiOverlayStyle(statusBarColor:Colors.orange,
          //statusBarIconBrightness:  Brightness.light )
        ),
        body: currentUser == null
            ? Center(child: Splash())
            : currentUser.isBlocked
                ? BlockUser()
                : currentUser.isHidden
                    ? HiddenUser()
                    : Container(
                        color: Theme.of(context).primaryColor,
                        width: MediaQuery.of(context).size.width,
                        child: findWidget(_index),
                      ),

        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).primaryColor,
            primaryColor: white,
          ),
          child: BottomNavigationBar(
            selectedIconTheme: IconThemeData(color: mRed, size: 35),
            unselectedIconTheme:
                IconThemeData(color: Colors.blueGrey, size: 30),
            selectedFontSize: 0,
            items: [
              BottomNavigationBarItem(
                  icon: _getHoemIcon(), label: "", tooltip: "Home".tr()),
              BottomNavigationBarItem(
                  icon: _getProfileIcon(), label: "", tooltip: "Profile".tr()),
              BottomNavigationBarItem(
                  icon: _getNotificationCounter(),
                  label: "",
                  tooltip: "Notification".tr()),
              BottomNavigationBarItem(
                  icon: _getChatCounter(), label: "", tooltip: "Chat".tr()),
              BottomNavigationBarItem(
                  icon: _getMenuIcon(), label: "", tooltip: "Menu".tr()),
            ],
            elevation: 0,
            currentIndex: _index,
            onTap: (index) {
              setState(() {
                _index = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _getHoemIcon() {
    if (_index == 0) {
      final icon = Icon((CupertinoIcons.house_fill), color: mRed, size: 30);
      return icon;
    } else {
      final icon = Icon((CupertinoIcons.home), color: lRed, size: 30);
      return icon;
    }
  }

  Widget _getProfileIcon() {
    if (_index == 1) {
      final icon = Icon(Icons.person, color: mRed, size: 37);
      return icon;
    } else {
      final icon = Icon((CupertinoIcons.person), color: lRed, size: 33);
      return icon;
    }
  }

  Widget _getMenuIcon() {
    if (_index == 4) {
      final icon = Icon(Icons.menu_rounded, color: mRed);
      return icon;
    } else {
      final icon = Icon(Icons.menu_rounded, color: lRed);
      return icon;
    }
  }

  Widget _getNotificationCounter() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (_index == 2) {
          final icon = Icon(Icons.notifications_active, color: mRed);
          return Badge(
            badgeColor: Colors.red,
            stackFit: StackFit.loose,
            showBadge:
                notificationProvider.unreadCount.length > 0 ? true : false,
            position: BadgePosition.topStart(top: -4, start: 18),
            animationType: BadgeAnimationType.fade,
            alignment: Alignment.center,
            shape: notificationProvider.unreadCount.length > 99
                ? BadgeShape.square
                : BadgeShape.circle,
            borderRadius: BorderRadius.circular(
                notificationProvider.unreadCount.length > 99 ? 12.0 : 0.0),
            child: icon,
          );
        }

        final icon = Icon((CupertinoIcons.bell), color: Colors.blueGrey);
        return Badge(
          badgeColor: mRed,
          stackFit: StackFit.loose,
          showBadge: notificationProvider.unreadCount.length > 0 ? true : false,
          position: BadgePosition.topStart(top: -4, start: 15),
          animationType: BadgeAnimationType.fade,
          alignment: Alignment.center,
          shape: notificationProvider.unreadCount.length > 99
              ? BadgeShape.square
              : BadgeShape.circle,
          borderRadius: BorderRadius.circular(
              notificationProvider.unreadCount.length > 99 ? 13.0 : 0.0),
          /*Text(
            notificationProvider.unreadCount.length.toString(),
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          )*/
          child: icon,
        );
        /*  print("_getNotificationCounter Called in Consumer...");

        if (notificationProvider.isReadNotification) {
          return Stack(
            children: <Widget>[
              //dot indicator
              icon,
              new Positioned(
                right: 3,
                child: new Container(
                  width: 13,
                  height: 13,
                  padding: EdgeInsets.all(3),
                  decoration: new BoxDecoration(
                    color: mRed,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          );
        } else {
          return icon;
        }*/
      },
    );
  }

  Widget _getChatCounter() {
    return Consumer<ChatBadgeController>(
      builder: (context, chatProvider, child) {
        if (_index == 3) {
          final icon = Icon(
            (CupertinoIcons.chat_bubble_text_fill),
            color: mRed,
          );
          return icon;
        }

        final icon = Icon(
          (CupertinoIcons.chat_bubble_text),
          color: Colors.blueGrey,
        );

        if (chatProvider.isReadNotification) {
          return NotificationCounter(
              icon: icon, counter: chatProvider.newChatCount);
        } else {
          return icon;
        }
      },
    );
  }

  getAllNotificationData(NotificationProvider notificationProvider) {
    notificationProvider.unreadCount.clear();
    notificationProvider.getUser().then((value) {
      notificationProvider.changeData(value);
    });
    notificationProvider.matchReference = notificationProvider
        .firebaseController.userColReference
        .doc(notificationProvider
            .firebaseController.firebaseAuth.currentUser.uid)
        .collection('Matches');
    notificationProvider.planReference = notificationProvider
        .firebaseController.userColReference
        .doc(notificationProvider
            .firebaseController.firebaseAuth.currentUser.uid)
        .collection('planRequest');
    notificationProvider.rReference = notificationProvider
        .firebaseController.userColReference
        .doc(notificationProvider
            .firebaseController.firebaseAuth.currentUser.uid)
        .collection('R');
    notificationProvider.notRefrenece =
        notificationProvider.firebaseController.notificationColReference;

    if (notificationProvider.rReference != null) {
      notificationProvider.rReference.doc('count').get().then((value) {
        if (value.exists) {
          notificationProvider.rReference
              .doc('count')
              .update({"new": 0, "isRead": true});
        }
      });
    }
  }

  Future<CreateAccountData> getUser() async {
    return _firebaseController.userColReference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .get()
        .then((m) {
      if (m["editInfo"] == null) {
        return null;
      }
      return CreateAccountData.fromDocument(m.data());
    });
  }
}
