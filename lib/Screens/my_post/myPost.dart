import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/my_post/my_post_provider.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:litpie/widgets/MyPollWidget.dart';
import 'package:litpie/widgets/PollWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../common/Utils.dart';
import '../../variables.dart';
import '../createPoll.dart';
import '../createTextPost.dart';

class MyPollScreen extends StatefulWidget {
  @override
  _MyPollScreenState createState() => _MyPollScreenState();
}

class _MyPollScreenState extends State<MyPollScreen> {
  ScrollController _scrollController = ScrollController();
  MyPostProvider myPostProvider;
  ThemeProvider themeProvider;
  double _screenWidth;

  @override
  void initState() {
    myPostProvider = Provider.of<MyPostProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    myPostProvider.getUserdata();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {}
    });
    super.initState();
  }

  Future createDialog(context) async {
    showDialog(
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
                                    "Seek professional help if needed."
                                .tr(),
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
                                      builder: (context) =>
                                          CreatePollScrenn(() {
                                            myPostProvider.getUserdata();
                                          })))
                                  .whenComplete(() {
                                myPostProvider.lastDocument = null;
                                myPostProvider.hasMore = true;
                                myPostProvider.isLoading = false;
                                /*  getMyPollsWithLoadMore();*/
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
                      SizedBox(
                        height: _screenWidth >= miniScreenWidth ? 15 : 12,
                      ),
                      Tooltip(
                        message: "Ask/Confess/Share".tr(),
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
                                "Ask/Confess/Share".tr(),
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
                                      builder: (context) => createTextPost(() {
                                            myPostProvider.getUserdata();
                                          })))
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
    return Consumer<MyPostProvider>(builder: (context, myPostProvider, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: mRed,
            title: Text("My Posts".tr()),
            centerTitle: true,
            elevation: 0,
            actions: [
              //todo
              if (myPostProvider.duplicatePostlist != null &&
                  myPostProvider.duplicatePostlist.isNotEmpty)
                IconButton(
                    icon: Icon(
                      Icons.add_chart,
                      color: white,
                      size: 30.0,
                    ),
                    splashRadius: 26.0,
                    onPressed: () async {
                      createDialog(context);
                    }),
            ],
          ),
          body: myPostProvider.isLoadingPost
              ? Center(
                  child: LinearProgressCustomBar(),
                )
              : (myPostProvider.duplicatePostlist.isEmpty &&
                      myPostProvider.duplicatePostlist.length == 0
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
                              "You don't have any POST\n It's time to create your own POST now and have public opinion on it."
                                  .tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Handlee',
                                  fontWeight: FontWeight.w700,
                                  color: lRed,
                                  decoration: TextDecoration.none,
                                  fontSize: _screenWidth >= miniScreenWidth
                                      ? 25
                                      : 18),
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
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 17
                                                  : 15,
                                          fontWeight: FontWeight.bold)),
                                ),
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              CreatePollScrenn(() {
                                                myPostProvider.getUserdata();
                                              })))
                                      .whenComplete(() {
                                    myPostProvider.lastDocument = null;
                                    myPostProvider.hasMore = true;
                                    myPostProvider.isLoading = false;
                                    /*getMyPollsWithLoadMore();*/
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
                            message: "Ask/Confess/Share".tr(),
                            preferBelow: false,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 50, right: 50),
                              height: 50,
                              child: ElevatedButton(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  child: Text("Ask/Confess/Share".tr(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 17
                                                  : 15,
                                          fontWeight: FontWeight.bold)),
                                ),
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              createTextPost(() {
                                                myPostProvider.getUserdata();
                                              })))
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
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(10.0),
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  myPostProvider.duplicatePostlist.length,
                              itemBuilder: (context, index) {
                                if (myPostProvider
                                        .duplicatePostlist[index].type ==
                                    "poll") {
                                  return myPostProvider.duplicatePostlist[index]
                                              .anonymously ==
                                          true
                                      ? Card(
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
                                          elevation: 4.0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Posted Anonymously"
                                                              .tr(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          Utils().convertToAgoAndDate(
                                                              myPostProvider
                                                                  .duplicatePostlist[
                                                                      index]
                                                                  .createdAt),
                                                          style: TextStyle(
                                                              color: themeProvider
                                                                      .isDarkMode
                                                                  ? Colors.white
                                                                  : black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                MyPollWidget(
                                                  pollDataModel: myPostProvider
                                                      .duplicatePostlist[index],
                                                  currentUserId: myPostProvider
                                                      .firebaseController
                                                      .currentFirebaseUser
                                                      .uid,
                                                  pollType: PollsType.creator,
                                                  pollRef: myPostProvider
                                                      .firebaseController
                                                      .postColReference,
                                                  deletePollPressed: () async {
                                                    if (myPostProvider
                                                            .duplicatePostlist[
                                                                index]
                                                            .pollQuestion
                                                            .createdBy ==
                                                        myPostProvider
                                                            .firebaseController
                                                            .currentFirebaseUser
                                                            .uid) {
                                                      myPostProvider
                                                          .firebaseController
                                                          .postColReference
                                                          .doc(myPostProvider
                                                              .duplicatePostlist[
                                                                  index]
                                                              .id)
                                                          .delete()
                                                          .catchError((e) {
                                                        print(e.toString());
                                                        Fluttertoast.showToast(
                                                            msg: "Poll Deletion Failed!!"
                                                                .tr(),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                3,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }).then((value) {
                                                        myPostProvider
                                                            .getUserdata();
                                                        Fluttertoast.showToast(
                                                            msg: "Poll Deleted Successfully!!"
                                                                .tr(),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                3,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      });
                                                    }
                                                    myPostProvider
                                                        .lastDocument = null;
                                                    myPostProvider.hasMore =
                                                        true;
                                                    /*  getMyPollsWithLoadMore();*/
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
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
                                          elevation: 4.0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 20.0),
                                            child: Column(
                                              children: [
                                                myPostProvider
                                                            .duplicatePostlist[
                                                                index]
                                                            .createdBy ==
                                                        myPostProvider
                                                            .userdata.uid
                                                    ? Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          myPostProvider
                                                                  .userdata
                                                                  .profilepic
                                                                  .isNotEmpty
                                                              ? ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    80,
                                                                  ),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    height: 45,
                                                                    width: 45,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    imageUrl: myPostProvider
                                                                        .userdata
                                                                        .profilepic,
                                                                    useOldImageOnUrlChange:
                                                                        true,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            CupertinoActivityIndicator(
                                                                      radius: 1,
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Icon(
                                                                          Icons
                                                                              .error,
                                                                          color:
                                                                              Colors.blueGrey,
                                                                          size:
                                                                              1,
                                                                        ),
                                                                        Text(
                                                                          "Error"
                                                                              .tr(),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blueGrey,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : ClipRRect(
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
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      15.0),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    myPostProvider
                                                                        .userdata
                                                                        .name,
                                                                    style: TextStyle(
                                                                        color: themeProvider.isDarkMode
                                                                            ? Colors
                                                                                .white
                                                                            : black,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                  Text(
                                                                    Utils().convertToAgoAndDate(myPostProvider
                                                                        .duplicatePostlist[
                                                                            index]
                                                                        .createdAt),
                                                                    style: TextStyle(
                                                                        color: themeProvider.isDarkMode
                                                                            ? Colors
                                                                                .white
                                                                            : black,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                ],
                                                              )),
                                                        ],
                                                      )
                                                    : Text(""),
                                                MyPollWidget(
                                                  pollDataModel: myPostProvider
                                                      .duplicatePostlist[index],
                                                  currentUserId: myPostProvider
                                                      .firebaseController
                                                      .currentFirebaseUser
                                                      .uid,
                                                  pollType: PollsType.creator,
                                                  pollRef: myPostProvider
                                                      .firebaseController
                                                      .postColReference,
                                                  deletePollPressed: () async {
                                                    if (myPostProvider
                                                            .duplicatePostlist[
                                                                index]
                                                            .pollQuestion
                                                            .createdBy ==
                                                        myPostProvider
                                                            .firebaseController
                                                            .currentFirebaseUser
                                                            .uid) {
                                                      await myPostProvider
                                                          .firebaseController
                                                          .postColReference
                                                          .doc(myPostProvider
                                                              .duplicatePostlist[
                                                                  index]
                                                              .id)
                                                          .delete()
                                                          .catchError((e) {
                                                        print(e.toString());
                                                        Fluttertoast.showToast(
                                                            msg: "Poll Deletion Failed!!"
                                                                .tr(),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                3,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }).then((value) {
                                                        myPostProvider
                                                            .getUserdata();
                                                        Fluttertoast.showToast(
                                                            msg: "Poll Deleted Successfully!!"
                                                                .tr(),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                3,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }).whenComplete(() {});
                                                    }
                                                    myPostProvider
                                                        .lastDocument = null;
                                                    myPostProvider.hasMore =
                                                        true;
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
                                      borderRadius: BorderRadius.circular(10),
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
                                          myPostProvider
                                                      .duplicatePostlist[index]
                                                      .anonymously ==
                                                  true
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        "Posted Anonymously"
                                                            .tr(),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        Utils().convertToAgoAndDate(
                                                            myPostProvider
                                                                .duplicatePostlist[
                                                                    index]
                                                                .createdAt),
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: myPostProvider
                                                                      .duplicatePostlist[
                                                                          index]
                                                                      .textPost !=
                                                                  null
                                                              ? Text(
                                                                  myPostProvider
                                                                      .duplicatePostlist[
                                                                          index]
                                                                      .textPost,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20.0,
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ),
                                                        Flexible(
                                                          child:
                                                              GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () async {
                                                              return showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      backgroundColor: themeProvider
                                                                              .isDarkMode
                                                                          ? black.withOpacity(
                                                                              .5)
                                                                          : white
                                                                              .withOpacity(.5),
                                                                      content:
                                                                          Container(
                                                                        //height: MediaQuery.of(context).size.height / 5,
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
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
                                                                                  myPostProvider.deletePost(myPostProvider.duplicatePostlist[index].createdBy, myPostProvider.duplicatePostlist[index].postId);
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
                                                              // myPostProvider.deletePost(
                                                              //     myPostProvider
                                                              //         .duplicatePostlist[
                                                              //             index]
                                                              //         .createdBy,
                                                              //     myPostProvider
                                                              //         .duplicatePostlist[
                                                              //             index]
                                                              //         .postId);
                                                            },
                                                            child: Container(
                                                              child: Icon(
                                                                CupertinoIcons
                                                                    .delete,
                                                                size: 26.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : myPostProvider.userdata.uid !=
                                                      null
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                myPostProvider
                                                                        .userdata
                                                                        .profilepic
                                                                        .isNotEmpty
                                                                    ? ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                          80,
                                                                        ),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          height:
                                                                              45,
                                                                          width:
                                                                              45,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          imageUrl: myPostProvider
                                                                              .userdata
                                                                              .profilepic,
                                                                          useOldImageOnUrlChange:
                                                                              true,
                                                                          placeholder: (context, url) =>
                                                                              CupertinoActivityIndicator(
                                                                            radius:
                                                                                1,
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
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
                                                                          height:
                                                                              45,
                                                                          width:
                                                                              45,
                                                                          child: Image.asset(
                                                                              placeholderImage,
                                                                              fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            15.0,
                                                                        vertical:
                                                                            10.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          myPostProvider
                                                                              .userdata
                                                                              .name,
                                                                          style: TextStyle(
                                                                              color: themeProvider.isDarkMode ? Colors.white : black,
                                                                              fontWeight: FontWeight.w700),
                                                                        ),
                                                                        Text(
                                                                          Utils().convertToAgoAndDate(myPostProvider
                                                                              .duplicatePostlist[index]
                                                                              .createdAt),
                                                                          style: TextStyle(
                                                                              color: themeProvider.isDarkMode ? Colors.white : black,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ],
                                                            ),
                                                            Flexible(
                                                              child:
                                                                  GestureDetector(
                                                                behavior:
                                                                    HitTestBehavior
                                                                        .translucent,
                                                                onTap:
                                                                    () async {
                                                                  //
                                                                  return showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          backgroundColor: themeProvider.isDarkMode
                                                                              ? black.withOpacity(.5)
                                                                              : white.withOpacity(.5),
                                                                          content:
                                                                              Container(
                                                                            //height: MediaQuery.of(context).size.height / 5,
                                                                            child:
                                                                                Column(
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
                                                                                      myPostProvider.deletePost(myPostProvider.duplicatePostlist[index].createdBy, myPostProvider.duplicatePostlist[index].postId);
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
                                                                  //
                                                                  // myPostProvider.deletePost(
                                                                  //     myPostProvider
                                                                  //         .duplicatePostlist[
                                                                  //             index]
                                                                  //         .createdBy,
                                                                  //     myPostProvider
                                                                  //         .duplicatePostlist[
                                                                  //             index]
                                                                  //         .postId);
                                                                },
                                                                child:
                                                                    Container(
                                                                  child: Icon(
                                                                    CupertinoIcons
                                                                        .delete,
                                                                    size: 26.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        myPostProvider
                                                                    .duplicatePostlist[
                                                                        index]
                                                                    .textPost !=
                                                                null
                                                            ? Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                                child: Text(
                                                                  myPostProvider
                                                                      .duplicatePostlist[
                                                                          index]
                                                                      .textPost,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20.0,
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox.shrink(),
                                                      ],
                                                    )
                                                  : SizedBox.shrink(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0, top: 20.0),
                                            child: StreamBuilder(
                                                stream: myPostProvider
                                                    .firebaseController
                                                    .postColReference
                                                    .doc(myPostProvider
                                                        .duplicatePostlist[
                                                            index]
                                                        .postId)
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  if (!snapshot.hasData)
                                                    return Center(
                                                      child: Text("0"),
                                                    );
                                                  var data = snapshot.data;
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          CupertinoIcons.heart),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(data['likesCount'] !=
                                                              null
                                                          ? data['likesCount']
                                                              .toString()
                                                          : "0"),
                                                      SizedBox(
                                                        width: 60,
                                                      ),
                                                      GestureDetector(
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          onTap: data['commentsCount'] ==
                                                                      null &&
                                                                  data['commentsCount'] ==
                                                                      "0"
                                                              ? null
                                                              : () {
                                                                  myPostProvider
                                                                      .changeCommentsVisibility(
                                                                          index,
                                                                          data[
                                                                              "postId"]);
                                                                },
                                                          child: myPostProvider
                                                                      .isTapped &&
                                                                  myPostProvider
                                                                          .currentIndex ==
                                                                      index
                                                              ? Icon(
                                                                  CupertinoIcons
                                                                      .chat_bubble_text_fill,
                                                                  color: mRed,
                                                                )
                                                              : Icon(CupertinoIcons
                                                                  .chat_bubble_text)),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(data['commentsCount'] !=
                                                              null
                                                          ? data['commentsCount']
                                                              .toString()
                                                          : "0"),
                                                    ],
                                                  );
                                                }),
                                          ),
                                          Visibility(
                                              visible: myPostProvider
                                                          .isTapped &&
                                                      myPostProvider
                                                              .currentIndex ==
                                                          index
                                                  ? true
                                                  : false,
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30.0),
                                                  alignment: Alignment.center,
                                                  child: myPostProvider
                                                          .isLoadingComment
                                                      ? Container(
                                                          height: 30.0,
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                            strokeWidth: 1,
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                          )))
                                                      : myPostProvider
                                                                  .commentList
                                                                  .length >
                                                              0
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  myPostProvider
                                                                      .commentList
                                                                      .length,
                                                              shrinkWrap: true,
                                                              itemBuilder: (context,
                                                                  commentIndex) {
                                                                return Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          10.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      StreamBuilder(
                                                                          stream: myPostProvider
                                                                              .firebaseController
                                                                              .userColReference
                                                                              .doc(myPostProvider.commentList[commentIndex][
                                                                                  'commentBy'])
                                                                              .get()
                                                                              .asStream(),
                                                                          builder:
                                                                              (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                                            if (!snapshot.hasData)
                                                                              return SizedBox.shrink();
                                                                            CreateAccountData
                                                                                commentUserData =
                                                                                CreateAccountData.fromDocument(snapshot.data.data());
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
                                                                        height:
                                                                            4.0,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              StreamBuilder(
                                                                                  stream: myPostProvider.firebaseController.postColReference.doc(myPostProvider.commentList[commentIndex]["postId"]).collection(commentsLikesCollectionName).where("likedBy", isEqualTo: myPostProvider.userdata.uid).where("commentId", isEqualTo: myPostProvider.commentList[commentIndex]["commentId"]).limit(1).snapshots(),
                                                                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                    if (!snapshot.hasData) return Container();

                                                                                    if (snapshot.data.docs.isEmpty) {
                                                                                      return Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                                                                        child: Icon(CupertinoIcons.heart),
                                                                                      );
                                                                                    } else {
                                                                                      return Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                                                                        child: Icon(CupertinoIcons.heart_solid),
                                                                                      );
                                                                                    }
                                                                                  }),
                                                                              StreamBuilder(
                                                                                  stream: myPostProvider.firebaseController.postColReference.doc(myPostProvider.posts[index].postId).collection(commentCollectionName).doc(myPostProvider.commentList[commentIndex]["commentId"]).snapshots(),
                                                                                  builder: (context, AsyncSnapshot snapshot) {
                                                                                    if (!snapshot.hasData)
                                                                                      return Center(
                                                                                        child: SizedBox.shrink(),
                                                                                      );
                                                                                    else if (snapshot.connectionState == ConnectionState.waiting)
                                                                                      return Center(
                                                                                        child: Text("0"),
                                                                                      );
                                                                                    else {
                                                                                      var data = snapshot.data.data();
                                                                                      print(data);
                                                                                      return data != null && data["likesCount"] != null ? Text(data["likesCount"].toString()) : SizedBox.shrink();
                                                                                    }
                                                                                  }),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                6.0,
                                                                          ),
                                                                          myPostProvider.commentList[commentIndex]["comment"] != ""
                                                                              ? Expanded(
                                                                                  child: ReadMoreText(
                                                                                    myPostProvider.commentList[commentIndex]["comment"],
                                                                                    colorClickableText: Colors.black,
                                                                                    trimLines: 3,
                                                                                    style: TextStyle(
                                                                                      color: themeProvider.isDarkMode ? Colors.white : black,
                                                                                    ),
                                                                                    moreStyle: TextStyle(fontWeight: FontWeight.bold),
                                                                                    lessStyle: TextStyle(fontWeight: FontWeight.bold),
                                                                                    trimMode: TrimMode.Line,
                                                                                    trimCollapsedText: '...show more',
                                                                                    trimExpandedText: ' show less',
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                );
                                                              })

                                                          /* ListView.builder(
                                                              itemCount:
                                                                  myPostProvider
                                                                      .commentList
                                                                      .length,
                                                              shrinkWrap: true,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Container(
                                                                  decoration: BoxDecoration(
                                                                      border: Border(
                                                                          bottom: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                    width: 2,
                                                                  ))),
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            10,
                                                                        top: 5),
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .3,
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20.0),
                                                                            */ /* child: Image.network(),*/ /*
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              15.0,
                                                                        ),
                                                                        Text(myPostProvider.commentList[index]
                                                                            [
                                                                            "comment"]),
                                                                        Icon(CupertinoIcons
                                                                            .heart),
                                                                        SizedBox(
                                                                          width:
                                                                              12.0,
                                                                        ),
                                                                        StreamBuilder(
                                                                            stream:
                                                                                myPostProvider.firebaseController.postColReference.doc(myPostProvider.commentList[index]["postId"]).collection(commentCollectionName).where("commentId", isEqualTo: myPostProvider.commentList[index]["commentId"]).snapshots(),
                                                                            builder: (context, AsyncSnapshot snapshot) {
                                                                              if (!snapshot.hasData)
                                                                                return Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                );
                                                                              var data = snapshot.data;
                                                                              return data == null ? SizedBox.shrink() : Text(data.docs[0]["likesCount"] != null ? data.docs[0]["likesCount"].toString() : "0");
                                                                            })
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              })*/
                                                          : SizedBox.shrink(),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )));
    });
  }
}
