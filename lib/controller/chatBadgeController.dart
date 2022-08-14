import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatBadgeController extends ChangeNotifier {
  CollectionReference docRef = FirebaseFirestore.instance.collection('users');

  bool chatNotificationCountFound = false;
  int newChatCount = 0;

  bool get isReadNotification => chatNotificationCountFound;
}
