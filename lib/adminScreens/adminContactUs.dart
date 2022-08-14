import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Theme/colors.dart';
import '../Theme/theme_provider.dart';
import '../common/Utils.dart';
import '../controller/FirebaseController.dart';
import '../models/contactUsModel.dart';
import '../models/createAccountData.dart';

class AdminContactUs extends StatefulWidget {
  // final ScrollController scrollController;
  // const AdminContactUs({Key key, this.scrollController}) : super(key: key);

  @override
  _AdminContactUsState createState() => _AdminContactUsState();
}

class _AdminContactUsState extends State<AdminContactUs> {
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  GlobalKey<State<Tooltip>> toolTipKeyProgressBar = GlobalKey<State<Tooltip>>();
  CollectionReference docRef =
      FirebaseFirestore.instance.collection('ContactUs');

  FirebaseController firebaseController = FirebaseController();
  CreateAccountData userData;
  double screenWidth;
  List<ContactUsModel> tempcontactUsData;
  List<ContactUsModel> myPostData;

  List<QueryDocumentSnapshot> tempcontactUsDocs = [];
  bool hasMore = true;
  bool isLoading = false;
  DocumentSnapshot lastDocument;
  int intdocLimit = 10;
  ScrollController _scrollController = ScrollController();
  bool isRead = false;
  SharedPreferences prefs;

  Future<CreateAccountData> getUser() async {
    userData = await firebaseController.currentUserData;
    return userData;
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
        .collection('ContactUs')
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
        tempcontactUsData = [];
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
        tempcontactUsData.add(ContactUsModel.fromDocument(element));
      });

      print("contactDocs: $intdocLimit");

      if (tempcontactUsData.length < intdocLimit) {
        if (mounted)
          setState(() {
            isLoading = false;
          });
        loadPost();
      }

      print("Contact us Length : ${tempcontactUsData.length}");
      if (mounted)
        setState(() {
          myPostData.addAll(tempcontactUsData);
          tempcontactUsData.clear();
          isLoading = false;
        });
      print("Contact Post Length: ${myPostData.length}");
    } catch (e) {
      print("Error: (My Contact Us Load More): $e");
    }
  }

  Future<ContactUsModel> getLatestPostlDetail({@required String postId}) async {
    try {
      return ContactUsModel.fromDocument(await docRef.doc(postId).get());
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
        title: Text("Contacted Us"),
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
                              if (myPostData[index] is ContactUsModel) {
                                ContactUsModel currentPost = myPostData[index];

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.blueGrey, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color:
                                      themeProvider.isDarkMode ? black : white,
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
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Center(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          Utils().convertToAgoAndDate(
                                                              currentPost
                                                                  .timestamp
                                                                  .millisecondsSinceEpoch),
                                                          style: TextStyle(
                                                              fontSize: 20))),
                                                ),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        currentPost.isRead ==
                                                                false
                                                            ? docRef
                                                                .doc(currentPost
                                                                    .docID)
                                                                .update({
                                                                "isRead": true,
                                                              }).then((_) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Read!!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .BOTTOM,
                                                                    timeInSecForIosWeb:
                                                                        3,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blueGrey,
                                                                    textColor:
                                                                        Colors
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
                                                                "isRead": false,
                                                              }).then((_) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "UnRead!!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .BOTTOM,
                                                                    timeInSecForIosWeb:
                                                                        3,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blueGrey,
                                                                    textColor:
                                                                        Colors
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
                                                                size: 26.0,
                                                              )
                                                            : Icon(
                                                                CupertinoIcons
                                                                    .check_mark_circled_solid,
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
                                        Column(
                                          children: [
                                            Center(
                                                child: Text(
                                              "Message",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            Container(
                                              height: 60,
                                              child: GestureDetector(
                                                  onTap: () => detailDialog(
                                                      context,
                                                      currentPost.message),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        currentPost.message,
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
                                                "Email:-",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  currentPost.contacted_by,
                                                  style:
                                                      TextStyle(fontSize: 17)),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
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
