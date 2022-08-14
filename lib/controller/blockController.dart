import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/variables.dart';
import 'package:easy_localization/easy_localization.dart';

class BlockUserController {
  final CollectionReference userCollRef = FirebaseFirestore.instance.collection(userCollectionName);
  CollectionReference blockedCollRef1;
  CollectionReference blockedCollRef2;

  Future<void> blockUser({@required String currentUserId, @required String anotherUserId}) async {
    try {
      blockedCollRef1 = userCollRef.doc(currentUserId).collection(blockedCollectionName);
      blockedCollRef2 = userCollRef.doc(anotherUserId).collection(blockedCollectionName);
      Map<String, dynamic> blockedMap = BlockedUserModel(blockedBy: currentUserId, blockedTo: anotherUserId, createdAt: Timestamp.now(), blockedAt: BlockedAt.profile).toJson();

      blockedCollRef1.add(blockedMap).catchError((e) {
        Fluttertoast.showToast(
            msg: "Something Went Wrong".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }).then((value) {
        blockedCollRef2.add(blockedMap).catchError((e) {
          //something went wrong toast
          Fluttertoast.showToast(
              msg: "Something Went Wrong".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
          blockedCollRef1.where("blockedBy", isEqualTo: currentUserId).get().then((value) {
            if (value.docs.isNotEmpty) {
              blockedCollRef1.doc(value.docs[0].id).delete();
            }
          });
        }).then((value) {
          Fluttertoast.showToast(
              msg: "Blocked!".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      });
    } catch (e) {
      print("Error (BlockController->addBlockedUser) : $e");
    }
  }

  //UnBlock User
  Future<void> unblockUser({@required String currentUserId, @required String anotherUserId}) async {
    blockedCollRef1 = userCollRef.doc(currentUserId).collection(blockedCollectionName);
    blockedCollRef2 = userCollRef.doc(anotherUserId).collection(blockedCollectionName);

    //unblock from user 1
    blockedCollRef1.where("blockedBy", isEqualTo: currentUserId).get().then((value) {
      if (value.docs.isNotEmpty) {
        blockedCollRef1.doc(value.docs[0].id).delete().then((value) {
          blockedCollRef2.where("blockedBy", isEqualTo: currentUserId).get().then((value) {
            if (value.docs.isNotEmpty) {
              blockedCollRef2.doc(value.docs[0].id).delete().then((value) {
                //flutter toast unbocked!!
                Fluttertoast.showToast(
                    msg: "Unblocked!".tr(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.blueGrey,
                    textColor: Colors.white,
                    fontSize: 16.0);
              });
            }
          });
        });
      }
    }).catchError((e) {
    });

    //unblock from user 2
  }

  //Check User Blocked Or Not
  Future<BlockedUserModel> blockedExistOrNot({@required String currentUserId, @required String anotherUserId}) async {
    try {
      blockedCollRef1 = userCollRef.doc(currentUserId).collection(blockedCollectionName);
      QuerySnapshot snapshot = await blockedCollRef1.where("blockedTo", isEqualTo: currentUserId).where("blockedBy", isEqualTo: anotherUserId).get().catchError((onError) {
        print("Error (BlockController -> snapshotError) : $onError");
        return null;
      });
      if (snapshot.docs.isNotEmpty) {
        return BlockedUserModel.fromDocument(snapshot.docs[0]);
      } else {
        QuerySnapshot snapshot = await blockedCollRef1.where("blockedTo", isEqualTo: anotherUserId).where("blockedBy", isEqualTo: currentUserId).get().catchError((onError) {
          print("Error (BlockController -> snapshotError) : $onError");
          return null;
        });
        if (snapshot.docs.isNotEmpty) {
          return BlockedUserModel.fromDocument(snapshot.docs[0]);
        }
      }
      return null;
    } catch (e) {
      print("Error (BlockController->checkBLockedUser) : $e");
      return null;
    }
  }
}
