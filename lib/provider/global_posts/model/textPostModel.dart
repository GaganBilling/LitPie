import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class TextPostModel {
  final String createdBy, textPost, postId, type;
  int likesCount, commentsCount;
  final int createdAt;
  bool anonymously;

  TextPostModel({
    @required this.textPost,
    @required this.createdBy,
    @required this.createdAt,
    @required this.anonymously,
    @required this.postId,
    @required this.type,
    @required this.likesCount,
    @required this.commentsCount,
  });

  Map<String, dynamic> toJson() => {
    "textPost": textPost,
    "createdBy": createdBy,
    "createdAt": createdAt,
    "anonymously": anonymously,
    "postId": postId,
    "type": type,
    "likesCount": likesCount,
    "commentsCount": commentsCount,
  };

  factory TextPostModel.fromJson(Map<String, dynamic> json) {
    return TextPostModel(
        textPost: json['textPost'],
        createdBy: json['createdBy'],
        createdAt: json['createdAt'],
        anonymously: json['anonymously'],
        postId: json['postId'],
        likesCount: json['likesCount'],
        commentsCount: json['commentsCount'],
        type: json['type']);
  }

  factory TextPostModel.fromDocument(DocumentSnapshot doc) {
    return TextPostModel(
      textPost: doc["textPost"],
      createdBy: doc['createdBy'],
      createdAt: doc["createdAt"],
      postId: doc["postId"],
      likesCount: doc["likesCount"],
      anonymously: doc['anonymously'] != null ? doc['anonymously'] : true,
      type: doc["type"],
      commentsCount: doc["commentsCount"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "textPost": textPost,
      "createdBy": createdBy,
      "createdAt": createdAt,
      "anonymously": anonymously,
      "postId": postId,
      "type": type,
      "likesCount": likesCount,
      "commentsCount": commentsCount,
    };
  }
}
