import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/UnKnownInformation.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/pushNotificationController.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:litpie/provider/global_posts/model/textPostModel.dart';
import 'package:litpie/variables.dart';

import '../../../models/createAccountData.dart';
import 'package:http/http.dart' as http;

class GlobalPostProvider extends ChangeNotifier {
  FirebaseController firebaseController = FirebaseController();
  CreateAccountData userData;
  String planPicData;
  //globalPollScreenData
  bool hasMore = true;
  bool isLoading = false;
  DocumentSnapshot lastDocument;
  int docLimit = 10;

  Future deletePost(String createdBy,String docId, String commentID, int cCount,TextPostModel commentsCount) async {

    print("createdBy ");
    print( createdBy);
    print(docId);
    print(commentID);
    if (createdBy == firebaseController.currentFirebaseUser.uid) {
      print("createdBy +" "+ docId + " "+commentID");
      await FirebaseFirestore.instance
        .collection("Post")
        .doc(docId).collection("Comments").doc(commentID).delete().catchError((e) {
        Fluttertoast.showToast(
            msg: "Comment Deletion Failed!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }).then((value) async {
        int val = commentsCount.commentsCount;

        commentsCount.commentsCount = val-1;
        await FirebaseFirestore.instance
            .collection("Post")
            .doc(docId).set(commentsCount.toMap()).then((value) => {
        Fluttertoast.showToast(
        msg: "Comment Deleted Successfully!!".tr(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0)
        }).whenComplete(() async {

        });
        });

    }
    notifyListeners();
  }

  //
  List<dynamic> posts = [];
  TextEditingController commentController = TextEditingController();
  List<String> deviceToken = [];
  int currentPostIndex = 0;
  bool isCommentTapped = false;
  bool isCommentsLoading = false;
  bool isPostLoading = false;
  var commentList = [];
  PushNotificationController pushNotificationController =
      PushNotificationController();
  double screenWidth;

  // double _maxScreenWidth;

  Future getUserData() async {
    isPostLoading = true;
    try {
      userData = await firebaseController.getCurrentUserData();
      if (userData != null) {
        await getAllPollPostDetail();
      }
    } catch (e) {}
    notifyListeners();
  }

  Future getAllPollPostDetail() async {
    posts.clear();
    try {
      QuerySnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(postCollectionName)
          .orderBy("createdAt", descending: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        var postList = documentSnapshot.docs
            .where((element) =>
                element['createdBy'] !=
                firebaseController.firebaseAuth.currentUser.uid)
            .toList();
        print(postList);
        if (postList.length > 0) {
          postList.forEach((element) {
            try {
              if (element["type"] != null) {
                if (element["type"] == "post") {
                  posts.add(TextPostModel.fromJson(element.data()));
                } else if (element["type"] == "poll") {
                  posts.add(PollDataModel.fromJson(element.data()));
                }
              }
              isPostLoading = false;
              print(posts);
              notifyListeners();
            } catch (e) {
              isPostLoading = false;
              print(e.toString());
            }
          });
        }
      }
    } catch (e) {
      isPostLoading = false;
      print(e.toString());
    }
    notifyListeners();
  }

//getLikedPosts
  Future<QuerySnapshot> getLikedOrNot(String postId) async {
    QuerySnapshot likePost = await firebaseController
        .likeDislikeCountColReference
        .where("likedBy", isEqualTo: userData.uid)
        .where("postId", isEqualTo: postId)
        .limit(1)
        .get();

    return likePost;
  }

  //getLikeButton
  Future<QuerySnapshot> getLikeButton(String postId) async {
    QuerySnapshot likePost = await getLikedOrNot(postId);
    return likePost;
  }

//getCommentLikeButton
  Future<QuerySnapshot> getCommentLikeButton(
      String postId, String commentId) async {
    QuerySnapshot commentLike = await firebaseController.postColReference
        .doc(postId)
        .collection(commentsLikesCollectionName)
        .where("likedBy", isEqualTo: userData.uid)
        .where("commentId", isEqualTo: commentId)
        .limit(1)
        .get();
    return commentLike;
  }

  //LikeOrDislike
  Future likeOrDislike(String postId, bool isLiked, doc, createdBy) async {
    List myList = [];
    deviceToken.clear();
    if (!isLiked) {
      await firebaseController.likeDislikeCountColReference.doc(doc).delete();
      QuerySnapshot result = await firebaseController.notificationColReference
          .where("likedBy", isEqualTo: userData.uid)
          .limit(1)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((value) {
          value.reference.delete();
        });
      }).whenComplete(() async {
        await firebaseController.postColReference
            .doc(postId)
            .update({"likesCount": FieldValue.increment(-1)});
        notifyListeners();
      });
    } else {
      await firebaseController.postColReference
          .doc(postId)
          .update({"likesCount": FieldValue.increment(1)});
      var ref = firebaseController.likeDislikeCountColReference.doc();

      await ref.set({"likedBy": userData.uid, "postId": postId, "id": ref.id});

      var notificationData = await firebaseController.getNotifications(
          "4",
          userData.uid,
          postId,
          createdBy,
          (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt(),
          false,
          ref.id);
      if (notificationData == true) {
        QuerySnapshot tokenList = await firebaseController.userColReference
            .doc(createdBy)
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
            await sendNotification(
                postId, deviceToken, userData.name, "4", false);
          }
        }
      }
      notifyListeners();
    }
  }

  Future<QuerySnapshot> comments(
      String postId, createdBy, BuildContext context) async {
    List myList = [];
    deviceToken.clear();
    QuerySnapshot isDocumentExist = await firebaseController.postColReference
        .doc(postId)
        .collection(commentCollectionName)
        .get();
    if (isDocumentExist.docs.isEmpty) {}
    var ref = firebaseController.postColReference
        .doc(postId)
        .collection(commentCollectionName)
        .doc();
    await ref.set({
      "commentBy": userData.uid,
      "postId": postId,
      "id": createdBy,
      "comment": commentController.text,
      "commentId": ref.id,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "likesCount": null
    }).catchError((error) {
      print(error.toString());
    }).whenComplete(() async {
      await firebaseController.postColReference
          .doc(postId)
          .update({"commentsCount": FieldValue.increment(1)});
    });

    var notificationData = await firebaseController.getNotifications(
        "5",
        userData.uid,
        postId,
        createdBy,
        (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt(),
        false,
        ref.id);
    if (notificationData) {
      QuerySnapshot tokenList = await firebaseController.userColReference
          .doc(createdBy)
          .collection(userDevicesCollectionName)
          .where("uid", isEqualTo: createdBy)
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
          await sendNotification(
              postId, deviceToken, userData.name, "5", false);
        }
      }
    }

    FocusScope.of(context).requestFocus(FocusNode());
    commentController.clear();
  }

  sendNotification(String postID, List deviceToken, String name,
      notificationType, bool isCommentLike) async {
    String title;
    String screenName;
    if (notificationType == "5") {
      title = "$name commented on your post";
      screenName = "COMMENT_POST";
    } else {
      title =
          isCommentLike ? "$name liked your comment" : "$name liked your post";
      screenName = isCommentLike ? "COMMENT_LIKE" : "LIKE_POST";
    }
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    try {
      deviceToken.toSet().forEach((element) async {
        final data = {
          "to": element,
          "priority": "high",
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": postID,
            "status": "done",
            "name": name,
            "screen": screenName,
            "title": title,
            //"body": "all is well",
          },

          /* "notification": {

          }*/
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

  //
  Query myPollQuery() {
    return firebaseController.pollColReference
        .where("PollQuestion.duration", isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy("PollQuestion.duration", descending: true);
  }

  Future<PollDataModel> getLatestPollDetail({@required String pollId}) async {
    try {
      return PollDataModel.fromDocument(
          await firebaseController.pollColReference.doc(pollId).get());
    } catch (e) {
      return null;
    }
  }

//getCommentLikeOrNot
  Future<QuerySnapshot> getCommentLikedOrNot(
      String commentId, String postId) async {
    QuerySnapshot commentLike = await firebaseController.postColReference
        .doc(postId)
        .collection(commentsLikesCollectionName)
        .where("likedBy", isEqualTo: userData.uid)
        .where("commentId", isEqualTo: commentId)
        .limit(1)
        .get();

    return commentLike;
  }

/*  Future<bool> likeOrDislikeComment(commentId, int index) async {
    var postId = await getPostId(index);
    if (postId != null) {
      QuerySnapshot commentLike = await getCommentLikedOrNot(commentId, postId);
      if (commentLike.docs.isEmpty && commentLike.docs.length == 0) {
        var ref = firebaseController.postColReference
            .doc(postId)
            .collection(commentsLikesCollectionName)
            .doc();
        await ref.set({
          "likedBy": userData.uid,
          "commentId": commentId,
          "id": commentId,
          "createdAt": DateTime.now().millisecondsSinceEpoch
        });
        await firebaseController.postColReference
            .doc(postId)
            .collection(commentCollectionName)
            .doc(commentId)
            .update({"likesCount": FieldValue.increment(1)});

        notifyListeners();
      } else {
        bool isDeleted = await getDeleteData(postId, commentId);
        if (isDeleted) {
          await firebaseController.postColReference
              .doc(postId)
              .collection(commentCollectionName)
              .doc(commentId)
              .update({"likesCount": FieldValue.increment(-1)});
        }
        notifyListeners();
      }
    }

    return true;
  }*/
  Future likeOrDislikeComment(
      commentId, postId, bool isDislike, commentedBy, createdBy) async {
    List myList = [];
    String commentedByData;
    if (commentedBy != null) {
      commentedByData = commentedBy;
    }
    deviceToken.clear();
    if (!isDislike) {
      var ref = firebaseController.postColReference
          .doc(postId)
          .collection(commentsLikesCollectionName)
          .doc();
      await ref.set({
        "likedBy": userData.uid,
        "commentId": commentId,
        "id": commentId,
        "createdAt": DateTime.now().millisecondsSinceEpoch
      });
      await firebaseController.postColReference
          .doc(postId)
          .collection(commentCollectionName)
          .doc(commentId)
          .update({"likesCount": FieldValue.increment(1)});

      if (commentedByData != null &&
          commentedByData != "" &&
          commentedByData != userData.uid) {
        var notificationData = await firebaseController.getNotifications(
            "4",
            userData.uid,
            postId,
            createdBy,
            (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt(),
            false,
            ref.id);

        if (notificationData == true) {
          QuerySnapshot tokenList = await firebaseController.userColReference
              .doc(commentedByData)
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
              await sendNotification(
                  postId, deviceToken, userData.name, "4", true);
            }
          }
        }
      }
    } else {
      bool isDeleted = await getDeleteData(postId, commentId);
      if (isDeleted) {
        await firebaseController.postColReference
            .doc(postId)
            .collection(commentCollectionName)
            .doc(commentId)
            .update({"likesCount": FieldValue.increment(-1)});
      }
      notifyListeners();
    }
  }

  showComments(String postId, {int index}) async {
    commentList.clear();
    var event = await firebaseController.postColReference
        .doc(postId)
        .collection(commentCollectionName)
        .get();
    event.docs.forEach((element) {
      commentList.add(element.data());
    });

    // isLoadingComment = false;
   // notifyListeners();
  }

  Future<bool> getDeleteData(String postId, String commentId) async {
    var data = await firebaseController.postColReference
        .doc(postId)
        .collection(commentsLikesCollectionName)
        .where("commentId", isEqualTo: commentId)
        .limit(1)
        .get();
    if (data.docs.isNotEmpty) {
      data.docs.forEach((element) {
        element.reference.delete();
      });
    }
    return true;
  }

  Future getPostId(int index) async {
    var postId = await firebaseController.postColReference
        .where('postId', isEqualTo: commentList[index]["postId"])
        .get();
    var list = [];
    if (postId.docs.isNotEmpty) {
      postId.docs.forEach((element) {
        list.add(element.data());
      });
    }
    var postID = list[0]['postId'];
    return postID;
  }

  void reportPost(
      postId, BuildContext context, TypeOfReport typeOfReport, createdBy) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => ReportUser(
              // currentUserUID: widget.currentUserId,
              currentUserUID: userData.uid,
              // secondUserUID: widget.textPostModel.createdBy,
              secondUserUID: createdBy,

              typeOfReport: typeOfReport,
              mediaID: postId,
            ));
  }

  setCurrentPostTappedIndex(int index) {
    currentPostIndex = index;
    notifyListeners();
  }

  setCommentTapped() {
    if (isCommentTapped) {
      isCommentTapped = false;
    } else {
      isCommentTapped = true;
    }
    notifyListeners();
  }

  postComment(String postId, String createdBy, BuildContext context) {
    if (commentController.text.isEmpty) {
      return Fluttertoast.showToast(
          msg: "Comment can't be empty",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      comments(postId, createdBy, context);
      Fluttertoast.showToast(
          msg: "Commented",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> navigateToUnkwonScreen(
    String otherUserData,
    String currentUser,
    BuildContext context,
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

     await showDialog(
          context: context,
          builder: (thisContext) {
            return UnknownInfo(
              _matchedUserData,
              _currentUserUserData,
            );
          }).whenComplete(() async {});
    }
  }

  Future voteToPoll(int value, String pollId) async {
    QuerySnapshot<Map<String, dynamic>> queryDocumentSnapshot =
        await FirebaseFirestore.instance
            .collection("Post")
            .where("id", isEqualTo: pollId)
            .get();
    if (queryDocumentSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data = queryDocumentSnapshot.docs[0].data();
      List data1 = data['PollOption'];
      data1[value] = {
        "option": data1[value]['option'],
        'voteCount': data1[value]['voteCount'] + 1,
      };
      queryDocumentSnapshot.docs[0].reference
          .update({"PollOption": data1}).whenComplete(() async {});
      print("All Done");
      print("publish");
      print(pollId);
      DocumentSnapshot<Map<String, dynamic>> votesDocument =
          await FirebaseFirestore.instance.collection("Post").doc(pollId).get();
      print(votesDocument);
      var votesCollection = await FirebaseFirestore.instance
          .collection("Post")
          .doc(pollId)
          .collection("VotedBy");
      QuerySnapshot document = await votesCollection.get().then((value) {});

      print(document);

      if (document == null || document.docs.isEmpty) {
        var ref =  FirebaseFirestore.instance
            .collection("Post")
            .doc(pollId)
            .collection("VotedBy")
            .doc();
        ref.set({
          "voteBy": firebaseController.firebaseAuth.currentUser.uid,
          "voteid": ref.id,
          "pollId": pollId,
          "answerOption": value,
          "createdAt": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
      } else {
        var ref =  FirebaseFirestore.instance
            .collection("Post")
            .doc(pollId)
            .collection("VotedBy")
            .doc();
        ref.set({
          "voteBy": firebaseController.firebaseAuth.currentUser.uid,
          "voteid": ref.id,
          "pollId": pollId,
          "answerOption": value,
          "createdAt": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
      }
    }

  }
}
