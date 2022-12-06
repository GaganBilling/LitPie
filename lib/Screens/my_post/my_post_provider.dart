import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:litpie/variables.dart';

class MyPostProvider extends ChangeNotifier {
  FirebaseController firebaseController = FirebaseController();
  CreateAccountData userdata;
  int currentIndex;
  List<PollDataModel> tempPollData;
  List<PollDataModel> myPollsData;
  List<dynamic> posts = [];
  List<dynamic> duplicatePostlist = [];
  bool isTapped = false;
  var commentList = [];
  List commentedUserDataList = [];
  bool isLoading = false;
  bool hasMore = true;
  bool isLoadingComment = false;
  DocumentSnapshot lastDocument;
  int docLimit = 10;
  bool isLoadingPost = false;

  //getUserData

  Future getUserdata() async {
    userdata = await firebaseController.getCurrentUserData();
    if (userdata != null) {
      await getAllPosts();
    }
    notifyListeners();
  }

  Future<void> getMyPollsWithLoadMore() async {
    try {
      if (!hasMore) {
        return;
      }
      if (isLoading) return;

      isLoading = true;
      notifyListeners();

      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        tempPollData = [];
        myPollsData = [];
        querySnapshot = await myPollQuery().limit(docLimit).get();
      } else {
        querySnapshot = await myPollQuery()
            .limit(docLimit)
            .startAfterDocument(lastDocument)
            .get();
      }
      if (querySnapshot.docs.length <= 0) {
        hasMore = false;
        print("No Polls Found");
      } else {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }
      querySnapshot.docs.forEach((element) {
        tempPollData.add(PollDataModel.fromDocument(element));
      });

      myPollsData.addAll(tempPollData);
      tempPollData.clear();
      isLoading = false;
      notifyListeners();

      print("Polls Length: ${myPollsData.length}");
    } catch (e) {
      print("Error: (MyPollsLoadMore): $e");
    }
  }

  myPollQuery() {
    return firebaseController.postColReference
        .where("createdBy",
            isEqualTo: firebaseController.currentFirebaseUser.uid)
        .orderBy("createdAt", descending: true);
  }

  myTextPostQuery() {
    return firebaseController.postColReference
        .where("createdBy",
            isEqualTo: firebaseController.currentFirebaseUser.uid)
        .orderBy("createdAt", descending: true);
  }

  showComments(String postId) async {
    commentList.clear();
    var event = await FirebaseFirestore.instance
        .collection(postCollectionName)
        .doc(postId)
        .collection(commentCollectionName)
        .get();
    event.docs.forEach((element) {
      commentList.add(element.data());
    });

    isLoadingComment = false;
    notifyListeners();
  }

  getCommentedUSerData(int index, postId) async {
    commentedUserDataList.clear();
    QuerySnapshot commentedUserData = await firebaseController.userColReference
        .where("uid", isEqualTo: duplicatePostlist[index].commentBy)
        .get();
    commentedUserData.docs.forEach((element) {
      commentedUserDataList.add(element.data());
    });
    return commentedUserDataList.toList();
  }

  void deletePost(String createdBy, String postId) {
    isLoadingPost = true;
    if (createdBy == firebaseController.currentFirebaseUser.uid) {
      firebaseController.postColReference.doc(postId).delete().catchError((e) {
        Fluttertoast.showToast(
            msg: "Post Deletion Failed!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }).then((value) {
        Fluttertoast.showToast(
            msg: "Post Deleted Successfully!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        getAllPosts();
      }).whenComplete(() async {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("Notifications")
            .where("postId", isEqualTo: postId)
            .get();
        if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.length > 0) {
          querySnapshot.docs.forEach((element) {
            element.reference.delete();
          });
        }
      });
    }
    notifyListeners();
  }

  Future getAllPosts() async {
    isLoadingPost = true;
    posts.clear();
    duplicatePostlist.clear();
    var data = await firebaseController.getPostPollDetail(userdata.uid);
    if (data != null) {
      isLoadingPost = false;
      posts.addAll(data);
      notifyListeners();
    } else {
      isLoadingPost = false;
    }
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    posts.forEach((element) {
      duplicatePostlist.add(element);
    });
    notifyListeners();
  }

  void changeCommentsVisibility(int index, String postId) {
    currentIndex = index;
    if (isTapped) {
      isTapped = false;
    } else {
      isTapped = true;
    }
    isLoadingComment = true;
    notifyListeners();
    showComments(postId);
  }
}
