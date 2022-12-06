import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/UploadMedia/UploadImages/uplopad_videosFirebase.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/swipeCardModel.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/swipeStack.dart';
import 'package:provider/provider.dart';

import '../../../../Theme/colors.dart';
import '../../../../Theme/theme_provider.dart';
import 'package:http/http.dart' as http;

class SwipeProvider extends ChangeNotifier {
  FirebaseController firebaseController = FirebaseController();
  String distanceBW;

  //All userData
  CreateAccountData currentUserData;
  User currentUser;
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  int freeSwipe = 25;
  bool exceedSwipes;
  GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
  double screenWidth;

//
  FirebaseController _firebaseController = FirebaseController();

  List<SwipeCardModel> swipeCardModelList = [];
  List<String> deviceToken = [];

  int swipeCount = 0;
  List<SwipeCardModel> swipeCardRemoved = [];
  List<QueryDocumentSnapshot> likedByList = [];
  SwipeCardModel element;

  // List<CreateAccountData> users = [];
  List<QueryDocumentSnapshot> likedByUsersDocs = [];
  List<QueryDocumentSnapshot> querySnapshot_likedUIDsUsersDetail = [];

  //Load More Variables
  DocumentSnapshot lastDocument;
  DocumentSnapshot likedByUsersUID_lastDocument;
  bool hasMore = true;
  bool likedByUsersHasMore = true;
  int initialDocLimit = 10;
  int laterDocLimit = 5;

  //loading
  bool isFetching = true;

  //getCurrentUser
  getCurrentUser() async {
    try {
      currentUserData = await firebaseController.currentUserData;
      currentUser = _firebaseController.firebaseAuth.currentUser;
    } catch (e) {
      print(e.toString());
    }
    await init();
    await getInitialSwipeCard();
   // notifyListeners();
  }

  //checkRoseCount
  SwipeProvider() {
    getCurrentUser();
  }

