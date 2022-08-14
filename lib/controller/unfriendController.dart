import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/models/unfriendModel.dart';
import 'package:litpie/variables.dart';

class UnFriendController {
  final CollectionReference userCollRef = FirebaseFirestore.instance.collection(userCollectionName);
  FirebaseDatabase db = FirebaseDatabase();

  Future<void> unFriendUser({@required String currentUserId, @required String anotherUserId}) async {
    DatabaseReference chatRef = db.reference().child("chats").child(Constants().generateChatId(currentUserId, anotherUserId));

    Map<String, dynamic> unFriendMap = UnFriendModel(unFriendBy: currentUserId, unFriendTo: anotherUserId, createdAt: Timestamp.now()).toJson();

    //Add To new collection in user's Collection
    userCollRef.doc(currentUserId).collection(unFriendCollectionName).add(unFriendMap);
    userCollRef.doc(anotherUserId).collection(unFriendCollectionName).add(unFriendMap);

    //Delete From Plan Request
    userCollRef.doc(currentUserId).collection(planRequestCollectionName).doc(anotherUserId).delete().catchError((e) {});
    userCollRef.doc(anotherUserId).collection(planRequestCollectionName).doc(currentUserId).delete().catchError((e) {});

    //Delete From Matches
    userCollRef.doc(currentUserId).collection(matchesCollectionName).doc(anotherUserId).delete().catchError((e) {});
    userCollRef.doc(anotherUserId).collection(matchesCollectionName).doc(currentUserId).delete().catchError((e) {});

    print(Constants().generateChatId(currentUserId, anotherUserId));
    //Delete From Chats
    chatRef.remove().catchError((e) {});
  }
}
