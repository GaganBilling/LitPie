import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/Home/planPage.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/controller/mobileAdsController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:easy_localization/easy_localization.dart';

class ExplorePlans extends StatefulWidget {
  final PageController pageController;

  const ExplorePlans({Key key, @required this.pageController})
      : super(key: key);

  @override
  _ExplorePlans createState() => _ExplorePlans();
}

class _ExplorePlans extends State<ExplorePlans>
    with AutomaticKeepAliveClientMixin {
  CreateAccountData currentUser;

  CollectionReference planRef = FirebaseFirestore.instance.collection('Plans');

  // CollectionReference docRef = FirebaseFirestore.instance.collection('Notifications');
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;

  // double _maxScreenWidth;
  bool requestSent = false;

  bool isLoading = false;
  bool hasMore = true;
  List<String> deviceToken = [];

  List<CreateAccountData> tempPlansUsers = [];
  List<QueryDocumentSnapshot> tempPlansDocs = [];
  FirebaseController _firebaseController = FirebaseController();

  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  GlobalKey<State<Tooltip>> toolTipKeyProgressBar = GlobalKey<State<Tooltip>>();

  List<Object> allUsersRows = [];
  List<Object> allPlansRows = [];
  List planData = [];
  MobileAdsController _mobileAdsController = MobileAdsController();

  Future<CreateAccountData> getUser() async {
    currentUser = await _firebaseController.currentUserData;
    return currentUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  double durationPercentage;

  // double getDurationPercentage(Timestamp startDate, Timestamp endDate) {
  //   DateTime start = startDate.toDate();
  //   DateTime end = endDate.toDate();
  //   int totalDiff = end.difference(start).inSeconds;
  //   int currentDiff = DateTime.now().difference(end).inSeconds.abs();
  //   double percentage = 1.0 - (currentDiff / totalDiff);
  //   print(percentage);
  //   // print(end.difference(DateTime.now()).inSeconds);
  //   if (end.difference(DateTime.now()).inSeconds <= 0) {
  //     return 1.0;
  //   }
  //   return percentage.abs() > 9.99 ? 1.0 : percentage;
  // }

  @override
  //Ads _ads = new Ads();
  void initState() {
    super.initState();

    getUser().then((value) async {
      if (!mounted) return;
      setState(() {
        currentUser = value;
        if (currentUser != null) {
          getAllPlans();
        }
      });
      // plansDocs = [];
      // plansUsers = [];
      // loadExplorePlans();
    });
  }

  Stream<DocumentSnapshot> planRequestStream(
      {@required CreateAccountData anotherUser}) {
    return planRef
        .doc(currentUser.uid)
        .collection('planRequest')
        .doc(anotherUser.uid)
        .snapshots();
  }

  Query loadExplorePlansQuery() {
    if (currentUser.showGender == 'everyone') {
      return userRef
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max'])
          .orderBy('age', descending: false);
    } else {
      return userRef
          .where('editInfo.userGender', isEqualTo: currentUser.showGender)
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max'])
          .orderBy('age', descending: false);
    }
  }

/*  Future<void> loadExplorePlans() async {
    if (!hasMore) {
      print("No More Explore Plans");
      return;
    }
    if (isLoading) return;
    setState(() {
      isLoading = true;
      // plansLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (plansLastDocument == null) {
      // plansUsers = [];
      // plansDocs = [];
      querySnapshot = await loadExplorePlansQuery().get();
      if(querySnapshot!=null){
        querySnapshot= await _firebaseController.notificationColReference.limit(plansLimit).where("type",isEqualTo: "plans") .get();
      }*/ /*.limit(plansLimit).get();*/ /*
    } */ /*else {
      querySnapshot = await _firebaseController.notificationColReference.limit(plansLimit).where("type",isEqualTo: "plans") .get();
      // querySnapshot = await loadExplorePlansQuery().limit(plansLimit).startAfterDocument(plansLastDocument).get();
    }*/ /*
    if (querySnapshot.docs.length < plansLimit) {
      hasMore = false;
    }

    if (querySnapshot.docs.length <= 0) {
      print("No Plan Found");
      if (plansLastDocument == null) {
        plansDocs = [];
        plansUsers = [];
      }
    } else {
      plansLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    await filterPlansUsers(querySnapshot: querySnapshot);

    print("plansDocs: $plansDocs");

    if (plansDocs.length < plansLimit) {
      isLoading = false;
      loadExplorePlans();
    }

    print("Explore Plans Length : ${plansUsers.length}");
    setState(() {
      isLoading = false;
      plansLoading = false;
    });
  }*/

/*  Future<void> loadExplorePlans() async {
    if (!hasMore) {
      print("No More Explore Plans");
      return;
    }
    if (isLoading) return;
    setState(() {
      isLoading = true;
      // plansLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (plansLastDocument == null) {
      // plansUsers = [];
      // plansDocs = [];
      querySnapshot = await loadExplorePlansQuery().get();
      if (querySnapshot != null) {
        querySnapshot = await _firebaseController.notificationColReference.limit(plansLimit).where("type", isEqualTo: "plans").get();
      } */ /*.limit(plansLimit).get();*/ /*
    }
    */ /*else {
      querySnapshot = await _firebaseController.notificationColReference.limit(plansLimit).where("type",isEqualTo: "plans") .get();
      // querySnapshot = await loadExplorePlansQuery().limit(plansLimit).startAfterDocument(plansLastDocument).get();
    }*/ /*
    if (querySnapshot.docs.length < plansLimit) {
      hasMore = false;
    }

    if (querySnapshot.docs.length <= 0) {
      print("No Plan Found");
      if (plansLastDocument == null) {
        plansDocs = [];
        plansUsers = [];
      }
    } else {
      plansLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    await filterPlansUsers(querySnapshot: querySnapshot);

    print("plansDocs: $plansDocs");

    if (plansDocs.length < plansLimit) {
      isLoading = false;
      loadExplorePlans();
    }

    print("Explore Plans Length : ${plansUsers.length}");
    setState(() {
      isLoading = false;
      plansLoading = false;
    });
  }*/

  Future<bool> filterPlansUsers({@required QuerySnapshot querySnapshot}) async {
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        QuerySnapshot querySnap;
        querySnap = await querySnapshot.docs[i].reference
            .collection('plans')
            .where('pTimeStamp', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('pTimeStamp', descending: true)
            .get();

        if (querySnap.docs.length != 0) {
          // print("Plans Collection : ${querySnap.docs}");
          //  print("new value print : ${querySnap.docs[0].data()["pTimeStamp"]}");

          CreateAccountData temp =
              CreateAccountData.fromDocument(querySnapshot.docs[i].data());
          var distance = Constants()
              .calculateDistance(currentUser: currentUser, anotherUser: temp);
          temp.distanceBW = distance.round();
          if (distance <= currentUser.maxDistance &&
              temp.uid != currentUser.uid &&
              !temp.isBlocked &&
              !temp.isHidden &&
              !temp.isDeleted &&
              await BlockUserController().blockedExistOrNot(
                      currentUserId: currentUser.uid,
                      anotherUserId: temp.uid) ==
                  null) {
            if (i % 5 == 0 && i != 0) {
              allUsersRows
                  .add(_mobileAdsController.loadMediumBannerAd()..load());
              allPlansRows.add("plan-doc-space");
            }
            allUsersRows.add(temp);
            tempPlansUsers.add(temp); //user detail
            tempPlansDocs.add(querySnap.docs[0]); //only one plan
            allPlansRows.add(querySnap.docs[0]); //only one plan
          } else {
            print("Distance Not Match");
          }
        } else {
          print("Post Not Found!");
        }
      }

      if (i == querySnapshot.docs.length - 1) {
        if (plansLastDocument == null) {
          plansDocs = [];
          plansUsers = [];
        }
        plansDocs.addAll(allPlansRows);
        plansUsers.addAll(allUsersRows);
        tempPlansUsers.clear();
        tempPlansDocs.clear();
        allUsersRows.clear();
        allPlansRows.clear();
      }
    }
    return true;
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: themeProvider.isDarkMode ? dRed : white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: themeProvider.isDarkMode ? dRed : white,
        ),
        child: ClipRRect(
          child: Stack(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? dRed : white,
                  ),
                  height: _screenWidth >= miniScreenWidth
                      ? MediaQuery.of(context).size.height * .80
                      : MediaQuery.of(context).size.height * .70,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      SizedBox(
                          height: _screenWidth >= miniScreenWidth
                              ? MediaQuery.of(context).size.height * .80
                              : MediaQuery.of(context).size.height * .70,
                          child: plansLoading
                              ? Align(
                                  alignment: Alignment.center,
                                  child: LinearProgressCustomBar(),
                                )
                              : (planData.length > 0
                                  ? SizedBox(
                                      height: _screenWidth >= miniScreenWidth
                                          ? MediaQuery.of(context).size.height *
                                              .80
                                          : MediaQuery.of(context).size.height *
                                              .70,
                                      child: RefreshIndicator(
                                        color: Colors.white,
                                        backgroundColor: mRed,
                                        onRefresh: () async {
                                          hasMore = true;
                                          plansLastDocument = null;
                                          plansUsers = [];
                                          plansDocs = [];
                                          plansLoading = true;
                                          setState(() {});
                                          return /* loadExplorePlans();*/
                                              getAllPlans();
                                        },
                                        child: PageView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: planData.length,
                                          controller: widget.pageController,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          onPageChanged: (int index) {
                                            print("plansUser: $plansUsers");
                                            print("plansDocs: $plansDocs");
                                            print(
                                                "plansLoading: $plansLoading");
                                            if (index == planData.length - 2) {
                                              /*    loadExplorePlans();*/
                                              getAllPlans();
                                            }
                                            // setState(() {});
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return PlanPage(
                                              index: index,
                                              currentUser: currentUser,
                                              themeProvider: themeProvider,
                                              pDoc: planData[index],
                                              pUser: planData[index]
                                                  ["pdataOwnerID"],
                                              cancelRequest: cancelRequest,
                                              sendRequestData: sendRequestData,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: lRed,
                                                  radius: 60,
                                                  child: Icon(
                                                    Icons.explore_outlined,
                                                    size: 100,
                                                    color: white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Text(
                                              "There's no new plan near you to EXPLORE,\n now it's your time to plan a DATE \n or WAVE to the people nearby or \n create or see new POST."
                                                  .tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.w700,
                                                  color: lRed,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 25
                                                      : 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void detailDialog(context, String detail) async {
    // final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Padding(
            padding: _screenWidth >= miniScreenWidth
                ? const EdgeInsets.only(top: 200.0, bottom: 200)
                : const EdgeInsets.only(top: 120.0, bottom: 120),
            child: SimpleDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.blueGrey.withOpacity(0.8),
              children: [
                Text("$detail",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1.3,
                        fontFamily: 'Handlee',
                        fontWeight: FontWeight.w700,
                        color: white,
                        decoration: TextDecoration.none,
                        fontSize: 22)),
              ],
            ),
          );
        });
    // showDialog(
    //     context: context,
    //     builder: (BuildContext buildContext) {
    //       return Padding(
    //         padding: const EdgeInsets.only(top:200.0,bottom: 200),
    //         child: AlertDialog(
    //           backgroundColor: Colors.blueGrey.withOpacity(0.5),
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //           content: Scrollbar(
    //             radius: Radius.circular(20),
    //             thickness: 5,
    //             isAlwaysShown: true,
    //             child:
    //             Container(
    //               alignment: Alignment.center,
    //               //height:200,
    //               // width: 300,
    //               child: SingleChildScrollView(
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: [
    //                     Text("$detail",
    //                         textAlign: TextAlign.center,
    //                         style: TextStyle(
    //                             letterSpacing: 1.3,
    //                             fontFamily: 'Handlee',
    //                             fontWeight: FontWeight.w700,
    //                             color: white,
    //                             decoration: TextDecoration.none,
    //                             fontSize: 22)),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ) ,
    //         ),
    //       );
    //     });
  }

  Future<bool> checkRoseCount(CreateAccountData accountData) async {
    DocumentSnapshot docSnap = await _firebaseController.userColReference
        .doc(_firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    print(docSnap.data());
    Map<String, dynamic> roseData = docSnap.data();
    if (roseData['roseColl'] != null) {
      if (roseData['roseColl'] >= 5) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> insertRoseData(CreateAccountData accountData) async {
    String usrId = accountData.uid;
    CollectionReference userRef =
        _firebaseController.userColReference.doc(usrId).collection('R');
    DocumentSnapshot userCountDoc = await userRef.doc('count').get();
    DocumentSnapshot docCurrent = await _firebaseController.userColReference
        .doc(_firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    DocumentSnapshot userDocData = await userRef
        .doc(_firebaseController.firebaseAuth.currentUser.uid)
        .get();

    print('uid: ${_firebaseController.firebaseAuth.currentUser.uid}');
    await _firebaseController.userColReference
        .doc(_firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .update({
      "roseColl": (docCurrent['roseColl'] - 5),
    }).onError((error, stackTrace) {
      print("ExplorePlan SendRequest RoseColl Increament Error : $error");
    });

    print('otherUid: $usrId');
    if (userCountDoc.data() != null) {
      print("userCount not null");
      if (userDocData.data() != null) {
        print("userDoc not null");

        try {
          int oldFresh = await userDocData['fresh'];
          int oldTotal = await userDocData['total'];
          userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).update({
            "pictureUrl": currentUser.profilepic,
            "fresh": oldFresh + 1,
            "total": oldTotal + 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      } else {
        print("userDoc null");

        try {
          userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).set({
            "pictureUrl": currentUser.profilepic,
            "fresh": 1,
            "total": 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      }
      userRef.doc('count').update({
        "roseRec": userCountDoc['roseRec'] + 1,
        "new": userCountDoc['new'] + 1,
        "isRead": false,
      });
    } else {
      print("Else");
      userRef.doc('count').set({
        "roseRec": 1,
        "new": 1,
        "isRead": false,
      });

      userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).set({
        "pictureUrl": currentUser.profilepic,
        "fresh": 1,
        "total": 1,
        'timestamp': DateTime.now(),
        //'type':"received",
        'isRead': false,
        'name': currentUser.name,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });
    }
    return true;
  }

  void insertNotificationCount(CreateAccountData userAccountData) async {
    String userId = userAccountData.uid;
    // CollectionReference userPlanRequestReference = _firebaseController.userColReference.doc(userId).collection('planRequest');
    //  S   ====== CollectionReference userPlanRequestReference = _firebaseController.notificationColReference.doc().collection('planRequest');
    CollectionReference userPlanRequestReference = _firebaseController
        .planColReference
        .doc(userAccountData.uid)
        .collection('planRequest');
    DocumentSnapshot userCountDoc =
        await userPlanRequestReference.doc('count').get();
    print(userCountDoc);

    if (userCountDoc.data() != null) {
      userPlanRequestReference.doc('count').update({
        "total": userCountDoc['total'] + 1,
        "new": userCountDoc['new'] + 1,
        "isRead": false,
      });
    } else {
      userPlanRequestReference.doc('count').set({
        "total": 1,
        "new": 1,
        "isRead": false,
      });
    }
    var data = {
      "CreatedUserId": userAccountData.uid,
      "sendBy": currentUser.uid,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "type": "Plan Request",
    };
    await _firebaseController.notificationColReference
        .doc(_firebaseController.currentFirebaseUser.uid +
            "." +
            userAccountData.uid)
        .set(data);
  }

  Future showRoseDialog(context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext buildContext) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
            //  Navigator.push(context, CupertinoPageRoute(builder: (context) => Welcome()));
          });
          return Center(
            child: Container(
              margin: EdgeInsets.all(100.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.transparent,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 5)
                ],
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              width: _screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              height: _screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              child: themeProvider.isDarkMode
                  ? Image.asset(
                      "assets/images/litpielogo.png",
                      height: _screenWidth >= miniScreenWidth ? 50 : 40,
                    )
                  : Image.asset(
                      "assets/images/litpielogo.png",
                      height: _screenWidth >= miniScreenWidth ? 50 : 40,
                    ),
            ),
          );
        });
  }

  Future noRoseDialog(context) async {
    // final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.blueGrey.withOpacity(0.5),
            children: [
              Text(
                  "OOPS!!! You need 5 LitPie's to Send Request in your collection. Please go to your profile and collect it now."
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
                    child: Text("Go Now".tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 19,
                            fontWeight: FontWeight.bold)),
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
    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext buildContext) {
    //       Future.delayed(Duration(seconds: 5), () {
    //         Navigator.pop(context);
    //         //  Navigator.push(context, CupertinoPageRoute(builder: (context) => Welcome()));
    //       });
    //       return Center(
    //         child: Padding(
    //           padding: const EdgeInsets.all(20.0),
    //           child: Container(
    //             height: MediaQuery.of(context).size.height * .55,
    //             color: Colors.blueGrey.withOpacity(0.5),
    //             child: Align(
    //               alignment: Alignment.center,
    //               child: Text(
    //                       "OOPS!!! You need 5 Roses to Send Request in your collection. Please go to your profile and collect it now."
    //                           .tr(),
    //                       textAlign: TextAlign.center,
    //                       style: TextStyle(
    //                           fontFamily: 'Handlee',
    //                           fontWeight: FontWeight.w700,
    //                           color: white,
    //                           decoration: TextDecoration.none,
    //                           fontSize: 22))
    //                   .tr(),
    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }

  Future sendRequestData(int index, CreateAccountData accountData) async {
    // CollectionReference planRequestRef = await docRef.doc(plansUsers[index].uid)
    //     .collection('planRequest');
    // DocumentSnapshot userCountDoc = await userRef.doc('count').get();

    await checkRoseCount(accountData).then((checked) async {
      if (checked) {
        print('uid: ${auth.currentUser.uid}');
        print('otherUid: ${accountData.uid}');

        // await docRef.doc(accountData.uid).collection('plans').doc(accountData.uid).get().then((value) {
        await planRef
            .where("pdataOwnerID", isEqualTo: accountData.uid)
            .get()
            .then((value) async {
          if (value.docs[0]["pName"] != "") {
            var data = await insertRoseData(accountData);
            if (data == true) {
              await sendPlanNotifications(planData[index]);
              //  await insertNotificationCount(accountData);
            }

            planRef
                .doc(planData[index]['planId'])
                .collection('planRequest')
                .doc(accountData.uid)
                .set({
              // 'planBy': planUser.uid,
              'planRequest': accountData.uid,
              'request': "sent",
              'isRead': false,
              // 'pName':planDoc['pName'],
              // 'userName': planUser.name,
              // 'pictureUrl':planUser.profilepic,
              // 'timestamp': DateTime.now(),
            }, SetOptions(merge: true)).then((_) {
              print("success!");
            });

            planRef
                .doc(planData[index]['planId'])
                .collection('planRequest')
                .doc(currentUser.uid)
                .set({
              // 'planBy': plansUsers[index].uid,
              'planRequest': currentUser.uid,
              'pName': value.docs[0]["pName"], //changed
              'request': "received",
              'isRead': false,
              'userName': currentUser.name,
              'pictureUrl': currentUser.profilepic,
              'timestamp': DateTime.now(),
            }, SetOptions(merge: true)).then((_) {
              print("success!");
            });
            Fluttertoast.showToast(
                msg: "Interest sent!!".tr(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: "Post Doesn't Exist!".tr(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
                fontSize: 16.0);

            plansLastDocument = null;
            hasMore = true;
            /* loadExplorePlans()*/
            getAllPlans();
          }
        });
      } else {
        noRoseDialog(context);
      }
    });
  }

  sendPlanNotifications(planData) async {
    deviceToken.clear();
    List myList = [];
    var data;

    var notificationList = await FirebaseFirestore.instance
        .collection(notificationCollectionName)
        .limit(1)
        .get();
    if (notificationList.docs.isEmpty) {
      var ref = await FirebaseFirestore.instance
          .collection(notificationCollectionName)
          .doc();
      var data = {
        'is_read': false,
        'request': "sent",
        "pdataOwnerID": planData['pdataOwnerID'],
        "requestSendBy": currentUser.uid,
        "CreatedUserId": planData['pdataOwnerID'],
        "createdAt":
            (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt(),
        "planId": planData['planId'],
        "_id": planData['planId'],
        "type": "Plan Request",
        "pName": planData['pName'],
      };
      print(data);
      ref.set(data).catchError((error) {
        print(error);
      });
    } else {
      var ref = await FirebaseFirestore.instance
          .collection(notificationCollectionName)
          .doc();
      data = {
        'is_read': false,
        'request': "sent",
        "pdataOwnerID": planData['pdataOwnerID'],
        "CreatedUserId": planData['pdataOwnerID'],
        "requestSendBy": currentUser.uid,
        "createdAt":
            (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt(),
        "planId": planData['planId'],
        "_id": planData['planId'],
        "type": "Plan Request",
        "pName": planData['pName'],
      };
      ref.set(data).catchError((error) {
        print(error);
      });
    }

    QuerySnapshot tokenList = await _firebaseController.userColReference
        .doc(planData['pdataOwnerID'])
        .collection(userDevicesCollectionName)
        .get();
    if (tokenList.docs.isNotEmpty) {
      tokenList.docs.forEach((element) {
        myList.add(element.data());
      });
      if (myList.length > 0) {
        myList.forEach((element) {
          deviceToken.add(element['token']);
        });
      }
      if (deviceToken.length > 0) {
        await sendLocalNotification(
          data,
          deviceToken,
          currentUser.name,
        );
      }
    }
  }

  Future getAllPlans() async {
    planData.clear();
    QuerySnapshot allPlans = await _firebaseController.planColReference
        .where("pdataOwnerID", isNotEqualTo: currentUser.uid)
        .get();
    if (allPlans.docs.isNotEmpty) {
      allPlans.docs.forEach((element) async {
        getDurationPercentage(element["createdAt"], element["pTimeStamp"]) <=
                0.90
            ? await planData.add(element.data())
            : element.reference.delete();
      });
    }
    plansLoading = false;

    if (mounted) setState(() {});
  }

  double getDurationPercentage(Timestamp startDate, Timestamp endDate) {
    DateTime start = startDate.toDate();
    DateTime end = endDate.toDate();
    int totalDiff = end.difference(start).inSeconds;
    int currentDiff = DateTime.now().difference(end).inSeconds.abs();
    double percentage = 1.0 - (currentDiff / totalDiff);
    print(percentage);
    if (end.difference(DateTime.now()).inSeconds <= 0) {
      return 1.0;
    }
    return percentage.abs() > 9.99 ? 1.0 : percentage;
  }

  cancelRequest(int index, CreateAccountData planUser) async {
    planRef
        .where("pdataOwnerID",
            isEqualTo: planUser
                .uid) /*doc(planUser.uid).collection('plans').doc(planUser.uid)*/
        .get()
        .then((value) async {
      if (value.docs[0]["pName"] != "") {
        DocumentSnapshot docCurrent = await _firebaseController.userColReference
            .doc(_firebaseController.firebaseAuth.currentUser.uid)
            .collection('R')
            .doc('count')
            .get();
        _firebaseController.userColReference
            .doc(_firebaseController.firebaseAuth.currentUser.uid)
            .collection('R')
            .doc('count')
            .update({
          "roseColl": docCurrent['roseColl'] + 4,
        });

        //Delete Request In Current User Database
        planRef
            .doc(planData[index]['planId'])
            .collection('planRequest')
            .doc(planUser.uid)
            .get()
            .then((planRequest) {
          if (planRequest.data()["request"] == "sent") {
            planRequest.reference.delete();
          }
        });

        //Delete Request In Plan User Database
        planRef
            .doc(planData[index]['planId'])
            .collection('planRequest')
            .doc(currentUser.uid)
            .get()
            .then((planRequest) {
          if (planRequest.data()["request"] == "received") {
            planRequest.reference.delete();
          }
        });

        //Delete Request In Notification Database
        await _firebaseController.notificationColReference
            .where('sendBy', isEqualTo: currentUser.uid)
            .get()
            .then((value) {
          print(value);
          value.docs.forEach((element) {
            element.reference.delete();
          });
        });
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("Notifications")
            .where("planId", isEqualTo: planData[index]['planId'])
            .where('requestSendBy', isEqualTo: auth.currentUser.uid)
            .get();
        if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.length > 0) {
          querySnapshot.docs.forEach((element) {
            element.reference.delete();
          });
        }
        Fluttertoast.showToast(
            msg: "Request Cancelled!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Post Doesn't Exist!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        //modify as per your
        plansLastDocument = null;
        hasMore = true;
        /*loadExplorePlans()*/
        getAllPlans();
      }
    });
  }

  Widget buildRequestButton(
      {@required String title, @required VoidCallback onTap}) {
    return Container(
      // width: 300.0,
      height: 50.0,
      constraints: BoxConstraints(
        minWidth: 300.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: mRed,
          onPrimary: white,
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        onPressed: onTap,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  sendLocalNotification(
    var notificationData,
    List deviceToken,
    String userName,
  ) {
    String title;
    String screenName;
    title = "$userName sent you a request";
    screenName = "PLANS";

    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    try {
      deviceToken.toSet().forEach((element) async {
        final data = {
          "to": element,
          "priority": "high",
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": notificationData['planId'],
            "status": "done",
            "name": userName,
            "screen": screenName,
            "title": title,
            "pdataOwnerID": notificationData['pdataOwnerID'],
            "requestSendBy": notificationData['requestSendBy'],
          },
        };

        final headers = {
          'content-type': 'application/json',
          'Authorization': "key=" +
              "AAAAmRE09k8:APA91bHHUm_GTWw8mjy2ABcpcczb6MTq4Z97uzT0WSVaUpIUp_ZcOHDW1fyupVCVmSOLSrEzOL_L2zwo1Yif-yRIMqGs4fn2QDJ3cbWbh1YooXZcIEK1nsX13T_o8ikkS5DEtBcRzhvS"
        };

        final response = await http.post(Uri.parse(postUrl),
            body: json.encode(data),
            encoding: Encoding.getByName('utf-8'),
            headers: headers);

        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
