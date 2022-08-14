import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/models/reportModel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import '../Screens/Information.dart';
import '../Theme/colors.dart';
import '../Theme/theme_provider.dart';
import '../common/Utils.dart';
import '../controller/FirebaseController.dart';
import '../models/createAccountData.dart';
import '../widgets/LinearProgressBar.dart';

class AdminReports extends StatefulWidget {
  @override
  _AdminReportsState createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  GlobalKey<State<Tooltip>> toolTipKeyProgressBar = GlobalKey<State<Tooltip>>();
  CollectionReference docRef = FirebaseFirestore.instance.collection('Reports');

  FirebaseController firebaseController = FirebaseController();
  CreateAccountData userData;
  double screenWidth;
  List<ReportModel> tempreportUsData;
  List<ReportModel> myPostData;

  List<QueryDocumentSnapshot> tempreportDocs = [];
  bool hasMore = true;
  bool isLoading = false;
  DocumentSnapshot lastDocument;
  int intdocLimit = 10;
  ScrollController _scrollController = ScrollController();
  bool isRead = false;
  SharedPreferences prefs;
  CreateAccountData currentUser;

  CreateAccountData otherUserData;

  Future<CreateAccountData> getUser() async {
    currentUser = await firebaseController.currentUserData;
    return currentUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    loadPost();
    getUser().then((value) async {
      prefs = await SharedPreferences.getInstance();
    });
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        loadPost();
      }
    });
    super.initState();
  }

  Query myPostQuery() {
    return FirebaseFirestore.instance
        .collection('Reports')
        .orderBy("timestamp", descending: true);
  }

  Future<void> loadPost() async {
    try {
      if (!hasMore) {
        print("No More Post");
        return;
      }
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });

      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        tempreportUsData = [];
        myPostData = [];
        querySnapshot = await myPostQuery().limit(intdocLimit).get();
      } else {
        querySnapshot = await myPostQuery()
            .limit(intdocLimit)
            .startAfterDocument(lastDocument)
            .get();
      }

      if (querySnapshot.docs.length <= 0) {
        hasMore = false;
        print("No Post Found");
      } else {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }

      querySnapshot.docs.forEach((element) {
        tempreportUsData.add(ReportModel.fromDocument(element));
      });

      print("reportsDocs: $intdocLimit");

      if (tempreportUsData.length < intdocLimit) {
        if (mounted)
          setState(() {
            isLoading = false;
          });
        loadPost();
      }

      print("Report us Length : ${tempreportUsData.length}");
      if (mounted)
        setState(() {
          myPostData.addAll(tempreportUsData);
          tempreportUsData.clear();
          isLoading = false;
        });
      print("Report Post Length: ${myPostData.length}");
    } catch (e) {
      print("Error: (My Report Us Load More): $e");
    }
  }

  Future<ReportModel> getLatestPostlDetail({@required String postId}) async {
    try {
      return ReportModel.fromDocument(await docRef.doc(postId).get());
    } catch (e) {
      return null;
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = new DateFormat('d-MM-y - hh:mm a');
    return format.format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mRed,
        title: Text("Reports"),
        centerTitle: true,
        elevation: 0,
      ),
      body: myPostData == null
          ? Center(
              child: LinearProgressCustomBar(),
            )
          : myPostData.isEmpty
              ? Center(
                  child: Text("No Data"),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Expanded(
                          child: RefreshIndicator(
                        key: UniqueKey(),
                        color: Colors.white,
                        backgroundColor: mRed,
                        onRefresh: () async {
                          lastDocument = null;
                          hasMore = true;
                          isLoading = false;
                          //myPostData = [];
                          return loadPost();
                        },
                        child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(10.0),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: myPostData.length,
                            itemBuilder: (context, index) {
                              if (myPostData[index] is ReportModel) {
                                ReportModel currentPost = myPostData[index];

                                return currentPost.type.contains('profile')
                                    ? Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.blueGrey, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        color: themeProvider.isDarkMode
                                            ? black
                                            : white,
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                child: Container(
                                                  // decoration: BoxDecoration(
                                                  //   color: mRed,
                                                  //   borderRadius: BorderRadius.only(
                                                  //     topLeft: Radius.circular(22),
                                                  //     bottomLeft: Radius.circular(22),
                                                  //     bottomRight:
                                                  //         Radius.circular(22),
                                                  //     topRight: Radius.circular(22),
                                                  //   ),
                                                  // ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Center(
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0),
                                                            child: Text(
                                                                Utils().convertToAgoAndDate(
                                                                    currentPost
                                                                        .timestamp
                                                                        .millisecondsSinceEpoch),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20))),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              currentPost.isRead ==
                                                                      false
                                                                  ? docRef
                                                                      .doc(currentPost
                                                                          .docID)
                                                                      .update({
                                                                      "isRead":
                                                                          true,
                                                                    }).then(
                                                                          (_) {
                                                                      Fluttertoast.showToast(
                                                                          msg:
                                                                              "Read!!",
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              3,
                                                                          backgroundColor: Colors
                                                                              .blueGrey,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                      print(
                                                                          'isRead: $isRead');
                                                                    })
                                                                  : docRef
                                                                      .doc(currentPost
                                                                          .docID)
                                                                      .update({
                                                                      "isRead":
                                                                          false,
                                                                    }).then(
                                                                          (_) {
                                                                      Fluttertoast.showToast(
                                                                          msg:
                                                                              "UnRead!!",
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              3,
                                                                          backgroundColor: Colors
                                                                              .blueGrey,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                      print(
                                                                          'isRead: $isRead');
                                                                    });
                                                            },
                                                            child: Container(
                                                              child: currentPost
                                                                          .isRead ==
                                                                      true
                                                                  ? Icon(
                                                                      CupertinoIcons
                                                                          .check_mark_circled,
                                                                      size:
                                                                          26.0,
                                                                    )
                                                                  : Icon(
                                                                      CupertinoIcons
                                                                          .check_mark_circled_solid,
                                                                      size:
                                                                          26.0,
                                                                      color:
                                                                          mRed,
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  currentPost.type
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              Column(
                                                children: [
                                                  Center(
                                                      child: Text(
                                                    "Reason",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                  Container(
                                                    height: 50,
                                                    child: GestureDetector(
                                                        onTap: () =>
                                                            detailDialog(
                                                                context,
                                                                currentPost
                                                                    .reason),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              currentPost
                                                                  .reason,
                                                              maxLines: 3,
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              Column(
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      "Reported against:-",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        var otherUser =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(currentPost
                                                                    .victim_id)
                                                                .get();
                                                        if (otherUser != null) {
                                                          otherUserData =
                                                              CreateAccountData
                                                                  .fromDocument(
                                                                      otherUser
                                                                          .data());
                                                        }
                                                        showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder: (context) {
                                                              return Info(
                                                                  otherUserData,
                                                                  currentUser);
                                                            });
                                                      },
                                                      child: Text(
                                                          currentPost.victim_id,
                                                          style: TextStyle(
                                                              fontSize: 17)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              Column(
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      "Reported by:-",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        var otherUser =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(currentPost
                                                                    .reported_by)
                                                                .get();
                                                        if (otherUser != null) {
                                                          otherUserData =
                                                              CreateAccountData
                                                                  .fromDocument(
                                                                      otherUser
                                                                          .data());
                                                        }
                                                        showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder: (context) {
                                                              return Info(
                                                                  otherUserData,
                                                                  currentUser);
                                                            });
                                                      },
                                                      child: Text(
                                                          currentPost
                                                              .reported_by,
                                                          style: TextStyle(
                                                              fontSize: 17)),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : currentPost.type.contains('post') ||
                                            currentPost.type.contains('poll') ||
                                            currentPost.type
                                                .contains('Explore Plan')
                                        ? Card(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.blueGrey,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            color: themeProvider.isDarkMode
                                                ? black
                                                : white,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 50,
                                                    child: Container(
                                                      // decoration: BoxDecoration(
                                                      //   color: mRed,
                                                      //   borderRadius: BorderRadius.only(
                                                      //     topLeft: Radius.circular(22),
                                                      //     bottomLeft: Radius.circular(22),
                                                      //     bottomRight:
                                                      //         Radius.circular(22),
                                                      //     topRight: Radius.circular(22),
                                                      //   ),
                                                      // ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Center(
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text(
                                                                    Utils().convertToAgoAndDate(currentPost
                                                                        .timestamp
                                                                        .millisecondsSinceEpoch),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20))),
                                                          ),
                                                          Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  currentPost.isRead ==
                                                                          false
                                                                      ? docRef
                                                                          .doc(currentPost
                                                                              .docID)
                                                                          .update({
                                                                          "isRead":
                                                                              true,
                                                                        }).then(
                                                                              (_) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Read!!",
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 3,
                                                                              backgroundColor: Colors.blueGrey,
                                                                              textColor: Colors.white,
                                                                              fontSize: 16.0);
                                                                          print(
                                                                              'isRead: $isRead');
                                                                        })
                                                                      : docRef
                                                                          .doc(currentPost
                                                                              .docID)
                                                                          .update({
                                                                          "isRead":
                                                                              false,
                                                                        }).then(
                                                                              (_) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "UnRead!!",
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 3,
                                                                              backgroundColor: Colors.blueGrey,
                                                                              textColor: Colors.white,
                                                                              fontSize: 16.0);
                                                                          print(
                                                                              'isRead: $isRead');
                                                                        });
                                                                },
                                                                child:
                                                                    Container(
                                                                  child: currentPost
                                                                              .isRead ==
                                                                          true
                                                                      ? Icon(
                                                                          CupertinoIcons
                                                                              .check_mark_circled,
                                                                          size:
                                                                              26.0,
                                                                        )
                                                                      : Icon(
                                                                          CupertinoIcons
                                                                              .check_mark_circled_solid,
                                                                          size:
                                                                              26.0,
                                                                          color:
                                                                              mRed,
                                                                        ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      currentPost.type
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "Post Id:-",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            currentPost.mediaID,
                                                            style: TextStyle(
                                                                fontSize: 17)),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                        "Reason",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                      Container(
                                                        height: 50,
                                                        child: GestureDetector(
                                                            onTap: () =>
                                                                detailDialog(
                                                                    context,
                                                                    currentPost
                                                                        .reason),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  currentPost
                                                                      .reason,
                                                                  maxLines: 3,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.grey,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "Reported against:-",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var otherUser =
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(currentPost
                                                                        .victim_id)
                                                                    .get();
                                                            if (otherUser !=
                                                                null) {
                                                              otherUserData =
                                                                  CreateAccountData
                                                                      .fromDocument(
                                                                          otherUser
                                                                              .data());
                                                            }
                                                            showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Info(
                                                                      otherUserData,
                                                                      currentUser);
                                                                });
                                                          },
                                                          child: Text(
                                                              currentPost
                                                                  .victim_id,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.grey,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "Reported by:-",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var otherUser =
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(currentPost
                                                                        .reported_by)
                                                                    .get();
                                                            if (otherUser !=
                                                                null) {
                                                              otherUserData =
                                                                  CreateAccountData
                                                                      .fromDocument(
                                                                          otherUser
                                                                              .data());
                                                            }
                                                            showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Info(
                                                                      otherUserData,
                                                                      currentUser);
                                                                });
                                                          },
                                                          child: Text(
                                                              currentPost
                                                                  .reported_by,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : currentPost.type.contains('image') ||
                                                currentPost.type
                                                    .contains('storyImage')
                                            ? Card(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Colors.blueGrey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                color: themeProvider.isDarkMode
                                                    ? black
                                                    : white,
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 50,
                                                        child: Container(
                                                          // decoration: BoxDecoration(
                                                          //   color: mRed,
                                                          //   borderRadius: BorderRadius.only(
                                                          //     topLeft: Radius.circular(22),
                                                          //     bottomLeft: Radius.circular(22),
                                                          //     bottomRight:
                                                          //         Radius.circular(22),
                                                          //     topRight: Radius.circular(22),
                                                          //   ),
                                                          // ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Center(
                                                                child: Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                    child: Text(
                                                                        Utils().convertToAgoAndDate(currentPost
                                                                            .timestamp
                                                                            .millisecondsSinceEpoch),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20))),
                                                              ),
                                                              Center(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          8.0),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      currentPost.isRead ==
                                                                              false
                                                                          ? docRef.doc(currentPost.docID).update({
                                                                              "isRead": true,
                                                                            }).then(
                                                                              (_) {
                                                                              Fluttertoast.showToast(msg: "Read!!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                              print('isRead: $isRead');
                                                                            })
                                                                          : docRef
                                                                              .doc(currentPost.docID)
                                                                              .update({
                                                                              "isRead": false,
                                                                            }).then((_) {
                                                                              Fluttertoast.showToast(msg: "UnRead!!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                              print('isRead: $isRead');
                                                                            });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      child: currentPost.isRead ==
                                                                              true
                                                                          ? Icon(
                                                                              CupertinoIcons.check_mark_circled,
                                                                              size: 26.0,
                                                                            )
                                                                          : Icon(
                                                                              CupertinoIcons.check_mark_circled_solid,
                                                                              size: 26.0,
                                                                              color: mRed,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(
                                                        color: Colors.grey,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          currentPost.type
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Divider(
                                                        color: Colors.grey,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "Post Id:-",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                currentPost
                                                                    .mediaID,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17)),
                                                          )
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: Colors.grey,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "URL:-",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () => CommonSwipeWidget()
                                                                  .launchURL(
                                                                      currentPost
                                                                          .url),
                                                              child: Text(
                                                                  currentPost
                                                                      .url,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Center(
                                                              child: Text(
                                                            "Reason",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                          Container(
                                                            height: 50,
                                                            child:
                                                                GestureDetector(
                                                                    onTap: () => detailDialog(
                                                                        context,
                                                                        currentPost
                                                                            .reason),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Text(
                                                                          currentPost
                                                                              .reason,
                                                                          maxLines:
                                                                              3,
                                                                          style:
                                                                              TextStyle(fontSize: 17),
                                                                        ),
                                                                      ),
                                                                    )),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: Colors.grey,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "Reported against:-",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                var otherUser = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(currentPost
                                                                        .victim_id)
                                                                    .get();
                                                                if (otherUser !=
                                                                    null) {
                                                                  otherUserData =
                                                                      CreateAccountData.fromDocument(
                                                                          otherUser
                                                                              .data());
                                                                }
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return Info(
                                                                          otherUserData,
                                                                          currentUser);
                                                                    });
                                                              },
                                                              child: Text(
                                                                  currentPost
                                                                      .victim_id,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: Colors.grey,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              "Reported by:-",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                var otherUser = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(currentPost
                                                                        .reported_by)
                                                                    .get();
                                                                if (otherUser !=
                                                                    null) {
                                                                  otherUserData =
                                                                      CreateAccountData.fromDocument(
                                                                          otherUser
                                                                              .data());
                                                                }
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return Info(
                                                                          otherUserData,
                                                                          currentUser);
                                                                    });
                                                              },
                                                              child: Text(
                                                                  currentPost
                                                                      .reported_by,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : currentPost.type
                                                        .contains('video') ||
                                                    currentPost.type
                                                        .contains('storyVideo')
                                                ? Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              Colors.blueGrey,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    color:
                                                        themeProvider.isDarkMode
                                                            ? black
                                                            : white,
                                                    child: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 50,
                                                            child: Container(
                                                              // decoration: BoxDecoration(
                                                              //   color: mRed,
                                                              //   borderRadius: BorderRadius.only(
                                                              //     topLeft: Radius.circular(22),
                                                              //     bottomLeft: Radius.circular(22),
                                                              //     bottomRight:
                                                              //         Radius.circular(22),
                                                              //     topRight: Radius.circular(22),
                                                              //   ),
                                                              // ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Center(
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                8.0),
                                                                        child: Text(
                                                                            Utils().convertToAgoAndDate(currentPost
                                                                                .timestamp.millisecondsSinceEpoch),
                                                                            style:
                                                                                TextStyle(fontSize: 20))),
                                                                  ),
                                                                  Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              8.0),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          currentPost.isRead == false
                                                                              ? docRef.doc(currentPost.docID).update({
                                                                                  "isRead": true,
                                                                                }).then((_) {
                                                                                  Fluttertoast.showToast(msg: "Read!!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                  print('isRead: $isRead');
                                                                                })
                                                                              : docRef.doc(currentPost.docID).update({
                                                                                  "isRead": false,
                                                                                }).then((_) {
                                                                                  Fluttertoast.showToast(msg: "UnRead!!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                  print('isRead: $isRead');
                                                                                });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child: currentPost.isRead == true
                                                                              ? Icon(
                                                                                  CupertinoIcons.check_mark_circled,
                                                                                  size: 26.0,
                                                                                )
                                                                              : Icon(
                                                                                  CupertinoIcons.check_mark_circled_solid,
                                                                                  size: 26.0,
                                                                                  color: mRed,
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              currentPost.type
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "Post Id:-",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                    currentPost
                                                                        .mediaID,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              )
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "URL:-",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () => CommonSwipeWidget()
                                                                      .launchURL(
                                                                          currentPost
                                                                              .url),
                                                                  child: Text(
                                                                      currentPost
                                                                          .url,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "Thumbnail URL:-",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () => CommonSwipeWidget()
                                                                      .launchURL(
                                                                          currentPost
                                                                              .url),
                                                                  child: Text(
                                                                      currentPost
                                                                          .thumbnailUrl,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                  child: Text(
                                                                "Reason",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                              Container(
                                                                height: 50,
                                                                child:
                                                                    GestureDetector(
                                                                        onTap: () => detailDialog(
                                                                            context,
                                                                            currentPost
                                                                                .reason),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              currentPost.reason,
                                                                              maxLines: 3,
                                                                              style: TextStyle(fontSize: 17),
                                                                            ),
                                                                          ),
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "Reported against:-",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    var otherUser = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(currentPost
                                                                            .victim_id)
                                                                        .get();
                                                                    if (otherUser !=
                                                                        null) {
                                                                      otherUserData =
                                                                          CreateAccountData.fromDocument(
                                                                              otherUser.data());
                                                                    }
                                                                    showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return Info(
                                                                              otherUserData,
                                                                              currentUser);
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                      currentPost
                                                                          .victim_id,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: Colors.grey,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "Reported by:-",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    var otherUser = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(currentPost
                                                                            .reported_by)
                                                                        .get();
                                                                    if (otherUser !=
                                                                        null) {
                                                                      otherUserData =
                                                                          CreateAccountData.fromDocument(
                                                                              otherUser.data());
                                                                    }
                                                                    showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return Info(
                                                                              otherUserData,
                                                                              currentUser);
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                      currentPost
                                                                          .reported_by,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Card();
                              } else {
                                return Container();
                              }
                              ;
                            }),
                      )),
                    ],
                  ),
                ),
    );
  }

  void detailDialog(context, String detail) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Padding(
            padding: const EdgeInsets.only(top: 200.0, bottom: 200),
            child: SimpleDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.blueGrey.withOpacity(0.8),
              children: [
                Text("$detail",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 1.3,
                        fontFamily: 'Handlee',
                        fontWeight: FontWeight.w700,
                        color: white,
                        decoration: TextDecoration.none,
                        fontSize: 22)),
              ],
            ),
          );
        });
  }
}
