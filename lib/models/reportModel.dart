import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ReportModel {
  final String reported_by,
      reason,
      docID,
      mediaID,
      url,
      type,
      victim_id,
      thumbnailUrl;
  final Timestamp timestamp;
  bool isRead;

  ReportModel(
      {@required this.reported_by,
      this.reason,
      this.docID,
      this.thumbnailUrl,
      this.mediaID,
      this.url,
      this.type,
      this.victim_id,
      this.timestamp,
      this.isRead});

  Map<String, dynamic> toJson() => {
        "reported_by": reported_by,
        "reason": reason,
        "docID": docID,
        "timestamp": timestamp,
        "url": url,
        "mediaID": mediaID,
        "type": type,
        "victim_id": victim_id,
        "thumbnailUrl": thumbnailUrl,
        "isRead": isRead,
      };

  factory ReportModel.fromDocument(DocumentSnapshot doc) {
    return ReportModel(
      reported_by: doc.data().toString().contains("reported_by")
          ? doc.get("reported_by")
          : "",
      reason: doc.data().toString().contains("reason") ? doc.get("reason") : "",
      url: doc.data().toString().contains("url") ? doc.get("url") : "",
      docID: doc.data().toString().contains("docID") ? doc.get("docID") : "",
      mediaID:
          doc.data().toString().contains("mediaID") ? doc.get("mediaID") : "",
      type: doc.data().toString().contains("type") ? doc.get("type") : "",
      victim_id: doc.data().toString().contains("victim_id")
          ? doc.get("victim_id")
          : "",
      thumbnailUrl: doc.data().toString().contains("thumbnailUrl")
          ? doc.get("thumbnailUrl")
          : "",
      isRead: doc.data().toString().contains("isRead") ? doc.get("isRead") : "",
      timestamp: doc.data().toString().contains("timestamp")
          ? doc.get("timestamp")
          : "",
    );
  }
}
