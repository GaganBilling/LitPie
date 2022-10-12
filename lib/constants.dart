import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';

class Constants {
  final CollectionReference userCollRef =
      FirebaseFirestore.instance.collection(userCollectionName);

  String generateChatId(String currentUserUID, String anotherUserUID) {
    if (currentUserUID.hashCode <= anotherUserUID.hashCode) {
      return '$currentUserUID-$anotherUserUID';
    } else {
      return '$anotherUserUID-$currentUserUID';
    }
  }

  //Calculate Distance
  double calculateDistance(
      {@required CreateAccountData currentUser,
      @required CreateAccountData anotherUser}) {
    var lat1 = currentUser.coordinates['latitude'];
    var lon1 = currentUser.coordinates['longitude'];
    var lat2 = anotherUser.coordinates['latitude'];
    var lon2 = anotherUser.coordinates['longitude'];
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void setDeviceToken() async {
    String currentToken = "";
    await FirebaseMessaging.instance
        .getToken()
        .then((token) => currentToken = token);
    Map<String, dynamic> tokenDetail = {
      "token": currentToken,
      "last_login": FieldValue.serverTimestamp(),
      "uid": FirebaseAuth.instance.currentUser.uid,
      "platform": Platform.isIOS ? "IOS" : "ANDROID",
    };
    if (FirebaseAuth.instance.currentUser != null && currentToken.isNotEmpty) {
      deleteDeviceTokenAfter30Day();
     await userCollRef
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection(userDevicesCollectionName)
          .where("token", isEqualTo: currentToken)
          .get()
          .then((oldToken) async {
        if (oldToken.docs.length <= 0) {
          await  userCollRef
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection(userDevicesCollectionName)
              .add(tokenDetail);
        } else {
          String docId = "";
          oldToken.docs.forEach((tokens) {
            if (tokens.data()["token"] == currentToken) {
              docId = tokens.id;
            }
          });
          if (docId.isNotEmpty) {
            await userCollRef
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection(userDevicesCollectionName)
                .doc(docId)
                .update({
              "last_login": FieldValue.serverTimestamp(),
              "platform": Platform.isIOS ? "IOS" : "ANDROID",
            });
          }
        }
      }).catchError((err) {
        print("SET TOKEN ERROR: $err");
      });
    } else {
      print("Current User Not Set, Please Login");
    }
  }

  Future<void> deleteDeviceToken() async {
    String currentToken = "";
    await FirebaseMessaging.instance
        .getToken()
        .then((token) => currentToken = token);
    if (FirebaseAuth.instance.currentUser != null && currentToken.isNotEmpty) {
      await userCollRef
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection(userDevicesCollectionName)
          .where("token", isEqualTo: currentToken)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          await value.docs[0].reference.delete();
        }
      }).catchError((err) {
        print("Delete Device Token Error: $err");
      });
    }
  }

  Future<void> deleteDeviceTokenAfter30Day() async {
    Timestamp twoDayBeforeTimestamp =
        Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2)));
    await userCollRef
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection(userDevicesCollectionName)
        .where("last_login", isLessThan: twoDayBeforeTimestamp)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      }
    }).catchError((err) {
      print("Delete Device Token Error: $err");
    });
  }
}

class Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  Utf8LengthLimitingTextInputFormatter(this.maxLength)
      : assert(maxLength == null || maxLength == -1 || maxLength > 0);

  final int maxLength;

  // TextEditingController _utf8TextController = TextEditingController();

  static int bytesLength(String value) {
    return utf8.encode(value).length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength > 0 &&
        bytesLength(newValue.text) > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old value.
      if (bytesLength(oldValue.text) == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }

  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    var newValue = '';
    if (bytesLength(value.text) > maxLength) {
      var length = 0;

      value.text.characters.takeWhile((char) {
        var nbBytes = bytesLength(char);
        if (length + nbBytes <= maxLength) {
          newValue += char;
          length += nbBytes;
          return true;
        }
        return false;
      });
    }
    return TextEditingValue(
      text: newValue,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, newValue.length),
        extentOffset: min(value.selection.end, newValue.length),
      ),
      composing: TextRange.empty,
    );
  }
}
