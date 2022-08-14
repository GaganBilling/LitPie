import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:litpie/models/createAccountData.dart';

class Notify {
  final CreateAccountData sender;
  final Timestamp time;
  final bool isRead;

  Notify({
    this.sender,
    this.time,
    this.isRead,
  });
}
