/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/pollDataModel.dart';
import 'package:litpie/models/textPostModel.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:litpie/widgets/MyPollWidget.dart';
import 'package:litpie/widgets/MyTextPostWidget.dart';
import 'package:litpie/widgets/PollWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../variables.dart';
import 'createPoll.dart';
import 'createTextPost.dart';

class MyTextPostScreen extends StatefulWidget {
  @override
  _MyTextPostScreenState createState() => _MyTextPostScreenState();
}

class _MyTextPostScreenState extends State<MyTextPostScreen> {
  FirebaseController _firebaseController = FirebaseController();
  // Future<List<PollDataModel>> myPollsData;

  // List<PollDataModel> tempPollData;
  // List<PollDataModel> myPollsData;

  List<TextPostModel> myTextPostData;
  List<TextPostModel> tempTextPostData;

  // double _maxScreenWidth;

  //for loadmore
  bool hasMore = true;
  bool isLoading = false;
  DocumentSnapshot lastDocument;
  int docLimit = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // getMyPollsWithLoadMore();
    getMyTextPostWithLoadMore();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        // getMyPollsWithLoadMore();
        getMyTextPostWithLoadMore();
      }
    });
    super.initState();
  }

  // Query myPollQuery() {
  //   // return _firebaseController.pollColReference
  //   //     .where("PollQuestion.createdBy",
  //   //         isEqualTo: _firebaseController.currentFirebaseUser.uid)
  //   //     .orderBy("PollQuestion.createdAt", descending: true);
  //   return _firebaseController.postColReference
  //       .where("createdBy",
  //           isEqualTo: _firebaseController.currentFirebaseUser.uid)
  //       .orderBy("createdAt", descending: true);
  // }
  //
  // Future<void> getMyPollsWithLoadMore() async {
  //   try {
  //     if (!hasMore) {
  //       print('No More Polls');
  //       return;
  //     }
  //     if (isLoading) return;
  //     setState(() {
  //       isLoading = true;
  //     });
  //     QuerySnapshot querySnapshot;
  //     if (lastDocument == null) {
  //       tempPollData = [];
  //       myPollsData = [];
  //       querySnapshot = await myPollQuery().limit(docLimit).get();
  //     } else {
  //       querySnapshot = await myPollQuery()
  //           .limit(docLimit)
  //           .startAfterDocument(lastDocument)
  //           .get();
  //     }
  //     if (querySnapshot.docs.length <= 0) {
  //       hasMore = false;
  //       print("No Polls Found");
  //     } else {
  //       lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
  //     }
  //     querySnapshot.docs.forEach((element) {
  //       tempPollData.add(PollDataModel.fromDocument(element));
  //     });
  //
  //     if (mounted)
  //       setState(() {
  //         myPollsData.addAll(tempPollData);
  //         tempPollData.clear();
  //         isLoading = false;
  //       });
  //     print("Polls Length: ${myPollsData.length}");
  //   } catch (e) {
  //     print("Error: (MyPollsLoadMore): $e");
  //   }
  // }

  Query myTextPostQuery() {
    return _firebaseController.postColReference
        .where("createdBy",
            isEqualTo: _firebaseController.currentFirebaseUser.uid)
        .orderBy("createdAt", descending: true);
  }

  Future<void> getMyTextPostWithLoadMore() async {
    try {
      if (!hasMore) {
        print('No More Polls');
        return;
      }
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });
      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        tempTextPostData = [];
        myTextPostData = [];
        querySnapshot = await myTextPostQuery().limit(docLimit).get();
      } else {
        querySnapshot = await myTextPostQuery()
            .limit(docLimit)
            .startAfterDocument(lastDocument)
            .get();
      }
      if (querySnapshot.docs.length <= 0) {
        hasMore = false;
        print("No Text Post Found");
      } else {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }
      querySnapshot.docs.forEach((element) {
        tempTextPostData.add(TextPostModel.fromDocument(element));
      });

      if (mounted)
        setState(() {
          myTextPostData.addAll(tempTextPostData);
          tempTextPostData.clear();
          isLoading = false;
        });
      print("Posts Length: ${myTextPostData.length}");
    } catch (e) {
      print("Error: (MyTextPostLoadMore): $e");
    }
  }

  double _screenWidth;

  Future createDialog(context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        //barrierDismissible: false,
        context: context,
        builder: (BuildContext buildContext) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: .0, right: .0, bottom: 0),
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? dRed : white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(
                    0,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Material(
                          color: themeProvider.isDarkMode ? dRed : white,
                          child: Text(
                            "The post will be public and anybody can express their opinion,\n"
                            "Seek professional help if needed.",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        message: "Create Poll".tr(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 60, right: 60),
                          height: 50,
                          child: ElevatedButton(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    _screenWidth >= miniScreenWidth ? 220 : 180,
                              ),
                              child: Text(
                                "Create Poll".tr(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 16
                                        : 14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => CreatePollScrenn()))
                                  .whenComplete(() {
                                lastDocument = null;
                                hasMore = true;
                                isLoading = false;
                                getMyTextPostWithLoadMore();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              // padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7)),
                            ),
                          ),
                        ),
                      ),
                      ),
                      SizedBox(
                        height: _screenWidth >= miniScreenWidth ? 15 : 12,
                      ),
                      Tooltip(
                        message: "Ask/Confess/Share",
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 60, right: 60),
                          height: 50,
                          child: ElevatedButton(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    _screenWidth >= miniScreenWidth ? 220 : 180,
                              ),
                              child: Text(
                                "Ask/Confess/Share",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 16
                                        : 14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => createTextPost()))
                                  .whenComplete(() {
                                ///todo
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              // padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Posts"),
        centerTitle: true,
        elevation: 0,
        actions: [
          //todo
          if (myTextPostData != null)
            if (myTextPostData.isNotEmpty)
              IconButton(
                  icon: Icon(
                    Icons.add_chart,
                    color: mRed,
                    size: 30.0,
                  ),
                  splashRadius: 26.0,
                  onPressed: () async {
                    createDialog(context);
                  }
                  //   await Navigator.of(context)
                  //       .push(MaterialPageRoute(
                  //           builder: (context) => CreatePollScrenn()))
                  //       .whenComplete(() {
                  //     lastDocument = null;
                  //     hasMore = true;
                  //     isLoading = false;
                  //     getMyPollsWithLoadMore();
                  //   });
                  // }
                  ),
        ],
      ),
      body: myTextPostData == null
          ? Center(
              child: LinearProgressCustomBar(),
            )
          : myTextPostData.isEmpty
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: lRed,
                              radius: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.poll_rounded,
                                size: 85,
                                color: white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "You don't have any POLL to watch.\n It's time to create your own anonymous POLL now and have public opinion on it."
                              .tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Handlee',
                              fontWeight: FontWeight.w700,
                              color: lRed,
                              decoration: TextDecoration.none,
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 25 : 18),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Tooltip(
                        message: "Create Poll".tr(),
                        preferBelow: false,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          height: 50,
                          child: ElevatedButton(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              child: Text("Create Poll".tr(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 17
                                          : 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                            onPressed: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => CreatePollScrenn()))
                                  .whenComplete(() {
                                lastDocument = null;
                                hasMore = true;
                                isLoading = false;
                                getMyTextPostWithLoadMore();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 60.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Tooltip(
                        message: "Ask/Confess/Share",
                        preferBelow: false,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          height: 50,
                          child: ElevatedButton(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              child: Text("Ask/Confess/Share",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 17
                                          : 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                            onPressed: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => createTextPost()))
                                  .whenComplete(() {
                                //todo
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 60.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: Colors.white,
                          backgroundColor: mRed,
                          onRefresh: () {
                            lastDocument = null;
                            hasMore = true;
                            isLoading = false;
                            return getMyTextPostWithLoadMore();
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            padding: EdgeInsets.all(10.0),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: myTextPostData.length,
                            itemBuilder: (context, index) {
                              // PollDataModel currentPoll = myPollsData[index];
                              TextPostModel currentTextPost =
                                  myTextPostData[index];
                              return MyTextPostWidget(
                                textPostModel: currentTextPost,
                                currentUserId:
                                    _firebaseController.currentFirebaseUser.uid,
                                pollType: PollsType.creator,
                                textpostRef:
                                    _firebaseController.postColReference,
                                deletePollPressed: () async {
                                  if (currentTextPost.createdBy ==
                                      _firebaseController
                                          .currentFirebaseUser.uid) {
                                    _firebaseController.postColReference
                                        .doc(currentTextPost.postId)
                                        .delete()
                                        .catchError((e) {
                                      Fluttertoast.showToast(
                                          msg: "Poll Deletion Failed!!".tr(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.blueGrey,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }).then((value) {
                                      Fluttertoast.showToast(
                                          msg: "Poll Deleted Successfully!!"
                                              .tr(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.blueGrey,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    });
                                  }
                                  lastDocument = null;
                                  hasMore = true;
                                  getMyTextPostWithLoadMore();
                                },
                              );
                            },
                          ),
                          // ListView.builder(
                          //   controller: _scrollController,
                          //   padding: EdgeInsets.all(10.0),
                          //   physics: AlwaysScrollableScrollPhysics(),
                          //   itemCount: myPollsData.length,
                          //   itemBuilder: (context, index) {
                          //     PollDataModel currentPoll = myPollsData[index];
                          //     // PollDataModel currentTextPost =
                          //     //     myPollsData[index];
                          //     return MyPollWidget(
                          //       pollDataModel: currentPoll,
                          //       currentUserId:
                          //           _firebaseController.currentFirebaseUser.uid,
                          //       pollType: PollsType.creator,
                          //       pollRef: _firebaseController.postColReference,
                          //       deletePollPressed: () async {
                          //         if (currentPoll.pollQuestion.createdBy ==
                          //             _firebaseController
                          //                 .currentFirebaseUser.uid) {
                          //           _firebaseController.postColReference
                          //               .doc(currentPoll.pollId)
                          //               .delete()
                          //               .catchError((e) {
                          //             Fluttertoast.showToast(
                          //                 msg: "Poll Deletion Failed!!".tr(),
                          //                 toastLength: Toast.LENGTH_SHORT,
                          //                 gravity: ToastGravity.BOTTOM,
                          //                 timeInSecForIosWeb: 3,
                          //                 backgroundColor: Colors.blueGrey,
                          //                 textColor: Colors.white,
                          //                 fontSize: 16.0);
                          //           }).then((value) {
                          //             Fluttertoast.showToast(
                          //                 msg: "Poll Deleted Successfully!!"
                          //                     .tr(),
                          //                 toastLength: Toast.LENGTH_SHORT,
                          //                 gravity: ToastGravity.BOTTOM,
                          //                 timeInSecForIosWeb: 3,
                          //                 backgroundColor: Colors.blueGrey,
                          //                 textColor: Colors.white,
                          //                 fontSize: 16.0);
                          //           });
                          //         }
                          //         lastDocument = null;
                          //         hasMore = true;
                          //         getMyPollsWithLoadMore();
                          //       },
                          //     );
                          //   },
                          // ),
                        ),
                      ),
                      if (isLoading)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5),
                          child: Center(child: LinearProgressCustomBar()),
                        )
                    ],
                  ),
                ),
    );
  }
}

// MyTextPostWidget(
//   texPostModel: currentTextPost,
//   currentUserId: _firebaseController
//       .currentFirebaseUser.uid,
//   textPostType: PollsType.creator,
//   textpostRef:
//       _firebaseController.postColReference,
//   deletePollPressed: () async {
//     if (currentTextPost.createdBy ==
//         _firebaseController
//             .currentFirebaseUser.uid) {
//       _firebaseController.postColReference
//           .doc(currentTextPost.postId)
//           .delete()
//           .catchError((e) {
//         Fluttertoast.showToast(
//             msg:
//                 "Poll Deletion Failed!!".tr(),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 3,
//             backgroundColor: Colors.blueGrey,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }).then((value) {
//         Fluttertoast.showToast(
//             msg: "Poll Deleted Successfully!!"
//                 .tr(),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 3,
//             backgroundColor: Colors.blueGrey,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       });
//     }
//     lastDocument = null;
//     hasMore = true;
//     getMyTextPostWithLoadMore();
//   },
// ),
*/