  checkRoseCount(CreateAccountData AccountData, BuildContext context) async {
    DocumentSnapshot docCurrent = await firebaseController.userColReference
        .doc(firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    if (docCurrent.data() != null) {
      if (docCurrent['roseColl'] != null) {
        if (docCurrent['roseColl'] >= 1) {
          insertData(AccountData);
          showRoseDialog(context);
          Fluttertoast.showToast(
              msg: "Delivered".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: mRed,
              textColor: Colors.white,
              fontSize: 16.0);
          print("Sent");
        } else {
          NoRoseDialog(context);
        }
      }
    } else {
      NoRoseDialog(context);
    }
  }

  void insertNotificationCount(CreateAccountData swipeUserData) async {
    String userId = swipeUserData.uid;
    CollectionReference cuserMatchReference = firebaseController
        .userColReference
        .doc(firebaseController.firebaseAuth.currentUser.uid)
        .collection('Matches');

    DocumentSnapshot cuserCountDoc =
        await cuserMatchReference.doc('count').get();

    if (cuserCountDoc.data() != null) {
      cuserMatchReference.doc('count').update({
        "total": cuserCountDoc['total'] + 1,
        "new": cuserCountDoc['new'] + 1,
        "isRead": false,
      });
    } else {
      cuserMatchReference.doc('count').set({
        "total": 1,
        "new": 1,
        "isRead": false,
      });
    }
    var u1 = firebaseController.firebaseAuth.currentUser.uid;
    String matchesNotificationId = u1 + "-" + userId;
    inserMatchesData(swipeUserData, matchesNotificationId);
    var data = {
      "matches": userId,
      "currentUser": u1,
      "CreatedUserId": u1,
      "createdAt": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "_id": matchesNotificationId,
      "is_read": false,
      "type": "Matches"
    };
    await firebaseController.notificationColReference
        .doc(matchesNotificationId)
        .set(data);
    sendMatchNotification(swipeUserData.uid, matchesNotificationId);
  }

  sendMatchNotification(
      String sendToMatchedUser, String matchesNotificationId) async {
    CreateAccountData currentUserAccountData;
    CreateAccountData matchedWithAccountData;
    var data;
    List myList = [];
    deviceToken.clear();
    DocumentSnapshot<Map<String, dynamic>> matchedUserData =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(sendToMatchedUser)
            .get();
    if (matchedUserData.data() != null) {
      currentUserAccountData =
          CreateAccountData.fromDocument(matchedUserData.data());
    }
    DocumentSnapshot<Map<String, dynamic>> matchedUser = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (matchedUser.data() != null) {
      matchedWithAccountData =
          CreateAccountData.fromDocument(matchedUser.data());
    }

    QuerySnapshot tokenList = await firebaseController.userColReference
        .doc(currentUserAccountData.uid)
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
        final postUrl = 'https://fcm.googleapis.com/fcm/send';
        try {
          deviceToken.toSet().forEach((element) async {
            final data = {
              "to": element,
              "priority": "high",
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "status": "done",
                "name": currentUserAccountData.name,
                "screen": "MATCHES",
                "title": "Congratulations!",
                "body": "You are matched with ${matchedWithAccountData.name}",
                "matchedWith": matchedWithAccountData.uid,
                "currentUser": currentUserAccountData.uid,
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
  }

  sendMatchedLocalNotification() {}

  insertData(CreateAccountData otherUserId) async {
    CollectionReference userRef = firebaseController.userColReference
        .doc(otherUserId.uid)
        .collection('R');
    DocumentSnapshot userCountDoc = await userRef.doc('count').get();
    DocumentSnapshot docCurrent = await firebaseController.userColReference
        .doc(firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    DocumentSnapshot userDocData = await userRef
        .doc(firebaseController.firebaseAuth.currentUser.uid)
        .get();

    firebaseController.userColReference
        .doc(firebaseController.firebaseAuth.currentUser.uid)
        .collection('R')
        .doc('count')
        .update({
      "roseColl": docCurrent['roseColl'] - 1,
    });

    print('otherUid: $otherUserId.uid');
    if (userCountDoc.data() != null) {
      if (userDocData.data() != null) {
        try {
          int oldFresh = await userDocData['fresh'];
          int oldTotal = await userDocData['total'];
          userRef.doc(firebaseController.firebaseAuth.currentUser.uid).update({
            "pictureUrl": currentUserData.profilepic,
            "fresh": oldFresh + 1,
            "total": oldTotal + 1,
            'timestamp': (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
            'isRead': false,
            'name': currentUserData.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      } else {
        print("userDoc null");

        try {
          userRef.doc(firebaseController.firebaseAuth.currentUser.uid).set({
            "pictureUrl": currentUserData.profilepic,
            "fresh": 1,
            "total": 1,
            'timestamp': (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
            'isRead': false,
            'name': currentUserData.name,
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

      userRef.doc(firebaseController.firebaseAuth.currentUser.uid).set({
        "pictureUrl": currentUserData.profilepic,
        "fresh": 1,
        "total": 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        //'type':"received",
        'isRead': false,
        'name': currentUserData.name,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });
    }
    sendNotification(otherUserId.uid);
  }

  Future showMatchDialog(BuildContext context, int index) {
    SwipeCardModel swipeCard = swipeCardModelList[index];
    return showDialog(
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(ctx);
          });
          return SimpleDialog(
            contentPadding: EdgeInsets.all(20.0),
            insetPadding: EdgeInsets.all(20.0),
            backgroundColor: Colors.blueGrey.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            children: [
              Center(
                child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.blueGrey,
                            offset: Offset(2, 2),
                            spreadRadius: 1,
                            blurRadius: 2)
                      ],
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(
                        80,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        80,
                      ),
                      child: swipeCard.createAccountData != null
                          ? swipeCard.createAccountData.profilepic.isNotEmpty
                              ? CachedNetworkImage(
                                  height:
                                      screenWidth >= miniScreenWidth ? 125 : 90,
                                  width:
                                      screenWidth >= miniScreenWidth ? 125 : 90,
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      swipeCard.createAccountData.profilepic,
                                  useOldImageOnUrlChange: true,
                                  placeholder: (context, url) =>
                                      CupertinoActivityIndicator(
                                    radius: 1,
                                  ),
                                  errorWidget: (context, url, error) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.error,
                                        color: Colors.blueGrey,
                                        size: 1,
                                      ),
                                      Text(
                                        "Error".tr(),
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                        ),
                                      ).tr(),
                                    ],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    80,
                                  ),
                                  child: Container(
                                    height: screenWidth >= miniScreenWidth
                                        ? 125
                                        : 90,
                                    width: screenWidth >= miniScreenWidth
                                        ? 125
                                        : 90,
                                    child: Center(
                                      child: Image.asset(placeholderImage,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                80,
                              ),
                              child: Container(
                                height:
                                    screenWidth >= miniScreenWidth ? 125 : 90,
                                width:
                                    screenWidth >= miniScreenWidth ? 125 : 90,
                                child: Center(
                                  child: Image.asset(placeholderImage,
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                    )),
              ),
              SizedBox(
                height: screenWidth >= miniScreenWidth ? 20 : 10,
              ),
              Center(
                child: Column(
                  children: [
                    Text(
                      "CONGRATS!!!\n you got it...\n It's a Match\n with "
                              .tr() +
                          "${swipeCard.createAccountData.name.toUpperCase()}.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Handlee',
                          fontWeight: FontWeight.w700,
                          color: white,
                          fontSize: screenWidth >= miniScreenWidth ? 28 : 22,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
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
              width: screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              height: screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              child: themeProvider.isDarkMode
                  ? Image.asset(
                      "assets/images/litpielogo.png",
                      height: screenWidth >= miniScreenWidth ? 50 : 40,
                    )
                  : Image.asset(
                      "assets/images/litpielogo.png",
                      height: screenWidth >= miniScreenWidth ? 50 : 40,
                    ),
            ),
          );
        });
  }

  Future NoRoseDialog(context) async {
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
                  "OOPS!!! You don't have any LitPie to give in your collection. Please go to your profile and collect it now."
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      color: white,
                      decoration: TextDecoration.none,
                      fontSize: screenWidth >= miniScreenWidth ? 22 : 19)),
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
                                  screenWidth >= miniScreenWidth ? 22 : 18,
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

  //swipeController

  init() async {
    swipeCardRemoved.clear();
    // await checkedUserOrNot();
    await getLikedByList();
    await getSwipedCount();
    // await getUserList();
    await getInitialSwipeCard();
    //notifyListeners();
  }

  Future getSwipedCount() {
    FirebaseController()
        .userColReference
        .doc(currentUser.uid)
        .collection("CheckedUser")
        .where(
          'timestamp',
          isGreaterThan: Timestamp.now().toDate().subtract(Duration(days: 1)),
        )
        .snapshots()
        .listen((event) {
      print("swipe " + event.docs.length.toString());
      swipeCount = event.docs.length;
     // notifyListeners();
    });
  }

  //

  Future<void> getLikedByList() async {
    CollectionReference likedByRef = _firebaseController.userColReference
        .doc(currentUser.uid)
        .collection("LikedBy");
    QuerySnapshot tempQueries = await likedByRef.get();
    if (tempQueries.docs.isNotEmpty) {
      likedByList = tempQueries.docs;
    }
   // notifyListeners();
  }

  Query likedByUserQuery({@required String userUid}) {
    if (currentUserData.showGender == 'everyone') {
      return _firebaseController.userColReference
          .where("uid", isEqualTo: userUid)
          .where("age",
              isGreaterThanOrEqualTo: currentUserData.ageRange["min"],
              isLessThanOrEqualTo: currentUserData.ageRange["max"])
          .orderBy("age", descending: false);
    } else {
      return _firebaseController.userColReference
          .where("uid", isEqualTo: userUid)
          .where("editInfo.userGender", isEqualTo: currentUserData.showGender)
          .where("age",
              isGreaterThanOrEqualTo: currentUserData.ageRange["min"],
              isLessThanOrEqualTo: currentUserData.ageRange["max"])
          .orderBy("age", descending: false);
    }
  }

  Query query() {
    if (currentUserData.showGender == 'everyone') {
      return _firebaseController.userColReference
          .where('age',
              isGreaterThanOrEqualTo: currentUserData.ageRange['min'],
              isLessThanOrEqualTo: currentUserData.ageRange['max'])

          /// int.parse(currentUser.ageRange['min'])
          .orderBy('age', descending: false);
    } else {
      return _firebaseController.userColReference
          .where('editInfo.userGender', isEqualTo: currentUserData.showGender)
          // .where('age',
          //     isGreaterThanOrEqualTo: currentUserData.ageRange['min'],
          //     isLessThanOrEqualTo: currentUserData.ageRange['max'])
         // .orderBy('age', descending: false)
      ;
    }
  }

  Future<bool> checkedUserOrNotBool({@required String uid}) async {
    QuerySnapshot querySnapshot = await _firebaseController.userColReference
        .doc(currentUser.uid)
        .collection("CheckedUser")
        .where("LikedUser", isEqualTo: uid.toString())
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> getInitialSwipeCard() async {
   // notifyListeners();
    if (!hasMore) {
      print("No More Post");
      isFetching = false;
    //  notifyListeners();
      return;
    }

    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshot_likedUsersUID;

    if (likedByUsersHasMore) {
      likedByUsersDocs.clear();
      while (likedByUsersDocs.length < initialDocLimit) {
        if (likedByUsersUID_lastDocument == null) {
          swipeCardModelList = [];
          querySnapshot_likedUsersUID = await _firebaseController
              .userColReference
              .doc(currentUser.uid)
              .collection("LikedBy")
              .limit(initialDocLimit)
              .get();
        } else {
          querySnapshot_likedUsersUID = await _firebaseController
              .userColReference
              .doc(currentUser.uid)
              .collection("LikedBy")
              .limit(laterDocLimit)
              .startAfterDocument(likedByUsersUID_lastDocument)
              .get();
        }

        if (querySnapshot_likedUsersUID.docs.length <= 0) {
          likedByUsersHasMore = false;
         // notifyListeners();
          break;
        } else {
          likedByUsersDocs.addAll(querySnapshot_likedUsersUID.docs);
          //assign Last Document from LikedByUsers
          likedByUsersUID_lastDocument = querySnapshot_likedUsersUID
              .docs[querySnapshot_likedUsersUID.docs.length - 1];
        }
      }

      //Print Likedby Users
      likedByUsersDocs.forEach((element) {
        print("${likedByUsersDocs.indexOf(element)} : ${element.id}");
      });

      //Getting likedUIDsUsersDetail For Swipe Card

      if (likedByUsersDocs.length > 0) {
        for (int i = 0; i < likedByUsersDocs.length; i++) {
          QuerySnapshot tempQuerySnapshot =
              await likedByUserQuery(userUid: likedByUsersDocs[i]["LikedBy"])
                  .get();

          if (tempQuerySnapshot.docs.isNotEmpty)
            querySnapshot_likedUIDsUsersDetail.add(tempQuerySnapshot.docs[0]);
        }
      //  notifyListeners();
      }
    //  notifyListeners();

      if (querySnapshot_likedUIDsUsersDetail.length > 0) {
       // await _getFinalUsersFromDocuments(querySnapshot_likedUIDsUsersDetail);
      }
    }

    //when likedByUserHasMore == false
    if (!likedByUsersHasMore) {
      print("Normal User Called");
      while (swipeCardModelList.length < initialDocLimit) {
        if (lastDocument == null) {
          querySnapshot = await query().limit(laterDocLimit).get();
         // notifyListeners();
        } else {
          querySnapshot = await query()
              .limit(laterDocLimit)
              .startAfterDocument(lastDocument)
              .get();
         // notifyListeners();
        }

        if (querySnapshot.docs.length < laterDocLimit) {
          hasMore = false;
          isFetching = false;
         // notifyListeners();
          print("_getFinalUsersFromDocuments1");
          await _getFinalUsersFromDocuments(querySnapshot.docs);
          print("No More Swipe Load");
         // notifyListeners();
          break;
        } else {
          lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

          //add to SwipeCardModelList -->
          //await
          print("_getFinalUsersFromDocuments2");
          await _getFinalUsersFromDocuments(querySnapshot.docs);
          // print("Temp Users Length: ${tempUsers.length}");
        }
      }
    }
    isFetching = false;
   // notifyListeners();
  }

  Future<void> _getFinalUsersFromDocuments(
      List<QueryDocumentSnapshot> docs) async {
    swipeCardRemoved.clear();
    await Future.forEach(docs, (QueryDocumentSnapshot element) async {
      CreateAccountData temp = CreateAccountData.fromDocument(element.data());


      var distance;
      if(temp.coordinates != null && temp.coordinates['lattitude'] != null) {
        print("temp4 " + temp.coordinates['lattitude']);
         distance = Constants()
            .calculateDistance(currentUser: currentUserData, anotherUser: temp);
        temp.distanceBW = distance.round();



      }
      BlockedUserModel blockedUserModel = await BlockUserController()
          .blockedExistOrNot(
          currentUserId: currentUserData.uid, anotherUserId: temp.uid);
      await getCheckedValue(temp, distance, blockedUserModel);
    });
  }

  Future<void> getCheckedValue(CreateAccountData temp, double distance,
      BlockedUserModel blockedUserModel) async {
    bool isChecked = await checkedUserOrNotBool(uid: temp.uid);
    if (isChecked) {
      if (
          temp.uid != currentUserData.uid &&
          !temp.isBlocked &&
          !temp.isDeleted &&
          !temp.isHidden &&
          blockedUserModel == null) {
        temp.imageUrl.clear();
         swipeCardModelList.insert(
            0,
            SwipeCardModel(
                createAccountData: temp,
                images: UserImagesModel(images: []),
                userVideosModel: UserVideosModel(videos: []),
                stories: null,
                blockedUserModel: null));

        await ImageController().getAllImages(uid: temp.uid).then((images) {
          List<Images> image = [];
          if (images.length > 0) {
            images.forEach((element) {
              Images images = Images.fromJson(element);
              image.add(images);
            });
            userImagesModel.images = image;
          } else {
            userImagesModel.images = [];
          }
         // notifyListeners();
          return userImagesModel;
        }).whenComplete(() {
          print("ehen complete");
          notifyListeners();
        });

        await VideoController().getAllVideos(temp.uid).then((videos) {
          List<Videos> lis = [];
          if (videos.length > 0) {
            videos.forEach((element) {
              Videos video = Videos.fromJson(element);
              lis.add(video);
            });
          }
          userVideosModel.videos = lis;
         // notifyListeners();
        }).whenComplete(() {
         // notifyListeners();
        });
        // await StoriesApiController().getStories(uid: temp.uid).then((stories) {
        //   if (stories != null) {
        //     temp.userStoriesModel = stories;
        //     swipeCardModelList.forEach((elem) {
        //       if (elem is SwipeCardModel) {
        //         SwipeCardModel element = elem;
        //         if (element.createAccountData.uid == temp.uid) {
        //           element.stories = stories;
        //           notifyListeners();
        //         }
        //       }
        //     });
        //   } else {
        //     print("No Stories : ${temp.uid}");
        //   }
        // }).whenComplete(() {
        //   notifyListeners();
        // });
      }
      if (swipeCardModelList != null && swipeCardModelList.length > 0) {
        for (int i = 0; i < swipeCardModelList.length; i++) {
          if (swipeCardModelList[i] is SwipeCardModel) {
            if (swipeCardModelList[i].createAccountData.uid == temp.uid) {
              if (userVideosModel.videos != null &&
                  userVideosModel.videos.length > 0) {
                swipeCardModelList[i]
                    .userVideosModel
                    .videos
                    .addAll(userVideosModel.videos);
                swipeCardModelList[i].userVideosModel.videos;
                print(
                    "The length of item videos are :${swipeCardModelList[i].userVideosModel.videos.length}");
              }
              if (userImagesModel.images != null &&
                  userImagesModel.images.length > 0) {
                swipeCardModelList[i]
                    .images
                    .images
                    .addAll(userImagesModel.images);
                swipeCardModelList[i].images.images;
                print(
                    "The length of item videos are :${swipeCardModelList[i].userVideosModel.videos.length}");
            //    notifyListeners();
              }
            }
          }
         // notifyListeners();
        }
      }
    }
  //  notifyListeners();
  }

  void removeSwipeCard({@required SwipeCardModel swipeCardModel}) {
    swipeCardModelList.remove(swipeCardModel);
    notifyListeners();
  }

  Future<void> inserMatchesData(
      CreateAccountData swipeUserData, String notificationId) async {
    await firebaseController.userColReference
        .doc(currentUser.uid)
        .collection("Matches")
        .doc(swipeUserData.uid)
        .set(
      {
        'matches': swipeUserData.uid,
        'currentUser': currentUser.uid,
        'isRead': false,
        'userName': swipeUserData.name,
        'pictureUrl': swipeUserData.profilepic,
        "_id": notificationId,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      },
    );

    await firebaseController.userColReference
        .doc(swipeUserData.uid)
        .collection("Matches")
        .doc(currentUser.uid)
        .set(
      {
        'matches': currentUser.uid,
        'currentUser': swipeUserData.uid,
        //for notification sending (check who swipe in last to create match)
        'userName': currentUserData.name,
        "_id": notificationId,
        'pictureUrl': currentUserData.profilepic,
        'isRead': false,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      },
    );
  }

  sendNotification(String otherUserId) async {
    CreateAccountData currentUserAccountData;
    var data;
    DocumentSnapshot<Map<String, dynamic>> currentUserData =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get();
    if (currentUserData.data() != null) {
      currentUserAccountData =
          CreateAccountData.fromDocument(currentUserData.data());
    }

    var notificationList = await FirebaseFirestore.instance
        .collection(notificationCollectionName)
        .limit(1)
        .get();
    var ref = await firebaseController.notificationColReference.doc();
    data = {
      "litPieTo": otherUserId,
      "CreatedUserId": otherUserId,
      "litPieBy": currentUser.uid,
      "createdAt": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "type": "LitPie",
      "_id": ref.id,
      "is_read": false,
    };
    if (notificationList.docs.isEmpty) {
      await ref.set(data).whenComplete(() => sendLocalNotification(
          otherUserId, currentUserAccountData.name, data));
    } else {
      await ref.set(data).whenComplete(() {
        sendLocalNotification(otherUserId, currentUserAccountData.name, data);
      });
    }
  }

  sendLocalNotification(
      String sendToUserId, String currentUserName, var notificationData) async {
    List myList = [];
    deviceToken.clear();
    QuerySnapshot tokenList = await firebaseController.userColReference
        .doc(sendToUserId)
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
        firebaseMessagingNotification(
            deviceToken, currentUserName, notificationData);
      }
    }
  }

  firebaseMessagingNotification(
      List<String> deviceToken, String currentUserName, var notificationData) {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    try {
      deviceToken.toSet().forEach((element) async {
        final data = {
          "to": element,
          "priority": "high",
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            "name": currentUserName,
            "screen": "LIT_PIE",
            "title": "${currentUserName} send you a LitPie",
            "litPieTo": notificationData['litPieTo'],
            "litPieBy": notificationData['litPieBy'],
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
