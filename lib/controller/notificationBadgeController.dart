import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationBadgeController extends ChangeNotifier {
  CollectionReference docRef = FirebaseFirestore.instance.collection('users');
  CollectionReference planRef = FirebaseFirestore.instance.collection('Plans');
  CollectionReference notRef =
      FirebaseFirestore.instance.collection('Notifications');

  bool matchNotificationCountFound = false;
  bool planNotificationCountFound = false;
  bool rNotificationCountFound = false;
  bool likeNotificationCountFound = false;
  bool commentNotificationCountFound = false;
}
