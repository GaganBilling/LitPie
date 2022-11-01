import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/UnKnownInformation.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:litpie/variables.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PlanPage extends StatefulWidget {
  PlanPage({
    Key key,
    @required this.pUser,
    @required this.pDoc,
    @required this.index,
    @required this.themeProvider,
    @required this.currentUser,
    @required this.cancelRequest,
    @required this.sendRequestData,
  }) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();

  final int index;
  final Object pUser;
  final Object pDoc;
  final ThemeProvider themeProvider;
  final CreateAccountData currentUser;
  final Function(int index, CreateAccountData planUser) cancelRequest;
  final Function(int index, CreateAccountData planUser) sendRequestData;
}

class _PlanPageState extends State<PlanPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  CollectionReference docRef = FirebaseFirestore.instance.collection('Plans');
  FirebaseController firebaseController = FirebaseController();
  CreateAccountData userAccountData;
  double durationPercentage;
  @override
  void initState() {
    getUserData();
    // TODO: implement initState
    super.initState();
  }

  void reportPost(
    CreateAccountData accountData,
    pdoc,
  ) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => ReportUser(
              currentUserUID: widget.currentUser.uid,
              secondUserUID: accountData.uid,
              mediaID: pdoc.toString(),
              typeOfReport: TypeOfReport.explorePlan,
            ));
  }

  double getDurationPercentage(Timestamp startDate, Timestamp endDate) {
    DateTime start = startDate.toDate();
    DateTime end = endDate.toDate();
    int totalDiff = end.difference(start).inSeconds;
    int currentDiff = DateTime.now().difference(end).inSeconds.abs();
    print(startDate.toDate().toString());
    double percentage = ((( totalDiff - currentDiff) / currentDiff));
    print(percentage);
    int totalDays = end.difference(start).inDays;
    int totalDaysFromNow = end.difference(DateTime.now()).inDays;
    print(totalDays);
    print(totalDaysFromNow);
    print(totalDays/totalDaysFromNow);
    print(totalDays%totalDaysFromNow);
    print("md- per -- "+ MediaQuery.of(context).size.width.toString());
    print(percentage);

    if (percentage > 0 && percentage < 0.02) {
      return 0.1;
    } else if (percentage > 0.02 && percentage < 0.03) {
      return 0.15;
    } else if (percentage >= 0.03 && percentage < 0.04 ) {
      return 0.2;
    } else if (percentage > 0.04 && percentage < 0.05) {
      return 0.25;
    } else if (percentage >= 0.05 && percentage < 0.06 ) {
      return 0.3;
    } else if (percentage > 0.06 && percentage < 0.07) {
      return 0.35;
    } else if (percentage >= 0.07 && percentage < 0.08 ) {
      return 0.4;
    }else if (percentage >= 0.08 && percentage < 0.09 ) {
      return 0.45;
    } else if (percentage >= 0.09 && percentage <0.5) {
      return percentage;
    } else if (percentage >= 0.5 && percentage <0.6) {
      return 0.5;
    }  else if (percentage >= 0.9 && percentage <1.5) {
      return 0.85;
    }else if (percentage >= 1.5 && percentage <2.0) {
      return 0.9;
    }  else if (percentage >= 2 && percentage <6) {
      return 0.95;
    } else {
      return 1.0;
    }
    return percentage.abs();
  }

  void detailDialog(context, String detail) async {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Padding(
            padding: _screenWidth >= miniScreenWidth
                ? const EdgeInsets.only(top: 200.0, bottom: 200)
                : const EdgeInsets.only(top: 120.0, bottom: 120),
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
    // showDialog(
    //     context: context,
    //     builder: (BuildContext buildContext) {
    //       return Padding(
    //         padding: const EdgeInsets.only(top:200.0,bottom: 200),
    //         child: AlertDialog(
    //           backgroundColor: Colors.blueGrey.withOpacity(0.5),
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //           content: Scrollbar(
    //             radius: Radius.circular(20),
    //             thickness: 5,
    //             isAlwaysShown: true,
    //             child:
    //             Container(
    //               alignment: Alignment.center,
    //               //height:200,
    //               // width: 300,
    //               child: SingleChildScrollView(
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: [
    //                     Text("$detail",
    //                         textAlign: TextAlign.center,
    //                         style: TextStyle(
    //                             letterSpacing: 1.3,
    //                             fontFamily: 'Handlee',
    //                             fontWeight: FontWeight.w700,
    //                             color: white,
    //                             decoration: TextDecoration.none,
    //                             fontSize: 22)),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ) ,
    //         ),
    //       );
    //     });
  }

  Stream<DocumentSnapshot> planRequestStream(
      {@required CreateAccountData anotherUser}) {
    Map<String, dynamic> pdoc = widget.pDoc;
    String pUser = widget.pUser;
    return docRef
        .doc(pdoc['planId'])
        .collection('planRequest')
        .doc(pUser)
        .snapshots();
  }

  Widget buildRequestButton(
      {@required String title, @required VoidCallback onTap}) {
    return Container(
      // width: 300.0,
      height: 50.0,
      constraints: BoxConstraints(
        minWidth: 300.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: mRed,
          onPrimary: white,
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        onPressed: onTap,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: _screenWidth >= miniScreenWidth ? 35 : 25,
              fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    if (userAccountData == null) {
      return Center(
        child: SizedBox(),
      );
    } else {
      CreateAccountData pdata = userAccountData;
      print(pdata);
      Map<String, dynamic> pdoc = widget.pDoc;

      return Scaffold(
        key: UniqueKey(),
        body: Transform.scale(
          scale: 0.9,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, right: 0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: widget.themeProvider.isDarkMode
                          ? Colors.white70
                          : black,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 1),
                ],
                color: mRed,
                borderRadius: BorderRadius.circular(
                  30,
                ),
              ),
              child: Card(
                  color: widget.themeProvider.isDarkMode ? black : white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: mRed,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "${pdoc['pName']}".toUpperCase(),
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 25
                                                  : 20,
                                          color: white),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        reportPost(pdata, pdoc['planId']);
                                      },
                                      child: Container(
                                        child: Icon(
                                          CupertinoIcons.flag,
                                          size: 26.0,
                                          color: white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // LinearPercentIndicator(
                        //   key: new UniqueKey(),
                        //   backgroundColor: Colors.blueGrey[200],
                        //   progressColor: getDurationPercentage(
                        //               /*planDoc["createdAt"],*/
                        //               pdoc["createdAt"],
                        //               /* planDoc
                        //                   ["pTimeStamp"])*/
                        //               pdoc["pTimeStamp"]) <=
                        //           0.90
                        //       ? Colors.green
                        //       : Colors.red,
                        //   lineHeight: 8.0,
                        //   percent: durationPercentage = getDurationPercentage(
                        //           pdoc["createdAt"], pdoc["pTimeStamp"]),
                        // ),
                        Tooltip(
                          message: "Post Duration".tr(),
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width-10,
                            lineHeight: 14.0,
                            barRadius: Radius.circular(5),
                            percent: getDurationPercentage(pdoc["createdAt"],
                              pdoc["pTimeStamp"]),
                            progressColor: Colors.green,
                          ),
                          // Container(
                          //   height: 16,
                          //   padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 2.0),
                          //   width: ( MediaQuery.of(context).size.width- *getDurationPercentage(pdoc["createdAt"],
                          //       pdoc["pTimeStamp"])
                          //       ),
                          //   child: Container(
                          //     width: MediaQuery.of(context).size.width,
                          //     decoration: BoxDecoration(
                          //       color: Colors.blueGrey,
                          //       borderRadius: BorderRadius.circular(10.0),
                          //     ),
                          //     child: Container(
                          //       constraints: BoxConstraints(
                          //         minWidth: double.infinity,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         color: getDurationPercentage(
                          //                     /*planDoc["createdAt"],*/
                          //                     pdoc["createdAt"],
                          //                     /* planDoc
                          //                 ["pTimeStamp"])*/
                          //                     pdoc["pTimeStamp"]) <=
                          //                 9
                          //             ? Colors.green
                          //             : Colors.red,
                          //         borderRadius: BorderRadius.circular(10.0),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  //here
                                  if (widget.currentUser != null) {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return UnknownInfo(
                                              pdata, widget.currentUser);
                                        });
                                  }
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Card(
                                    child: pdoc["planplacepic"] != null &&
                                            pdoc["planplacepic"].isNotEmpty
                                        ? CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                pdoc["planplacepic"].isNotEmpty
                                                    ? pdoc["planplacepic"]
                                                    : pdata.profilepic,
                                            useOldImageOnUrlChange: true,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              radius: 15,
                                            ),
                                            errorWidget:
                                                (context, url, error) => Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.blueGrey,
                                                  size: 30,
                                                ),
                                                Text(
                                                  "Enable to load".tr(),
                                                  style: TextStyle(
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : pdata.profilepic == null
                                            ? Image.asset(placeholderImage,
                                                fit: BoxFit.cover)
                                            : CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: pdata.profilepic,
                                                useOldImageOnUrlChange: true,
                                                placeholder: (context, url) =>
                                                    CupertinoActivityIndicator(
                                                  radius: 15,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.blueGrey,
                                                      size: 30,
                                                    ),
                                                    Text(
                                                      "Enable to load".tr(),
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                            height: 30,
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.only(top: 5.0),
                                          //   child: Text(
                                          //     " ${pdata.age},",
                                          //     // textAlign: TextAlign.center,
                                          //     style: TextStyle(
                                          //       color: white,
                                          //       fontSize: 14,
                                          //       fontWeight: FontWeight.w500,
                                          //       shadows: [
                                          //         Shadow(
                                          //             blurRadius: 13,
                                          //             color: Colors.black
                                          //                 .withOpacity(0.5),
                                          //             offset: Offset(1.0, 1.0))
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                "${pdata.name},".toUpperCase(),
                                                style: TextStyle(
                                                  color: white,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 22
                                                      : 18,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 13,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        offset:
                                                            Offset(1.0, 1.0))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      /* Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.accessibility_rounded,
                                                size: 14,
                                                color: white,
                                              ),
                                              Text(
                                                pdata?.distanceBW != null
                                                    ? pdata.distanceBW <= 5
                                                        ? " Less than 5 Km.".tr()
                                                        : pdata.distanceBW >= 1000
                                                            ? NumberFormat.compact().format(pdata.distanceBW) + " Km. approx. ".tr()
                                                            : "${pdata.distanceBW}" + " Km. approx. ".tr()
                                                    : "",
                                                style: TextStyle(
                                                  shadows: [Shadow(blurRadius: 13, color: Colors.black.withOpacity(0.5), offset: Offset(1.0, 1.0))],
                                                  color: white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),*/
                                      Expanded(
                                        child: Align(
                                          alignment:
                                              FractionalOffset.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 8.0, top: 5),
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.bottomLeft,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      reverse: true,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            "At:- ".tr() +
                                                                " ${pdoc['pVenue']}," +
                                                                "  ${pdoc['pCity']},",
                                                            style: TextStyle(
                                                              shadows: [
                                                                Shadow(
                                                                    blurRadius:
                                                                        13,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    offset:
                                                                        Offset(
                                                                            1.0,
                                                                            1.0))
                                                              ],
                                                              color: white,
                                                              fontSize: 18,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 8.0, top: 5),
                                        child: Row(
                                          children: [
                                            Text(
                                              "On:- ".tr(),
                                              style: TextStyle(
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 13,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      offset: Offset(1.0, 1.0))
                                                ],
                                                color: white,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              "${pdoc['pDate']},",
                                              style: TextStyle(
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 13,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      offset: Offset(1.0, 1.0))
                                                ],
                                                color: white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                reverse: true,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Time:-".tr() +
                                                          " ${pdoc['pTimeBegin']} " +
                                                          "to ".tr() +
                                                          " ${pdoc['pTimeEnd']}",
                                                      style: TextStyle(
                                                        shadows: [
                                                          Shadow(
                                                              blurRadius: 13,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.5),
                                                              offset: Offset(
                                                                  1.0, 1.0))
                                                        ],
                                                        color: white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => detailDialog(
                                            context, pdoc['pDoing']),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 8.0, top: 5),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Detail:- ".tr(),
                                                style: TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 13,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        offset:
                                                            Offset(1.0, 1.0))
                                                  ],
                                                  color: white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    "${pdoc['pDoing']}",
                                                    style: TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                            blurRadius: 13,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            offset: Offset(
                                                                1.0, 1.0))
                                                      ],
                                                      color: white,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (pdata.isVaccinated != null)
                                if (pdata.isVaccinated)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: new Tooltip(
                                      key: toolTipKey,
                                      message: "I Am Vaccinated".tr(),
                                      textStyle: TextStyle(color: Colors.white),
                                      decoration: BoxDecoration(
                                        color: mRed,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          // toolTipKey.currentState.ensureTooltipVisible();
                                          final dynamic tooltip =
                                              toolTipKey.currentState;
                                          tooltip.ensureTooltipVisible();

                                          Timer(Duration(seconds: 1), () {
                                            toolTipKey.currentState
                                                .deactivate();
                                          });
                                        },
                                        child: Container(
                                          width: 35,
                                          height: 35,
                                          child: Image.asset(
                                            "assets/images/vaccinatedPic.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 35,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: widget.themeProvider.isDarkMode
                                      ? black
                                      : white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(22),
                                    bottomRight: Radius.circular(22),
                                  ),
                                ),
                                child: ListTile(
                                  title: Center(
                                    child: Wrap(
                                      spacing: 0,
                                      children: [
                                        if (widget.currentUser != null)
                                          StreamBuilder<DocumentSnapshot>(
                                              stream: planRequestStream(
                                                  anotherUser: pdata),
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          DocumentSnapshot>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data.exists) {
                                                    if (snapshot
                                                            .data["request"] ==
                                                        "sent") {
                                                      return buildRequestButton(
                                                          title: "Cancel".tr(),
                                                          onTap: () {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            widget
                                                                .cancelRequest(
                                                                    widget
                                                                        .index,
                                                                    pdata);
                                                            //Cancel onTap
                                                            // cancelRequest(
                                                            //     widget.index,
                                                            //     planUser);
                                                          });
                                                    } else {
                                                      return buildRequestButton(
                                                          title: "Send Interest"
                                                              .tr(),
                                                          onTap: () async {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            widget
                                                                .sendRequestData(
                                                                widget.index,
                                                                pdata);
                                                          });
                                                    }
                                                  } else {
                                                    print(widget.currentUser.uid);
                                                    print(FirebaseAuth.instance.currentUser.uid);
                                                    return (FirebaseAuth.instance.currentUser.uid == pdata.uid) ?
                                                    buildRequestButton(
                                                        title: "Delete22"
                                                            .tr(),
                                                        onTap: () async {

                                                          await docRef .where("pdataOwnerID", isEqualTo: pdata.uid).get()
                                                              .then((value) async {
                                                            print(value.docs[0]['planId']);
                                                            await docRef.doc(value.docs[0]['planId']).delete().then((value) => {

                                                              Fluttertoast.showToast(
                                                                  msg: "Plan Deleted!!".tr(),
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.BOTTOM,
                                                                  timeInSecForIosWeb: 3,
                                                                  backgroundColor: Colors.blueGrey,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0),

                                                              Navigator.pop(context)

                                                            });

                                                          });


                                                        })
                                                        :
                                                     buildRequestButton(
                                                        title: "Send Interest"
                                                            .tr(),
                                                        onTap: () {
                                                          HapticFeedback
                                                              .heavyImpact();
                                                          widget
                                                              .sendRequestData(
                                                                  widget.index,
                                                                  pdata);
                                                        });
                                                  }
                                                } else {
                                                  return buildRequestButton(
                                                      title:
                                                          "Send Interest".tr(),
                                                      onTap: () {
                                                        HapticFeedback
                                                            .heavyImpact();
                                                        widget.sendRequestData(
                                                            widget.index,
                                                            pdata);
                                                      });
                                                }
                                              }),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      );
    }
  }

  Future<CreateAccountData> getUserData() async {
    var userData = await firebaseController.userColReference
        .where("uid", isEqualTo: widget.pUser)
        .get();
    userAccountData = await CreateAccountData.fromJson(userData.docs[0].data());
    if (mounted) setState(() {});
    print(userAccountData);
    return userAccountData;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
