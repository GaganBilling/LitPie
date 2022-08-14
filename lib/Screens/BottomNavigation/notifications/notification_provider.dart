import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/createAccountData.dart';

class NotificationProvider extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  CreateAccountData currentUser;
  BuildContext dialogContext;
  String dropdownValue = 'All';
  bool isMatchLoading = false;
  bool isAllLoading = false;
  bool isLikeLoading = false;
  bool isPostLoading = false;
  bool isCommentLoading = false;
  bool isPlanRequestLoading = false;
  bool isLitPieLoading = false;
  var matchesDoc;
  var matchesAnotherDoc;
  var rDoc;
  var items = [
    "All",
    'Post',
    'Plan Request',
    'LitPie',
    'Matches',
  ];

  TabController tabController;
  ScrollController scrollViewController;
  CollectionReference matchReference;
  CollectionReference planReference;
  CollectionReference rReference;
  CollectionReference notRefrenece;
  List allNotificationList = [];
  List likesNotificationList = [];
  List postNotificationList = [];

  List commentsNotificationList = [];
  List planRequestNotificationList = [];
  List matchesNotificationList = [];
  List litpieNotificationList = [];
  List unreadCount = [];
  List allUnreadCount = [];
  List likeUnreadCount = [];
  List postUnreadCount = [];
  List commentUnreadCount = [];
  List matchesUnreadCount = [];
  List litpieUnreadCount = [];
  List planRequestUnreadCount = [];

  ScrollController rScrollController = ScrollController();
  ScrollController planScrollController = ScrollController();
  ScrollController matchScrollController = ScrollController();
  ScrollController pollScreenScrollController = ScrollController();

  FirebaseController firebaseController = FirebaseController();

  Future<CreateAccountData> getUser() async {
    final User user = auth.currentUser;
    if (pollScreenScrollController.hasClients) {
      if (pollScreenScrollController.offset > 100)
        pollScreenScrollController.animateTo(
            pollScreenScrollController.initialScrollOffset,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
    }
    return firebaseController.userColReference
        .doc(user.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.data()));
  }

  void scrollToInitialOffset({ScrollController controller}) {
    if (controller.hasClients) {
      if (controller.offset > 100)
        controller.animateTo(controller.initialScrollOffset,
            duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  NotificationProvider() {
    deleteOlderNotifications();
  }

//methods
  checkedNotification(String type, int index, String postId, String id,
      {String requestBy}) async {
    switch (type) {
      case "Likes":
        {
          if (notRefrenece != null) {
            print(id);
            await notRefrenece.where("_id", isEqualTo: id).get().then((value) {
              value.docs[0].reference.update({
                "is_read": true,
              });
              if (unreadCount.length > 0) {
                for (int i = 0; i <= unreadCount.length - 1; i++) {
                  if (unreadCount[i]['_id'] == id) {
                    unreadCount.remove(unreadCount[i]);
                    notifyListeners();
                  }
                }
                if (likeUnreadCount.length > 0) {
                  for (int i = 0; i <= likeUnreadCount.length - 1; i++) {
                    if (likeUnreadCount[i]['_id'] == id) {
                      likeUnreadCount.remove(likeUnreadCount[i]);
                      notifyListeners();
                    }
                  }
                }
              }
            });
          }
          var data = likesNotificationList
              .where((element) => element["_id"] == id)
              .toList();
          if (data.length > 0) {
            data[0]['is_read'] = true;
          }
          scrollToInitialOffset(controller: rScrollController);
          notifyListeners();
        }
        break;
      case "Comments":
        {
          if (notRefrenece != null) {
            await notRefrenece.where("_id", isEqualTo: id).get().then((value) {
              value.docs[0].reference.update({"is_read": true});
              if (unreadCount.length > 0) {
                for (int i = 0; i <= unreadCount.length - 1; i++) {
                  if (unreadCount[i]['_id'] == id) {
                    unreadCount.remove(unreadCount[i]);
                    notifyListeners();
                  }
                }
              }
              if (commentUnreadCount.length > 0) {
                for (int i = 0; i <= commentUnreadCount.length - 1; i++) {
                  if (commentUnreadCount[i]['_id'] == id) {
                    commentUnreadCount.remove(commentUnreadCount[i]);
                    notifyListeners();
                  }
                }
              }
            });
          }
          var data = commentsNotificationList
              .where((element) => element["_id"] == id)
              .toList();
          if (data.length > 0) {
            data[0]['is_read'] = true;
          }
          scrollToInitialOffset(controller: planScrollController);
          notifyListeners();
        }
        break;
      case "Matches":
        {
          //MatchNotification
          if (unreadCount.length > 0) {
            for (int i = 0; i <= unreadCount.length - 1; i++) {
              if (unreadCount[i]['_id'] == id) {
                unreadCount.remove(unreadCount[i]);
                notifyListeners();
              }
            }
          }
          if (matchesUnreadCount.length > 0) {
            for (int i = 0; i <= matchesUnreadCount.length - 1; i++) {
              if (matchesUnreadCount[i]['_id'] == id) {
                matchesUnreadCount.remove(matchesUnreadCount[i]);
                notifyListeners();
              }
            }
          }
          var data = matchesNotificationList
              .where((element) => element["_id"] == id)
              .toList();
          if (data.length > 0) {
            data[0]['is_read'] = true;
          }
          scrollToInitialOffset(controller: matchScrollController);
          notifyListeners();
        }
        break;

      case "LitPie":
        {
          //MatchNotification
          if (unreadCount.length > 0) {
            for (int i = 0; i <= unreadCount.length - 1; i++) {
              if (unreadCount[i]['_id'] == id) {
                unreadCount.remove(unreadCount[i]);
                notifyListeners();
              }
            }
          }
          if (litpieUnreadCount.length > 0) {
            for (int i = 0; i <= litpieUnreadCount.length - 1; i++) {
              if (litpieUnreadCount[i]['_id'] == id) {
                litpieUnreadCount.remove(litpieUnreadCount[i]);
                notifyListeners();
              }
            }
          }
          var data = litpieNotificationList
              .where((element) => element["_id"] == id)
              .toList();
          if (data.length > 0) {
            data[0]['is_read'] = true;
          }
          scrollToInitialOffset(controller: matchScrollController);
          notifyListeners();
        }
        break;
      case "Plan Request":
        {
          if (unreadCount.length > 0) {
            for (int i = 0; i <= unreadCount.length - 1; i++) {
              if (unreadCount[i]['type'] == "Plan Request" &&
                  unreadCount[i]['_id'] == id &&
                  unreadCount[i]['requestSendBy'] == requestBy) {
                unreadCount.remove(unreadCount[i]);
                notifyListeners();
              }
            }
          }
          if (planRequestUnreadCount.length > 0) {
            for (int i = 0; i <= planRequestUnreadCount.length - 1; i++) {
              if (planRequestUnreadCount[i]['type'] == "Plan Request" &&
                  planRequestUnreadCount[i]['_id'] == id &&
                  planRequestUnreadCount[i]['requestSendBy'] == requestBy) {
                planRequestUnreadCount.remove(planRequestUnreadCount[i]);
                notifyListeners();
              }
            }
          }
          var data = planRequestNotificationList
              .where((element) => element["_id"] == id)
              .toList();
          if (data.length > 0) {
            data[0]['is_read'] = true;
          }
          scrollToInitialOffset(controller: matchScrollController);
          notifyListeners();
        }
        break;
    }
  }

  Future getNotificationListByType(
      String dropdownValue, CreateAccountData currentUser) async {
    if (currentUser != null) {
      if (dropdownValue == "Comments") {
        commentUnreadCount.clear();
        var unreadList = [];
        isCommentLoading = true;
        notifyListeners();
        commentsNotificationList.clear();
        await firebaseController.notificationColReference
            .where("CreatedUserId", isEqualTo: currentUser.uid)
            .where("type", isEqualTo: dropdownValue)
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            isCommentLoading = false;
            notifyListeners();
            value.docs.forEach((element) {
              commentsNotificationList.add(element.data());
            });
          }
          unreadList = await commentsNotificationList
              .where((element) => !element['is_read'])
              .toList();
          if (unreadCount.length > 0) {
            var commentsList = unreadCount
                .where((element) => element['type'] == "Comments")
                .toList();
            unreadCount.removeWhere((e) => commentsList.contains(e));
            print(unreadCount);
          }
          unreadCount.addAll(unreadList);
          commentUnreadCount.addAll(unreadList);

          commentsNotificationList;
          isCommentLoading = false;
          notifyListeners();
        }).catchError((e) {
          isCommentLoading = false;
          notifyListeners();
        });
      } else if (dropdownValue == "Plan Request") {
        List unReadList = [];
        planRequestUnreadCount.clear();
        isPlanRequestLoading = true;
        notifyListeners();
        planRequestNotificationList.clear();
        await firebaseController.notificationColReference
            .where("pdataOwnerID", isEqualTo: currentUser.uid)
            .where("type", isEqualTo: dropdownValue)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            isPlanRequestLoading = false;
            notifyListeners();
            value.docs.forEach((element) {
              planRequestNotificationList.add(element.data());
            });
          }
          unReadList = planRequestNotificationList
              .where((element) => !element['is_read'])
              .toList();
          if (unreadCount.length > 0) {
            var commentsList = unreadCount
                .where((element) => element['type'] == "Plan Request")
                .toList();
            unreadCount.removeWhere((e) => commentsList.contains(e));
            print(unreadCount);
          }
          unreadCount.addAll(unReadList);
          planRequestUnreadCount.addAll(unReadList);
          //  checkDate(planRequestNotificationList[0]['createdAt']);
          planRequestNotificationList;

          isPlanRequestLoading = false;
          notifyListeners();
        }).catchError((e) {
          isPlanRequestLoading = false;
          notifyListeners();
        });
      } else if (dropdownValue == "Matches") {
        List unReadList = [];
        matchesUnreadCount.clear();
        matchesNotificationList.clear();
        isMatchLoading = true;
        notifyListeners();
        await firebaseController.notificationColReference
            .where("currentUser", isEqualTo: currentUser.uid)
            .where("type", isEqualTo: dropdownValue)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            isMatchLoading = false;
            notifyListeners();
            value.docs.forEach((element) {
              matchesNotificationList.add(element.data());
            });
          }

          matchesNotificationList;
          isMatchLoading = false;
          notifyListeners();
        });
        await firebaseController.notificationColReference
            .where("matches", isEqualTo: currentUser.uid)
            .where("type", isEqualTo: dropdownValue)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((element) {
              matchesNotificationList.add(element.data());
            });
          }
        });
        unReadList = matchesNotificationList
            .where((element) => !element['is_read'])
            .toList();
        if (unreadCount.length > 0) {
          var matchList = unreadCount
              .where((element) => element['type'] == "Matches")
              .toList();
          unreadCount.removeWhere((e) => matchList.contains(e));
          print(unreadCount);
        }
        unreadCount.addAll(unReadList);
        matchesUnreadCount.addAll(unReadList);
        matchesNotificationList;
        notifyListeners();
      } else if (dropdownValue == "LitPie") {
        List unReadList = [];
        litpieUnreadCount.clear();
        isLitPieLoading = true;
        notifyListeners();
        litpieNotificationList.clear();
        await firebaseController.notificationColReference
            .where("litPieTo", isEqualTo: currentUser.uid)
            .where("type", isEqualTo: dropdownValue)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            isLitPieLoading = false;
            notifyListeners();
            value.docs.forEach((element) {
              litpieNotificationList.add(element.data());
            });
          }
          litpieNotificationList;
          unReadList = litpieNotificationList
              .where((element) => !element['is_read'])
              .toList();
          unreadCount.addAll(unReadList);
          litpieUnreadCount.addAll(unReadList);
          isLitPieLoading = false;
          notifyListeners();
        }).catchError((e) {
          isLitPieLoading = false;
          notifyListeners();
        });
      }
    }
  }

  getDropDownWidget(String dropdownValue) {
    if (dropdownValue == "Post") {
      return postNotificationList;
    } else if (dropdownValue == "Plan Request") {
      return planRequestNotificationList;
    } else if (dropdownValue == "Matches") {
      return matchesNotificationList;
    } else {
      return litpieNotificationList;
    }
  }

  Future getPostNotificationList(String dropdownValue) async {
    if (dropdownValue == "Post") {
      print(unreadCount);
      postUnreadCount.clear();
      List unReadList = [];
      isPostLoading = true;
      postNotificationList.clear();
      notifyListeners();
      await firebaseController.notificationColReference
          .where("CreatedUserId", isEqualTo: currentUser.uid)
          .where("type", isEqualTo: "Likes")
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          notifyListeners();
          value.docs.forEach((element) {
            postNotificationList.add(element.data());
          });
        }
        //allUnreadCount
        unReadList = postNotificationList
            .where(
                (element) => !element['is_read'] && element['type'] == "Likes")
            .toList();
        if (unreadCount.length > 0) {
          var likeList = unreadCount
              .where((element) => element['type'] == "Likes")
              .toList();
          if (likeList.length > 0) {
            unreadCount.removeWhere((e) => likeList.contains(e));
          }
          print(unreadCount);
        }
        unreadCount.addAll(unReadList);
        postUnreadCount.addAll(unReadList);
        notifyListeners();
      }).catchError((e) {
        isPostLoading = false;
        notifyListeners();
      });
      await firebaseController.notificationColReference
          .where("CreatedUserId", isEqualTo: currentUser.uid)
          .where("type", isEqualTo: "Comments")
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          notifyListeners();
          value.docs.forEach((element) {
            postNotificationList.add(element.data());
          });
        }
        unReadList = await postNotificationList
            .where((element) =>
                !element['is_read'] && element['type'] == "Comments")
            .toList();
        if (unreadCount.length > 0) {
          var commentsList = unreadCount
              .where((element) => element['type'] == "Comments")
              .toList();
          unreadCount.removeWhere((e) => commentsList.contains(e));
          print(unreadCount);
        }
        unreadCount.addAll(unReadList);
        postUnreadCount.addAll(unReadList);
        notifyListeners();
      }).catchError((e) {
        isPostLoading = false;
        notifyListeners();
      });
      postNotificationList;
      isPostLoading = false;
      notifyListeners();
    }
    /* if (dropdownValue == "Likes") {
      likeUnreadCount.clear();
      List unReadList = [];
      isLikeLoading = true;
      notifyListeners();
      likesNotificationList.clear();
      await firebaseController.notificationColReference
          .where("CreatedUserId", isEqualTo: currentUser.uid)
          .where("type", isEqualTo: dropdownValue)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          isLikeLoading = false;
          notifyListeners();
          value.docs.forEach((element) {
            likesNotificationList.add(element.data());
          });
        }
        unReadList = likesNotificationList
            .where((element) => !element['is_read'])
            .toList();
        if (unreadCount.length > 0) {
          var likeList = unreadCount
              .where((element) => element['type'] == "Likes")
              .toList();
          unreadCount.removeWhere((e) => likeList.contains(e));
          print(unreadCount);
        }
        unreadCount.addAll(unReadList);
        likeUnreadCount.addAll(unReadList);
        likesNotificationList;

        isLikeLoading = false;
        notifyListeners();
      }).catchError((e) {
        isLikeLoading = false;
        notifyListeners();
      });
    }*/
  }

  Future<dynamic> getData(String currentUser, String matches) async {
    try {
      matchesDoc = await firebaseController.userColReference
          .doc(currentUser)
          .collection("Matches")
          .doc(matches)
          .get();
      notifyListeners();
      return matchesDoc;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getRData(int index) async {
    try {
      rDoc = await firebaseController.userColReference
          .doc(litpieNotificationList[index]["litPieTo"])
          .collection("R")
          .doc(litpieNotificationList[index]["litPieBy"])
          .get();
      notifyListeners();
      return matchesDoc;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getAnotherData(int index) async {
    try {
      matchesAnotherDoc = await firebaseController.userColReference
          .doc(matchesNotificationList[index]["matches"])
          .collection("Matches")
          .doc(matchesNotificationList[index]["currentUser"])
          .get();
      notifyListeners();
      return matchesAnotherDoc;
    } catch (e) {
      print(e.toString());
    }
  }

  changeDropDownValue(newValue) async {
    var item = newValue;
    dropdownValue = item.toString();
    await getAllNotifications(dropdownValue);
    await getPostNotificationList(dropdownValue);
    await getNotificationListByType(dropdownValue, currentUser);
    getDropDownWidget(dropdownValue);
    notifyListeners();
  }

  changeData(CreateAccountData value) {
    currentUser = value;
    if (currentUser != null) {
      getAllNotifications(dropdownValue);
      getPostNotificationList(
        "Post",
      );
      //  getNotificationListByType("Comments", currentUser);
      getNotificationListByType("Plan Request", currentUser);
      getNotificationListByType("LitPie", currentUser);
      getNotificationListByType("Matches", currentUser);
    }
  }

  static bool checkDate(int timeStamp) {
    print(timeStamp);
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    try {
      int totalDays = DateTime.now().difference(date).inDays;
      print(totalDays);

      if (totalDays >= 15) {
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  deleteOlderNotifications() async {
    await firebaseController.notificationColReference.get().then((value) async {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) async {
          Map<String, dynamic> data = element.data();
          bool isOldNotification = checkDate(data['createdAt']);
          if (isOldNotification) {
            await element.reference.delete();
          }
        });
      }
    });
  }

  getAllNotifications(String dropdownValue) async {
    allUnreadCount.clear();
    if (dropdownValue == "All") {
      List unReadList = [];
      isAllLoading = true;
      notifyListeners();
      allNotificationList.clear();
      await firebaseController.notificationColReference
          .where("CreatedUserId", isEqualTo: currentUser.uid)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          isAllLoading = false;
          notifyListeners();
          value.docs.forEach((element) {
            allNotificationList.add(element.data());
          });
        }
        unReadList = allNotificationList
            .where((element) => !element['is_read'])
            .toList();

        allUnreadCount.addAll(unReadList);
        allNotificationList;
        isAllLoading = false;
        notifyListeners();
      }).catchError((e) {
        isAllLoading = false;
        notifyListeners();
      });
    }
  }
}
