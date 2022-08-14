import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

enum BlockedAt {chat, profile }

class BlockedUserModel {
  final String blockedBy;
  final String blockedTo;
  final Timestamp createdAt;
  final BlockedAt blockedAt;

  BlockedUserModel({
    @required this.blockedBy,
    @required this.blockedTo,
    @required this.createdAt,
    @required this.blockedAt,
  });

  Map<String, dynamic> toJson() => {
        "blockedBy": blockedBy,
        "blockedTo": blockedTo,
        "createdAt": createdAt,
        "blockedAt": blockedAt == BlockedAt.chat ? "chat" : "profile",
      };

  factory BlockedUserModel.fromDocument(DocumentSnapshot doc) {
    return BlockedUserModel(
      blockedBy: doc["blockedBy"],
      blockedTo: doc["blockedTo"],
      createdAt: doc["createdAt"],
      blockedAt: doc["blockedAt"] == "chat" ? BlockedAt.chat : BlockedAt.profile,
    );
  }
}
