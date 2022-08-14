import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UnFriendModel {
  final String unFriendBy;
  final String unFriendTo;
  final Timestamp createdAt;

  UnFriendModel({
    @required this.unFriendBy,
    @required this.unFriendTo,
    @required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "unFriendBy": unFriendBy,
    "unFriendTo": unFriendTo,
    "createdAt": createdAt,
  };

  factory UnFriendModel.fromDocument(DocumentSnapshot doc) {
    return UnFriendModel(
      unFriendBy: doc["unFriendBy"],
      unFriendTo: doc["unFriendTo"],
      createdAt: doc["createdAt"],
    );
  }
}
