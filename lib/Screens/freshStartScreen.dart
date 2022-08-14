import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Registration/login.dart';
import 'package:litpie/Screens/BottomNavigation/notifications/notification_provider.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/unfriendModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class FreshStartScreen extends StatefulWidget {
  final String currentUserUID;

  const FreshStartScreen({Key key, @required this.currentUserUID})
      : super(key: key);

  @override
  _FreshStartScreenState createState() => _FreshStartScreenState();
}

//double _maxScreenWidth;

class _FreshStartScreenState extends State<FreshStartScreen> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  FirebaseController _firebaseController = FirebaseController();
  NotificationProvider notificationProvider;

  FirebaseDatabase db = FirebaseDatabase();
  DatabaseReference chatRef;

  bool isLoading = false;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    chatRef = db.reference().child("chats");
    super.initState();
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: mRed,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: !isLoading,
        ),
        body: isLoading
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please Wait. This may take a While. Don't refresh or leave this App."
                            .tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: _screenWidth >= miniScreenWidth ? 25 : 20,
                            fontFamily: "Handlee"),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      LinearProgressCustomBar(),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                            child: Image.asset(
                          "assets/images/practicelogo.png",
                          height: 100,
                        )),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "This will remove all the previous history related to Swipes, Matches, Plans, Messages and  Notifications, if any and to do this you need 200 LitPie's in your Collection and then you have to Login again with your current Email and Password or Phone Number. This action cannot be undone."
                                .tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.w700,
                                color: lRed,
                                decoration: TextDecoration.none,
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 24 : 20),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Tooltip(
                            message: "I Want to Start Fresh".tr(),
                            preferBelow: false,
                            child: SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                                child: ElevatedButton(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Text(
                                          "Yes, I Want to Start Fresh".tr(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 22
                                                  : 18,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    onPressed: () async {
                                      freshStartUser(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: mRed,
                                        onPrimary: mYellow,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.7)))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  freshStartUser(context) async {
    DocumentSnapshot docCurrent = await _reference
        .doc(widget.currentUserUID)
        .collection('R')
        .doc('count')
        .get();
    print(docCurrent.data());
    print(notificationProvider.likesNotificationList);
    print(notificationProvider.matchesNotificationList);
    print(notificationProvider.planRequestNotificationList);
    print(notificationProvider.commentsNotificationList);

    print(notificationProvider.likesNotificationList);
    Map<String, dynamic> roseData = docCurrent.data();
    // deleteAllCurrentUserNotifications();
    if (roseData['roseColl'] != null && roseData['roseColl'] >= 200) {
      freshStartConfirmDialog(context);
    } else {
      noRoseDialog(context);
    }
  }

  Future noRoseDialog(context) async {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.blueGrey.withOpacity(0.8),
            children: [
              Text(
                  "OOPS!!! You need 200 LitPie's to start fresh in your collection. Please go to your profile and collect it now"
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      color: white,
                      decoration: TextDecoration.none,
                      fontSize: _screenWidth >= miniScreenWidth ? 22 : 19)),
              SizedBox(
                height: 10,
              ),
              Tooltip(
                message: "Go Now".tr(),
                preferBelow: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 10.0),
                  child: ElevatedButton(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Text("Go Now".tr(),
                          maxLines: 1,
                          style: TextStyle(
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 22 : 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RoseCollec()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: mRed,
                      onPrimary: white,
                      elevation: 3,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 35.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void freshStartConfirmDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode
            ? black.withOpacity(.5)
            : white.withOpacity(.5),
        content: Container(
          // height: MediaQuery.of(context).size.height / 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are You Sure?".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 30, right: 30),
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = true;
                    });
                    await inputData().then((value) async {
                      if (value) {
                        print("Success");
                        Fluttertoast.showToast(
                            msg: "Success".tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.blueGrey,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        await _firebaseController.userColReference
                            .doc(_firebaseController.currentFirebaseUser.uid)
                            .update({"isOnline": false}).then((_) async {
                          await _firebaseController.firebaseAuth
                              .signOut()
                              .then((value) {
                            //_firebaseMessaging.deleteInstanceID();
                            Navigator.pushReplacement(
                                scaffoldKey.currentContext,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          });
                          // _ads.disable(_ad);;
                        });
                      }
                    });
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Text(
                      "YES".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: mRed,
                    onPrimary: white,
                    // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.7)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 30, right: 30),
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Text(
                      "NO".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: themeProvider.isDarkMode ? mBlack : white,
                    onPrimary: Colors.blue[700],
                    //  padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.7)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> inputData() async {
    deleteAllCurrentUserNotifications();
    await _reference
        .doc(widget.currentUserUID)
        .collection(checkedUserCollectionName)
        .get()
        .then((checkedUserDocs) {
      checkedUserDocs.docs.forEach((element) {
        element.reference.delete();
      });
    });

    //Delete LikedBy
    await _reference
        .doc(widget.currentUserUID)
        .collection(likedByCollectionName)
        .get()
        .then((likedByDocs) {
      likedByDocs.docs.forEach((element) {
        element.reference.delete();
      });
    });

    //Delete Matches
    await _reference
        .doc(widget.currentUserUID)
        .collection(matchesCollectionName)
        .get()
        .then((matchesDocs) {
      matchesDocs.docs.forEach((ourMatches) {
        _reference
            .doc(ourMatches.id)
            .collection(matchesCollectionName)
            .where("Matches", isEqualTo: widget.currentUserUID)
            .get()
            .then((value) {
          value.docs.forEach((anotherMatches) {
            anotherMatches.reference.delete();
          });
        });
        ourMatches.reference.delete();
      });
    });

    //Delete Plan Request (from both users collection)
    await _reference
        .doc(widget.currentUserUID)
        .collection(planRequestCollectionName)
        .get()
        .then((ourPlanRequestsDocs) {
      ourPlanRequestsDocs.docs.forEach((ourRequest) {
        if (ourRequest.data()["request"] == "sent") {
          _reference
              .doc(ourRequest.data()["planRequest"])
              .collection(planRequestCollectionName)
              .where("planRequest", isEqualTo: widget.currentUserUID)
              .get()
              .then((otherPlanRequests) {
            otherPlanRequests.docs.forEach((otherRequest) {
              otherRequest.reference.delete();
            });
          });
        }
        ourRequest.reference.delete();
      });
    });

    //Delete Plan
    await _reference
        .doc(widget.currentUserUID)
        .collection(plansCollectionName)
        .get()
        .then((plans) {
      plans.docs.forEach((element) {
        element.reference.delete();
      });
    });

    //Reset ChatCount
    await _reference
        .doc(widget.currentUserUID)
        .collection(chatCountCollectionName)
        .doc("count")
        .update({
      "isRead": true,
      "new": 0,
    });

    //Delete R Request
    await _reference
        .doc(widget.currentUserUID)
        .collection(rCollectionName)
        .get()
        .then((rDocs) {
      rDocs.docs.forEach((rData) {
        if (rData.id == "count") {
          rData.reference.update({
            "isRead": true,
            "new": 0,
            "roseColl": FieldValue.increment(-200),
          });
        } else {
          rData.reference.delete();
        }
      });
    });

    //Delete Chats With Unfriend
    await chatRef.once().then((chats) async {
      List allChatIds;
      if (chats.snapshot.exists) {
        chats.snapshot.children.forEach((element) {
          allChatIds.add(element.key);
        });
        //  final = chats.snapshot.value.keys.toList();
        for (int i = 0; i < allChatIds.length; i++) {
          List userIds = allChatIds[i].toString().split("-");
          String currentUser, anotherUser;
          if (userIds[0] == widget.currentUserUID) {
            currentUser = userIds[0];
            anotherUser = userIds[1];
            await chatRef.child(allChatIds[i].toString()).remove();
            //Unfriend
            Map<String, dynamic> unFriendMap = UnFriendModel(
                    unFriendBy: currentUser,
                    unFriendTo: anotherUser,
                    createdAt: Timestamp.now())
                .toJson();
            //Add To new collection in user's Collection
            _reference
                .doc(currentUser)
                .collection(unFriendCollectionName)
                .add(unFriendMap);
            _reference
                .doc(anotherUser)
                .collection(unFriendCollectionName)
                .add(unFriendMap);
          } else if (userIds[1] == widget.currentUserUID) {
            currentUser = userIds[1];
            anotherUser = userIds[0];
            await chatRef.child(allChatIds[i].toString()).remove();
            //Unfriend
            Map<String, dynamic> unFriendMap = UnFriendModel(
                    unFriendBy: currentUser,
                    unFriendTo: anotherUser,
                    createdAt: Timestamp.now())
                .toJson();
            //Add To new collection in user's Collection
            _reference
                .doc(currentUser)
                .collection(unFriendCollectionName)
                .add(unFriendMap);
            _reference
                .doc(anotherUser)
                .collection(unFriendCollectionName)
                .add(unFriendMap);
          }
        }
      }
    });

    return true;
  }

  Future deleteAllCurrentUserNotifications() async {
    var allData = [];
    var notificationsList = [];
    if (notificationProvider.commentsNotificationList.length > 0) {
      allData.addAll(notificationProvider.commentsNotificationList);
    }
    if (notificationProvider.likesNotificationList.length > 0) {
      allData.addAll(notificationProvider.likesNotificationList);
    }
    if (notificationProvider.matchesNotificationList.length > 0) {
      allData.addAll(notificationProvider.matchesNotificationList);
    }
    if (notificationProvider.planRequestNotificationList.length > 0) {
      allData.addAll(notificationProvider.planRequestNotificationList);
    }
    if (notificationProvider.litpieNotificationList.length > 0) {
      allData.addAll(notificationProvider.litpieNotificationList);
    }
    if (allData.length > 0) {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          for (var doc in value.docs) {
            var refernceData = doc.data();
            if (allData.length > 0) {
              for (var data in allData) {
                if (data['_id'] == refernceData['_id']) {
                  doc.reference.delete();
                }
              }
            }
          }
        }
      });
    }
  }
}
