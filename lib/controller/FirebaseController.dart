import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:litpie/provider/global_posts/model/textPostModel.dart';
import 'package:litpie/variables.dart';

class FirebaseController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final User currentFirebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userColReference =
      FirebaseFirestore.instance.collection(userCollectionName);
  final CollectionReference pollColReference =
      FirebaseFirestore.instance.collection(pollCollectionName);
  final CollectionReference postColReference =
      FirebaseFirestore.instance.collection(postCollectionName);
  final CollectionReference likeDislikeCountColReference =
      FirebaseFirestore.instance.collection(likeDislikeCollectionName);
  final CollectionReference notificationColReference =
      FirebaseFirestore.instance.collection(notificationCollectionName);
  final CollectionReference planColReference =
      FirebaseFirestore.instance.collection(plansCollectionName);

  CreateAccountData cUserData;

  FirebaseController() {
    init();
  }

  init() async {
    if (firebaseAuth.currentUser != null)
      cUserData = await getCurrentUserData();
  }

  Future<CreateAccountData> get currentUserData async {
    if (cUserData != null) {
      return cUserData;
    } else {
      CreateAccountData data = await getCurrentUserData();
      return data;
    }
  }

  Future<CreateAccountData> getCurrentUserData() async {
    try {
      if (firebaseAuth.currentUser != null) {
        DocumentSnapshot currentUserDoc =
            await userColReference.doc(firebaseAuth.currentUser.uid).get();
        if (currentUserDoc["editInfo"] == null) {
          return null;
        }
        return CreateAccountData.fromDocument(currentUserDoc.data());
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<CreateAccountData> getUserData({@required String uid}) async {
    DocumentSnapshot currentUserDoc = await userColReference.doc(uid).get();
    return CreateAccountData.fromDocument(currentUserDoc.data());
  }

  Future<String> deleteUser({String email, String password}) async {
    print("Email :" + email + "Password:" + password);
    AuthCredential credentials =
        EmailAuthProvider.credential(email: email, password: password);
    UserCredential result = await currentFirebaseUser
        .reauthenticateWithCredential(credentials)
        .catchError((onError) {
      print("Error: $onError");
    });
    print(result);
    if (result == null) return "wrong-password";
    try {
      await Constants().deleteDeviceToken();
      await FirebaseFirestore.instance.terminate();
      FirebaseDatabase.instance.setPersistenceEnabled(false);
      await result.user.delete();
      return "success";
    } catch (e) {
      print("User Delete Error: $e");
      return "failed";
    }
  }

  Future<List<dynamic>> getPostPollDetail(String createdBy) async {
    List<dynamic> data = [];
    try {
      var event = await FirebaseFirestore.instance
          .collection(postCollectionName)
          .where("createdBy", isEqualTo: createdBy)
          .get();

      event.docs.forEach((value) {
        try {
          if (value["type"] != null) {
            if (value["type"] == "post") {
              data.add(TextPostModel.fromJson(value.data()));
            } else if (value["type"] == "poll") {
              data.add(PollDataModel.fromJson(value.data()));
            }
          }
        } catch (e) {
          print(e.toString());
        }
      });
      return data;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> getNotifications(String type, String uid, String id,
      createdUserId, int dateTime, bool isRead, String refId) async {
    print("dateTime=====${dateTime}");
    var notificationList = await FirebaseFirestore.instance
        .collection(notificationCollectionName)
        .limit(1)
        .get();
    try {
      if (notificationList.docs.isEmpty) {
        var ref = await FirebaseFirestore.instance
            .collection(notificationCollectionName)
            .doc();
        if (type == "1") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Matches",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == '2') {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Plan Request",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "3") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "LitPie",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "4") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Likes",
            "likedBy": uid,
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "5") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Comments",
            "commentBy": uid,
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        }
      } else if (notificationList.docs.length > 0) {
        var ref = await FirebaseFirestore.instance
            .collection(notificationCollectionName)
            .doc();
        if (type == "1") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Matches",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == '2') {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Plan Request",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "3") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "LitPie",
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "4") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Likes",
            "likedBy": uid,
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        } else if (type == "5") {
          ref.set({
            "CreatedUserId": createdUserId,
            "postId": id,
            "type": "Comments",
            "commentBy": uid,
            "createdAt": dateTime,
            "is_read": isRead,
            "_id": refId
          });
        }
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
