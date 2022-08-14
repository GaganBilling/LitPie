import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ContactUsModel {
  final String contacted_by, docID;
  final String message;
  final String uid;
  final Timestamp timestamp;
  bool isRead;

  ContactUsModel(
      {@required this.contacted_by,
      this.message,
      this.docID,
      this.uid,
      this.timestamp,
      this.isRead});

  Map<String, dynamic> toJson() => {
        "contacted_by": contacted_by,
        "message": message,
        "timestamp": timestamp,
        "uid": uid,
        "isRead": isRead,
        "docID": docID,
      };

  factory ContactUsModel.fromDocument(DocumentSnapshot doc) {
    return ContactUsModel(
        contacted_by: doc["contacted_by"],
        message: doc["message"],
        uid: doc["uid"],
        isRead: doc["isRead"],
        timestamp: doc["timestamp"],
        docID: doc['docID']);
  }
}
