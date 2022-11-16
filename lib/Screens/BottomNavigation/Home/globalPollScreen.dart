import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/Home/globalPoll/emptyGlobalPost.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:litpie/provider/global_posts/provider/globalPostProvider.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:litpie/widgets/MyPollWidget.dart';
import 'package:litpie/widgets/PollWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../../Theme/theme_provider.dart';

class GlobalPollScreen extends StatefulWidget {
  final ScrollController scrollController;

  const GlobalPollScreen({Key key, this.scrollController}) : super(key: key);

  @override
  _GlobalPollScreenState createState() => _GlobalPollScreenState();
}

class _GlobalPollScreenState extends State<GlobalPollScreen> {
  GlobalPostProvider globalPostProvider;
  CreateAccountData commentUserData;


  @override
  void initState() {
    globalPostProvider =
        Provider.of<GlobalPostProvider>(context, listen: false);
    globalPostProvider.getUserData();
    globalPostProvider.pushNotificationController.fcmSubscribe();
    /*   widget.scrollController.addListener(() {
      double maxScroll = widget.scrollController.position.maxScrollExtent;
      double currentScroll = widget.scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {}
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    globalPostProvider.screenWidth = MediaQuery.of(context).size.width;
    return Consumer<GlobalPostProvider>(
        builder: (context, globalPostProvider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: globalPostProvider.isPostLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (globalPostProvider.posts.isEmpty
                ? Center(child: EmptyGlobalPost(globalPostProvider.screenWidth))
                : (globalPostProvider.posts.length == 0
                    ? Center(
                        child: SizedBox(),
                      )
                    : RefreshIndicator(
                        onRefresh: getRefreshData,
                        color: Colors.white,
                        backgroundColor: mRed,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5.0,
                                ),
                                ListView.builder(
                                  controller: widget.scrollController,
                                  padding: EdgeInsets.all(10.0),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: globalPostProvider.posts.length,
                                  itemBuilder: (context, index) {
                                    if (globalPostProvider.posts[index].type ==
                                        "poll") {
                                      return globalPostProvider
                                                  .posts[index].anonymously ==
                                              true
                                          ? MyPollWidget(
                                              pollDataModel: globalPostProvider
                                                  .posts[index],
                                              currentUserId: globalPostProvider
                                                  .firebaseController
                                                  .currentFirebaseUser
                                                  .uid,
                                              pollType: PollsType.voter,
                                              isAnonymous: true,
                                              pollRef: globalPostProvider
                                                  .firebaseController
                                                  .postColReference,
                                              deletePollPressed: () async {
                                                if (globalPostProvider
                                                        .posts[index]
                                                        .pollQuestion
                                                        .createdBy ==
                                                    globalPostProvider
                                                        .firebaseController
                                                        .currentFirebaseUser
                                                        .uid) {
                                                  globalPostProvider
                                                      .firebaseController
                                                      .postColReference
                                                      .doc(globalPostProvider
                                                          .posts[index].pollId)
                                                      .delete()
                                                      .catchError((e) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Poll Deletion Failed!!"
                                                                .tr(),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 3,
                                                        backgroundColor:
                                                            Colors.blueGrey,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }).then((value) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Poll Deleted Successfully!!"
                                                                .tr(),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 3,
                                                        backgroundColor:
                                                            Colors.blueGrey,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  });
                                                }
                                                globalPostProvider
                                                    .lastDocument = null;
                                                globalPostProvider.hasMore =
                                                    true;
                                                /*  getMyPollsWithLoadMore();*/
                                              },
                                              onVotePressed: (value) async {
                                                print("iuooi2");
                                                await globalPostProvider.voteToPoll(
                                                    value,
                                                    globalPostProvider
                                                        .posts[index].id).then((value) async {
                                                          print("iuooi");
                                                          await Navigator.of(context).pushReplacementNamed('/Home');
                                                });

                                              },
                                            )
                                          : Card(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.blueGrey,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              color: themeProvider.isDarkMode
                                                  ? Colors.black.withOpacity(.3)
                                                  : white,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 20.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      onTap: () {
                                                        globalPostProvider
                                                            .navigateToUnkwonScreen(
                                                                globalPostProvider
                                                                    .posts[
                                                                        index]
                                                                    .createdBy,
                                                                globalPostProvider
                                                                    .userData
                                                                    .uid,
                                                                context);
                                                      },
                                                      child: StreamBuilder(
                                                          stream: globalPostProvider
                                                              .firebaseController
                                                              .userColReference
                                                              .doc(globalPostProvider
                                                                  .posts[index]
                                                                  .createdBy)
                                                              .get()
                                                              .asStream(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot) {
                                                            if (!snapshot
                                                                .hasData)
                                                              return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                strokeWidth: 1,
                                                                color: themeProvider
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ));
                                                            CreateAccountData
                                                                postUserData =
                                                                CreateAccountData
                                                                    .fromDocument(
                                                                        snapshot
                                                                            .data
                                                                            .data());
                                                            return Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    postUserData
                                                                            .profilepic
                                                                            .isNotEmpty
                                                                        ? ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                              80,
                                                                            ),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              height: 45,
                                                                              width: 45,
                                                                              fit: BoxFit.fill,
                                                                              imageUrl: postUserData.profilepic,
                                                                              useOldImageOnUrlChange: true,
                                                                              placeholder: (context, url) => CupertinoActivityIndicator(
                                                                                radius: 1,
                                                                              ),
                                                                              errorWidget: (context, url, error) => Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: <Widget>[
                                                                                  Icon(
                                                                                    Icons.error,
                                                                                    color: Colors.blueGrey,
                                                                                    size: 1,
                                                                                  ),
                                                                                  Text(
                                                                                    "Error".tr(),
                                                                                    style: TextStyle(
                                                                                      color: Colors.blueGrey,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                              80,
                                                                            ),
                                                                            child:
                                                                                Container(
                                                                              height: 45,
                                                                              width: 45,
                                                                              child: Image.asset(placeholderImage, fit: BoxFit.cover),
                                                                            ),
                                                                          ),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                                10.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(postUserData.name,
                                                                                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black, fontWeight: FontWeight.w700)),
                                                                            SizedBox(
                                                                              height: 5.0,
                                                                            ),
                                                                            Text(
                                                                              Utils().convertToAgoAndDate(globalPostProvider.posts[index].createdAt),
                                                                              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black, fontWeight: FontWeight.normal),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ),
                                                                globalPostProvider
                                                                            .posts[
                                                                                index]
                                                                            .createdBy !=
                                                                        FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid
                                                                    ? GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior.translucent,
                                                                        onTap:
                                                                            () {
                                                                          globalPostProvider
                                                                            ..reportPost(
                                                                                globalPostProvider.posts[index].id,
                                                                                context,
                                                                                TypeOfReport.poll,
                                                                                globalPostProvider.posts[index].createdBy);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Icon(
                                                                            CupertinoIcons.flag,
                                                                            size:
                                                                                26.0,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Flexible(
                                                                        child:
                                                                            GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.translucent,
                                                                          onTap:
                                                                              () async {
                                                                            return showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    backgroundColor: themeProvider.isDarkMode ? black.withOpacity(.5) : white.withOpacity(.5),
                                                                                    content: Container(
                                                                                      //height: MediaQuery.of(context).size.height / 5,
                                                                                      child: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Text(
                                                                                            "Are You Sure?".tr(),
                                                                                            textAlign: TextAlign.center,
                                                                                            style: TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Container(
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            margin: EdgeInsets.only(left: 30, right: 30),
                                                                                            height: 50,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                if (globalPostProvider.posts[index].createdBy == globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                                                  globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).delete().catchError((e) {
                                                                                                    Fluttertoast.showToast(msg: "Post Deletion Failed!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                                  }).then((value) {
                                                                                                    Fluttertoast.showToast(msg: "Post Deleted Successfully!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                                  });
                                                                                                }
                                                                                                globalPostProvider.lastDocument = null;
                                                                                                globalPostProvider.hasMore = true;

                                                                                                // deleteMyPoll(
                                                                                                //     themeProvider:
                                                                                                //         themeProvider);
                                                                                              },
                                                                                              child: SingleChildScrollView(
                                                                                                scrollDirection: Axis.horizontal,
                                                                                                physics: BouncingScrollPhysics(),
                                                                                                child: Text(
                                                                                                  "Delete".tr(),
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: TextStyle(fontSize: 20),
                                                                                                ),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mRed,
                                                                                                onPrimary: white,
                                                                                                // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                                elevation: 5,
                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Container(
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            margin: EdgeInsets.only(left: 30, right: 30),
                                                                                            height: 50,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: SingleChildScrollView(
                                                                                                scrollDirection: Axis.horizontal,
                                                                                                physics: BouncingScrollPhysics(),
                                                                                                child: Text(
                                                                                                  "Cancel".tr(),
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: TextStyle(fontSize: 20),
                                                                                                ),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: themeProvider.isDarkMode ? mBlack : white,
                                                                                                onPrimary: Colors.blue[700],
                                                                                                // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                                elevation: 5,
                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                });
                                                                            // if (globalPostProvider.posts[index].createdBy ==
                                                                            //     globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                            //   globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).delete().catchError((e) {
                                                                            //     Fluttertoast.showToast(msg: "Post Deletion Failed!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                            //   }).then((value) {
                                                                            //     Fluttertoast.showToast(msg: "Post Deleted Successfully!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                            //   });
                                                                            // }
                                                                            // globalPostProvider.lastDocument =
                                                                            //     null;
                                                                            // globalPostProvider.hasMore =
                                                                            //     true;
                                                                            //
                                                                            // // deleteMyPoll(
                                                                            // //     themeProvider:
                                                                            // //         themeProvider);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Icon(
                                                                              CupertinoIcons.delete,
                                                                              size: 26.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ],
                                                            );
                                                          }),
                                                    ),
                                                    MyPollWidget(
                                                      pollDataModel:
                                                          globalPostProvider
                                                              .posts[index],
                                                      currentUserId:
                                                          globalPostProvider
                                                              .firebaseController
                                                              .currentFirebaseUser
                                                              .uid,
                                                      pollType: PollsType.voter,
                                                      pollRef: globalPostProvider
                                                          .firebaseController
                                                          .postColReference,
                                                      onVotePressed: (value) async {
                                                        print("iuooi3");
                                                        await globalPostProvider
                                                            .voteToPoll(
                                                                value,
                                                                globalPostProvider
                                                                    .posts[
                                                                        index]
                                                                    .id).then((value) async {
                                                          print("iuooi33");
                                                          await Navigator.of(context).pushReplacementNamed('/Home');
                                                        });

                                                      },
                                                      deletePollPressed:
                                                          () async {
                                                        if (globalPostProvider
                                                                .posts[index]
                                                                .pollQuestion
                                                                .createdBy ==
                                                            globalPostProvider
                                                                .firebaseController
                                                                .currentFirebaseUser
                                                                .uid) {
                                                          globalPostProvider
                                                              .firebaseController
                                                              .postColReference
                                                              .doc(
                                                                  globalPostProvider
                                                                      .posts[
                                                                          index]
                                                                      .pollId)
                                                              .delete()
                                                              .catchError((e) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Poll Deletion Failed!!"
                                                                        .tr(),
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    3,
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueGrey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          }).then((value) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Poll Deleted Successfully!!"
                                                                        .tr(),
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    3,
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueGrey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          });
                                                        }
                                                        globalPostProvider
                                                                .lastDocument =
                                                            null;
                                                        globalPostProvider
                                                            .hasMore = true;
                                                        /*  getMyPollsWithLoadMore();*/
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                    } else {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.blueGrey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        color: themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(.3)
                                            : white,
                                        elevation: 4.0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              globalPostProvider.posts[index]
                                                          .anonymously ==
                                                      true
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    80,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 45,
                                                                    width: 45,
                                                                    child: Image.asset(
                                                                        placeholderImage,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          "Unknown"
                                                                              .tr(),
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700)),
                                                                      SizedBox(
                                                                        height:
                                                                            4.0,
                                                                      ),
                                                                      Text(
                                                                        Utils().convertToAgoAndDate(globalPostProvider
                                                                            .posts[index]
                                                                            .createdAt),
                                                                        style: TextStyle(
                                                                            color: themeProvider.isDarkMode
                                                                                ? Colors.white
                                                                                : black,
                                                                            fontWeight: FontWeight.normal),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .createdBy !=
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                        .uid
                                                                ? Flexible(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        globalPostProvider
                                                                          ..reportPost(
                                                                              globalPostProvider.posts[index].postId,
                                                                              context,
                                                                              TypeOfReport.post,
                                                                              globalPostProvider.posts[index].createdBy);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Icon(
                                                                          CupertinoIcons
                                                                              .flag,
                                                                          size:
                                                                              26.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Flexible(
                                                                    child:
                                                                        GestureDetector(
                                                                      behavior:
                                                                          HitTestBehavior
                                                                              .translucent,
                                                                      onTap:
                                                                          () async {
                                                                        return showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                backgroundColor: themeProvider.isDarkMode ? black.withOpacity(.5) : white.withOpacity(.5),
                                                                                content: Container(
                                                                                  //height: MediaQuery.of(context).size.height / 5,
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Are You Sure?".tr(),
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(fontSize: 20),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        margin: EdgeInsets.only(left: 30, right: 30),
                                                                                        height: 50,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            if (globalPostProvider.posts[index].createdBy == globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                                              globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).delete().catchError((e) {
                                                                                                Fluttertoast.showToast(msg: "Post Deletion Failed!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                              }).then((value) {
                                                                                                Fluttertoast.showToast(msg: "Post Deleted Successfully!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                              });
                                                                                            }
                                                                                            globalPostProvider.lastDocument = null;
                                                                                            globalPostProvider.hasMore = true;
                                                                                            // deleteMyPoll(
                                                                                            //     themeProvider: themeProvider);
                                                                                          },
                                                                                          child: SingleChildScrollView(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            physics: BouncingScrollPhysics(),
                                                                                            child: Text(
                                                                                              "Delete".tr(),
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontSize: 20),
                                                                                            ),
                                                                                          ),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            primary: mRed,
                                                                                            onPrimary: white,
                                                                                            // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                            elevation: 5,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        margin: EdgeInsets.only(left: 30, right: 30),
                                                                                        height: 50,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: SingleChildScrollView(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            physics: BouncingScrollPhysics(),
                                                                                            child: Text(
                                                                                              "Cancel".tr(),
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(fontSize: 20),
                                                                                            ),
                                                                                          ),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            primary: themeProvider.isDarkMode ? mBlack : white,
                                                                                            onPrimary: Colors.blue[700],
                                                                                            // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                            elevation: 5,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            });
                                                                        // if (globalPostProvider.posts[index].createdBy ==
                                                                        //     globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                        //   globalPostProvider
                                                                        //       .firebaseController
                                                                        //       .postColReference
                                                                        //       .doc(globalPostProvider.posts[index].postId)
                                                                        //       .delete()
                                                                        //       .catchError((e) {
                                                                        //     Fluttertoast.showToast(
                                                                        //         msg: "Post Deletion Failed!!".tr(),
                                                                        //         toastLength: Toast.LENGTH_SHORT,
                                                                        //         gravity: ToastGravity.BOTTOM,
                                                                        //         timeInSecForIosWeb: 3,
                                                                        //         backgroundColor: Colors.blueGrey,
                                                                        //         textColor: Colors.white,
                                                                        //         fontSize: 16.0);
                                                                        //   }).then((value) {
                                                                        //     Fluttertoast.showToast(
                                                                        //         msg: "Post Deleted Successfully!!".tr(),
                                                                        //         toastLength: Toast.LENGTH_SHORT,
                                                                        //         gravity: ToastGravity.BOTTOM,
                                                                        //         timeInSecForIosWeb: 3,
                                                                        //         backgroundColor: Colors.blueGrey,
                                                                        //         textColor: Colors.white,
                                                                        //         fontSize: 16.0);
                                                                        //   });
                                                                        // }
                                                                        // globalPostProvider.lastDocument =
                                                                        //     null;
                                                                        // globalPostProvider.hasMore =
                                                                        //     true;
                                                                        // // deleteMyPoll(
                                                                        // //     themeProvider: themeProvider);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Icon(
                                                                          CupertinoIcons
                                                                              .delete,
                                                                          size:
                                                                              26.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10.0,
                                                        ),
                                                      ],
                                                    )
                                                  : (globalPostProvider
                                                              .posts[index]
                                                              .createdBy !=
                                                          null
                                                      ? StreamBuilder(
                                                          stream: globalPostProvider
                                                              .firebaseController
                                                              .userColReference
                                                              .doc(globalPostProvider
                                                                  .posts[index]
                                                                  .createdBy)
                                                              .get()
                                                              .asStream(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot) {
                                                            if (!snapshot
                                                                .hasData)
                                                              return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                strokeWidth: 1,
                                                                color: themeProvider
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ));
                                                            CreateAccountData
                                                                postUserData =
                                                                CreateAccountData
                                                                    .fromDocument(
                                                                        snapshot
                                                                            .data
                                                                            .data());
                                                            return Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                GestureDetector(
                                                                  behavior:
                                                                      HitTestBehavior
                                                                          .translucent,
                                                                  onTap: () {
                                                                    globalPostProvider.navigateToUnkwonScreen(
                                                                        globalPostProvider
                                                                            .userData
                                                                            .uid,
                                                                        globalPostProvider
                                                                            .posts[index]
                                                                            .createdBy,
                                                                        context);
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      postUserData
                                                                              .profilepic
                                                                              .isNotEmpty
                                                                          ? ClipRRect(
                                                                              borderRadius: BorderRadius.circular(
                                                                                80,
                                                                              ),
                                                                              child: CachedNetworkImage(
                                                                                height: 45,
                                                                                width: 45,
                                                                                fit: BoxFit.fill,
                                                                                imageUrl: postUserData.profilepic,
                                                                                useOldImageOnUrlChange: true,
                                                                                placeholder: (context, url) => CupertinoActivityIndicator(
                                                                                  radius: 1,
                                                                                ),
                                                                                errorWidget: (context, url, error) => Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: <Widget>[
                                                                                    Icon(
                                                                                      Icons.error,
                                                                                      color: Colors.blueGrey,
                                                                                      size: 1,
                                                                                    ),
                                                                                    Text(
                                                                                      "Error".tr(),
                                                                                      style: TextStyle(
                                                                                        color: Colors.blueGrey,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : ClipRRect(
                                                                              borderRadius: BorderRadius.circular(
                                                                                80,
                                                                              ),
                                                                              child: Container(
                                                                                height: 45,
                                                                                width: 45,
                                                                                child: Image.asset(placeholderImage, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                              child: Text(
                                                                                postUserData.name,
                                                                                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black, fontWeight: FontWeight.w700),
                                                                              )),
                                                                          SizedBox(
                                                                            height:
                                                                                4.0,
                                                                          ),
                                                                          Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                              child: Text(
                                                                                Utils().convertToAgoAndDate(globalPostProvider.posts[index].createdAt),
                                                                                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black, fontWeight: FontWeight.normal),
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                globalPostProvider
                                                                            .posts[
                                                                                index]
                                                                            .createdBy !=
                                                                        FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid
                                                                    ? GestureDetector(
                                                                        behavior:
                                                                            HitTestBehavior.translucent,
                                                                        onTap:
                                                                            () {
                                                                          globalPostProvider
                                                                            ..reportPost(
                                                                                globalPostProvider.posts[index].postId,
                                                                                context,
                                                                                TypeOfReport.post,
                                                                                globalPostProvider.posts[index].createdBy);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Icon(
                                                                            CupertinoIcons.flag,
                                                                            size:
                                                                                26.0,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Flexible(
                                                                        child:
                                                                            GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.translucent,
                                                                          onTap:
                                                                              () async {
                                                                            return showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    backgroundColor: themeProvider.isDarkMode ? black.withOpacity(.5) : white.withOpacity(.5),
                                                                                    content: Container(
                                                                                      //height: MediaQuery.of(context).size.height / 5,
                                                                                      child: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Text(
                                                                                            "Are You Sure?".tr(),
                                                                                            textAlign: TextAlign.center,
                                                                                            style: TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Container(
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            margin: EdgeInsets.only(left: 30, right: 30),
                                                                                            height: 50,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                if (globalPostProvider.posts[index].createdBy == globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                                                  globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).delete().catchError((e) {
                                                                                                    Fluttertoast.showToast(msg: "Post Deletion Failed!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                                  }).then((value) {
                                                                                                    Fluttertoast.showToast(msg: "Post Deleted Successfully!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                                                  });
                                                                                                }
                                                                                                globalPostProvider.lastDocument = null;
                                                                                                globalPostProvider.hasMore = true;

                                                                                                // deleteMyPoll(
                                                                                                //     themeProvider:
                                                                                                //         themeProvider);
                                                                                              },
                                                                                              child: SingleChildScrollView(
                                                                                                scrollDirection: Axis.horizontal,
                                                                                                physics: BouncingScrollPhysics(),
                                                                                                child: Text(
                                                                                                  "Delete".tr(),
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: TextStyle(fontSize: 20),
                                                                                                ),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mRed,
                                                                                                onPrimary: white,
                                                                                                // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                                elevation: 5,
                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Container(
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            margin: EdgeInsets.only(left: 30, right: 30),
                                                                                            height: 50,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: SingleChildScrollView(
                                                                                                scrollDirection: Axis.horizontal,
                                                                                                physics: BouncingScrollPhysics(),
                                                                                                child: Text(
                                                                                                  "Cancel".tr(),
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: TextStyle(fontSize: 20),
                                                                                                ),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: themeProvider.isDarkMode ? mBlack : white,
                                                                                                onPrimary: Colors.blue[700],
                                                                                                // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                                                                                elevation: 5,
                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                });
                                                                            // if (globalPostProvider.posts[index].createdBy ==
                                                                            //     globalPostProvider.firebaseController.currentFirebaseUser.uid) {
                                                                            //   globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).delete().catchError((e) {
                                                                            //     Fluttertoast.showToast(msg: "Post Deletion Failed!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                            //   }).then((value) {
                                                                            //     Fluttertoast.showToast(msg: "Post Deleted Successfully!!".tr(), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 3, backgroundColor: Colors.blueGrey, textColor: Colors.white, fontSize: 16.0);
                                                                            //   });
                                                                            // }
                                                                            // globalPostProvider.lastDocument =
                                                                            //     null;
                                                                            // globalPostProvider.hasMore =
                                                                            //     true;
                                                                            //
                                                                            // // deleteMyPoll(
                                                                            // //     themeProvider:
                                                                            // //         themeProvider);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Icon(
                                                                              CupertinoIcons.delete,
                                                                              size: 26.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ],
                                                            );
                                                          })
                                                      : Container()),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              globalPostProvider.posts[index]
                                                          .textPost !=
                                                      null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              top: 5.0),
                                                      child: Text(
                                                        globalPostProvider
                                                            .posts[index]
                                                            .textPost,
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0, top: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        StreamBuilder(
                                                            stream: globalPostProvider
                                                                .firebaseController
                                                                .likeDislikeCountColReference
                                                                .where(
                                                                    "likedBy",
                                                                    isEqualTo:
                                                                        globalPostProvider
                                                                            .userData
                                                                            .uid)
                                                                .where("postId",
                                                                    isEqualTo: globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .postId)
                                                                .limit(1)
                                                                .snapshots()

                                                            /*    globalPostProvider
                                                                .getLikeButton(
                                                                    globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .postId)
                                                                .asStream() */
                                                            ,
                                                            builder: (context,
                                                                AsyncSnapshot<
                                                                        QuerySnapshot>
                                                                    snapshot) {
                                                              if (!snapshot
                                                                  .hasData)
                                                                return Container();

                                                              if (snapshot
                                                                  .data
                                                                  .docs
                                                                  .isEmpty) {
                                                                return GestureDetector(
                                                                  behavior:
                                                                      HitTestBehavior
                                                                          .translucent,
                                                                  onTap:
                                                                      () async {
                                                                    QuerySnapshot
                                                                        isLiked =
                                                                        await globalPostProvider.getLikeButton(globalPostProvider
                                                                            .posts[index]
                                                                            .postId);
                                                                    if (isLiked
                                                                        .docs
                                                                        .isEmpty) {
                                                                      globalPostProvider.likeOrDislike(
                                                                          globalPostProvider
                                                                              .posts[
                                                                                  index]
                                                                              .postId,
                                                                          true,
                                                                          null,
                                                                          globalPostProvider
                                                                              .posts[index]
                                                                              .createdBy);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2.0,
                                                                        vertical:
                                                                            2.0),
                                                                    child: Icon(
                                                                        CupertinoIcons
                                                                            .heart),
                                                                  ),
                                                                );
                                                              } else {
                                                                return GestureDetector(
                                                                  behavior:
                                                                      HitTestBehavior
                                                                          .translucent,
                                                                  onTap:
                                                                      () async {
                                                                    QuerySnapshot
                                                                        isLiked =
                                                                        await globalPostProvider.getLikeButton(globalPostProvider
                                                                            .posts[index]
                                                                            .postId);
                                                                    if (isLiked
                                                                        .docs
                                                                        .isNotEmpty) {
                                                                      globalPostProvider.likeOrDislike(
                                                                          globalPostProvider
                                                                              .posts[
                                                                                  index]
                                                                              .postId,
                                                                          false,
                                                                          isLiked.docs[0]
                                                                              [
                                                                              'id'],
                                                                          globalPostProvider
                                                                              .posts[index]
                                                                              .createdBy);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2.0,
                                                                        vertical:
                                                                            2.0),
                                                                    child: Icon(
                                                                      CupertinoIcons
                                                                          .heart_solid,
                                                                      color:
                                                                          mRed,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }),
                                                        StreamBuilder(
                                                            stream: globalPostProvider
                                                                .firebaseController
                                                                .postColReference
                                                                .doc(globalPostProvider
                                                                    .posts[
                                                                        index]
                                                                    .postId)
                                                                .snapshots(),
                                                            builder: (context,
                                                                AsyncSnapshot
                                                                    snapshot) {
                                                              if (!snapshot
                                                                  .hasData)
                                                                return Center(
                                                                  child: SizedBox
                                                                      .shrink(),
                                                                );
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting)
                                                                return Center(
                                                                  child:
                                                                      Text("0"),
                                                                );
                                                              var data =
                                                                  snapshot.data;

                                                              return Text(data[
                                                                          "likesCount"] !=
                                                                      null
                                                                  ? data["likesCount"]
                                                                      .toString()
                                                                  : "0");
                                                            }),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      onTap: () {
                                                        globalPostProvider
                                                            .setCurrentPostTappedIndex(
                                                                index);
                                                        globalPostProvider
                                                            .setCommentTapped();
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          2.0,
                                                                      vertical:
                                                                          5.0),
                                                              child: globalPostProvider
                                                                              .currentPostIndex ==
                                                                          index &&
                                                                      globalPostProvider
                                                                          .isCommentTapped
                                                                  ? Icon(
                                                                      CupertinoIcons
                                                                          .chat_bubble_text_fill,
                                                                      color:
                                                                          mRed,
                                                                    )
                                                                  : Icon(
                                                                      CupertinoIcons
                                                                          .chat_bubble_text,
                                                                    ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            StreamBuilder(
                                                                stream: globalPostProvider
                                                                    .firebaseController
                                                                    .postColReference
                                                                    .doc(globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .postId)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    AsyncSnapshot
                                                                        snapshot) {
                                                                  if (!snapshot
                                                                      .hasData)
                                                                    return Center(
                                                                      child: SizedBox
                                                                          .shrink(),
                                                                    );
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting)
                                                                    return Center(
                                                                      child: Text(
                                                                          "0"),
                                                                    );
                                                                  var data =
                                                                      snapshot
                                                                          .data;

                                                                  return data["commentsCount"] !=
                                                                          null
                                                                      ? Container(
                                                                          padding:
                                                                              EdgeInsets.symmetric(
                                                                            vertical:
                                                                                5.0,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              data["commentsCount"].toString(),
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: 12.0),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : SizedBox
                                                                          .shrink();
                                                                }),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: globalPostProvider
                                                                .currentPostIndex ==
                                                            index &&
                                                        globalPostProvider
                                                            .isCommentTapped
                                                    ? true
                                                    : false,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30.0),
                                                  alignment: Alignment.center,
                                                  child: StreamBuilder(
                                                      stream: globalPostProvider
                                                          .firebaseController
                                                          .postColReference
                                                          .doc(
                                                              globalPostProvider
                                                                  .posts[index]
                                                                  .postId)
                                                          .collection(
                                                              commentCollectionName)
                                                          .orderBy("createdAt",
                                                              descending: true)
                                                          .snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                        List dummyList = [];
                                                        List commentList = [];
                                                        if (!snapshot.hasData)
                                                          return Container(
                                                              height: 30.0,
                                                              child: Text(
                                                                "Please wait...."
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: themeProvider.isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black),
                                                              ));

                                                        snapshot.data.docs
                                                            .forEach((element) {
                                                          dummyList.add(
                                                              element.data());
                                                        });

                                                        var data = dummyList
                                                            .where((element) =>
                                                                element[
                                                                    'commentBy'] ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                            .toList();
                                                        var otherData = dummyList
                                                            .where((element) =>
                                                                element[
                                                                    'commentBy'] !=
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                            .toList();

                                                        if (data.length > 0) {
                                                          commentList
                                                              .addAll(data);
                                                        }
                                                        if (otherData.length >
                                                            0) {
                                                          commentList.addAll(
                                                              otherData);
                                                        }
                                                        return commentList
                                                                    .length >
                                                                0
                                                            ? Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    .4,
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount:
                                                                            commentList
                                                                                .length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            AlwaysScrollableScrollPhysics(),
                                                                        itemBuilder:
                                                                            (context,
                                                                                commentIndex) {
                                                                          return Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                                                            decoration:
                                                                                BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                StreamBuilder(
                                                                                    stream: globalPostProvider.firebaseController.userColReference.doc(commentList[commentIndex]['commentBy']).get().asStream(),
                                                                                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                                                      if (!snapshot.hasData) return SizedBox.shrink();
                                                                                      commentUserData = CreateAccountData.fromDocument(snapshot.data.data());
                                                                                      return Row(
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          commentUserData.profilepic != ""
                                                                                              ? ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(
                                                                                                    80,
                                                                                                  ),
                                                                                                  child: CachedNetworkImage(
                                                                                                    height: 30,
                                                                                                    width: 30,
                                                                                                    fit: BoxFit.cover,
                                                                                                    imageUrl: commentUserData.profilepic,
                                                                                                    useOldImageOnUrlChange: true,
                                                                                                    placeholder: (context, url) => CupertinoActivityIndicator(
                                                                                                      radius: 1,
                                                                                                    ),
                                                                                                    errorWidget: (context, url, error) => Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: <Widget>[
                                                                                                        Icon(
                                                                                                          Icons.error,
                                                                                                          color: Colors.blueGrey,
                                                                                                          size: 1,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          "Error".tr(),
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.blueGrey,
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              : ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(
                                                                                                    30,
                                                                                                  ),
                                                                                                  child: Container(
                                                                                                    height: 30,
                                                                                                    width: 30,
                                                                                                    child: Image.asset(placeholderImage, fit: BoxFit.cover),
                                                                                                  ),
                                                                                                ),
                                                                                          SizedBox(
                                                                                            width: 8.0,
                                                                                          ),
                                                                                          Container(
                                                                                            child: Text(
                                                                                              commentUserData.name ?? "",
                                                                                              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black, fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    }),
                                                                                SizedBox(
                                                                                  height: 4.0,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        StreamBuilder(
                                                                                            stream: globalPostProvider.firebaseController.postColReference.doc(commentList[commentIndex]["postId"]).collection(commentsLikesCollectionName).where("likedBy", isEqualTo: globalPostProvider.userData.uid).where("commentId", isEqualTo: commentList[commentIndex]["commentId"]).limit(1).snapshots(),
                                                                                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                              if (!snapshot.hasData) return Container();
                                                                                              if (snapshot.data.docs.isEmpty) {
                                                                                                return GestureDetector(
                                                                                                  behavior: HitTestBehavior.translucent,
                                                                                                  onTap: () async {
                                                                                                    QuerySnapshot isLiked = await globalPostProvider.getCommentLikedOrNot(commentList[commentIndex]["commentId"], globalPostProvider.posts[index].postId);
                                                                                                    if (isLiked.docs.isEmpty) {
                                                                                                      globalPostProvider.likeOrDislikeComment(commentList[commentIndex]["commentId"], globalPostProvider.posts[index].postId, false, commentUserData.uid, globalPostProvider.posts[index].createdBy);
                                                                                                    }
                                                                                                  },
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                                                                                    child: Icon(CupertinoIcons.heart),
                                                                                                  ),
                                                                                                );
                                                                                              } else {
                                                                                                return GestureDetector(
                                                                                                  behavior: HitTestBehavior.translucent,
                                                                                                  onTap: () async {
                                                                                                    QuerySnapshot isLiked = await globalPostProvider.getCommentLikedOrNot(commentList[commentIndex]["commentId"], globalPostProvider.posts[index].postId);
                                                                                                    if (isLiked.docs.isNotEmpty) {
                                                                                                      globalPostProvider.likeOrDislikeComment(commentList[commentIndex]["commentId"], globalPostProvider.posts[index].postId, true, null, globalPostProvider.posts[index].createdBy);
                                                                                                    }
                                                                                                  },
                                                                                                  child: Container(
                                                                                                    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                                                                                    child: Icon(
                                                                                                      CupertinoIcons.heart_solid,
                                                                                                      color: mRed,
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                            }),
                                                                                        StreamBuilder(
                                                                                            stream: globalPostProvider.firebaseController.postColReference.doc(globalPostProvider.posts[index].postId).collection(commentCollectionName).doc(commentList[commentIndex]["commentId"]).snapshots(),
                                                                                            builder: (context, AsyncSnapshot snapshot) {
                                                                                              if (!snapshot.hasData)
                                                                                                return Center(
                                                                                                  child: SizedBox.shrink(),
                                                                                                );
                                                                                              else if (snapshot.connectionState == ConnectionState.waiting)
                                                                                                return Center(
                                                                                                  child: Text(
                                                                                                    "0",
                                                                                                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black),
                                                                                                  ),
                                                                                                );
                                                                                              else {
                                                                                                var data = snapshot.data.data();
                                                                                                print(data);
                                                                                                return data != null && data["likesCount"] != null
                                                                                                    ? Text(
                                                                                                        data["likesCount"].toString(),
                                                                                                        style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black),
                                                                                                      )
                                                                                                    : SizedBox.shrink();
                                                                                              }
                                                                                            }),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 6.0,
                                                                                    ),
                                                                                    if (commentList[commentIndex]["comment"] != "") Container(
                                                                                      width: MediaQuery.of(context).size.width -140,
                                                                                            child: Row(
                                                                                              children : [
                                                                                                  Container(
                                                                                                  width: 165,
                                                                                                  child: ReadMoreText(
                                                                                                    commentList[commentIndex]["comment"],
                                                                                                    colorClickableText: Colors.black,
                                                                                                    trimLines: 3,
                                                                                                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : black),
                                                                                                    moreStyle: TextStyle(fontWeight: FontWeight.bold),
                                                                                                    lessStyle: TextStyle(fontWeight: FontWeight.bold),
                                                                                                    trimMode: TrimMode.Line,
                                                                                                    trimCollapsedText: '...show more'.tr(),
                                                                                                    trimExpandedText: ' show less'.tr(),
                                                                                                  ),
                                                                                                ),
                                                                                                Container(
                                                                                                  width: 20,
                                                                                                  child: IconButton(
                                                                                                    onPressed: () async {
                                                                                                      print("on icon button click");
                                                                                                      await globalPostProvider.deletePost(commentList[commentIndex]["commentBy"],
                                                                                                          globalPostProvider.posts[index].postId,
                                                                                                          commentList[commentIndex]["commentId"],globalPostProvider.posts[index].commentsCount,
                                                                                                        globalPostProvider.posts[index]
                                                                                                          ).then((value) => {
                                                                                                            print("deleted  o"),
                                                                                                         // Navigator.of(context).pushReplacementNamed('/postScreen')
                                                                                                      });
                                                                                                    },
                                                                                                    icon: Icon(
                                                                                                        CupertinoIcons
                                                                                                            .delete),
                                                                                                    iconSize: 14,

                                                                                                  ),
                                                                                                ),
                                                                                              ]

                                                                                            ),
                                                                                          ) else SizedBox.shrink(),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                              )
                                                            : SizedBox.shrink();
                                                      }),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 3, 10, 0),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? Colors.black
                                                                  .withOpacity(
                                                                      .3)
                                                              : Colors.white),
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? Colors.black
                                                              .withOpacity(.3)
                                                          : Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 2,
                                                          blurRadius: 2,
                                                          offset: const Offset(
                                                              0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: TextField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    cursorColor: Colors.black,
                                                    controller:
                                                        globalPostProvider
                                                            .commentController,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    maxLines: 2,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      suffixIcon:
                                                          GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onTap: () {
                                                                globalPostProvider.postComment(
                                                                    globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .postId,
                                                                    globalPostProvider
                                                                        .posts[
                                                                            index]
                                                                        .createdBy,
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                  Icons.send,
                                                                  color: Colors
                                                                      .grey)),
                                                      hintText:
                                                          "Write comment here.."
                                                              .tr(),
                                                      hintStyle: TextStyle(
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      .5)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      .5)),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              0, 10, 0, 10),
                                                    ),
                                                    style: TextStyle(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? Colors.white
                                                            : black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))),
      );
    });
  }

  @override
  void dispose() {
    globalPostProvider.commentController.clear();
    // TODO: implement dispose
    super.dispose();
  }

  Future getRefreshData() {
    return globalPostProvider.getAllPollPostDetail();
  }
}
