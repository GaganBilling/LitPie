import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/controller/rewardCollectController.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../variables.dart';

class RoseCollec extends StatefulWidget {
  @override
  _RoseState createState() => _RoseState();
}

class _RoseState extends State<RoseCollec> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  RewardCollectController _rewardCollectController;
  ThemeProvider themeProvider;

  RewardCollectController rewardCollectProvider;
  SharedPreferences pref;


  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    rewardCollectProvider =
        Provider.of<RewardCollectController>(context, listen: false);

    kInit();
    rewardCollectProvider.getRoseCount();

    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
  }
  kInit() async {
    pref = await SharedPreferences.getInstance();
    pref.setInt("lastRewardEarnedTimestamp",0);
  }

  void _handleOnPressed() {
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 1000), () {
      _animationController.reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rewardCollectController.watchAdCountdownTimer?.cancel(); //dispose
    _rewardCollectController.dailyCollectCountdownTimer?.cancel(); //dispose
    super.dispose();
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Consumer<RewardCollectController>(
        builder: (context, rewardController, child) {
      _rewardCollectController = rewardController;
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mRed,
          actions: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 3.0).animate(_animationController),
              child: IconButton(
                splashRadius: 30.0,
                icon: Icon(
                  (CupertinoIcons.refresh_circled),
                  size: 35,
                ),
                onPressed: () {
                  _handleOnPressed();
                  rewardController.getRoseCount();

                },
              ),
            ),
            IconButton(
              splashRadius: 30.0,
              icon: Icon(
                Icons.info_outline,
                size: 35,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext buildContext) {
                      return SimpleDialog(
                        contentPadding: EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Colors.blueGrey.withOpacity(0.8),
                        children: [
                          Row(
                            children: [
                              Text("Watch Video".tr() + ":-",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'Handlee',
                                      fontWeight: FontWeight.w700,
                                      color: white,
                                      decoration: TextDecoration.none,
                                      fontSize: 22)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "By watching the short video you'll get 5 Fresh LitPie's in received and 1 Fresh LitPie in collection."
                                  .tr(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: white,
                                  decoration: TextDecoration.none,
                                  fontSize: 18)),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text("Daily Collect".tr() + ":-",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'Handlee',
                                      fontWeight: FontWeight.w700,
                                      color: white,
                                      decoration: TextDecoration.none,
                                      fontSize: 22)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "By pressing on Daily Collect you'll get 13 Fresh LitPie's in collection."
                                  .tr(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: white,
                                  decoration: TextDecoration.none,
                                  fontSize: 18)),
                        ],
                      );
                    });
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: rewardController.likeCountDoc == null
                  ? Center(
                      child: LinearProgressCustomBar(),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              80,
                            ),
                          ),
                          child:
                              themeProvider.isDarkMode
                                  ? SizedBox(
                                      child: Image.asset(
                                          "assets/images/litpielogo.png"),
                                      height: _screenWidth >= miniScreenWidth
                                          ? 80
                                          : 70,
                                    )
                                  : Image.asset("assets/images/litpielogo.png"),
                          height: _screenWidth >= miniScreenWidth ? 80 : 70,
                        ),
                        Text(
                          "LitPie's",
                          style: TextStyle(
                            color: mRed,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  children: [
                                    Text(
                                        rewardController.roseRec >= 1000
                                            ? NumberFormat.compact().format(
                                                rewardController.roseRec)
                                            : "${rewardController.roseRec}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500)
                                        //style: TextStyle(color: black),
                                        ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "Received".tr(),
                                      style: TextStyle(
                                          fontFamily: 'Handlee',
                                          fontWeight: FontWeight.w700,
                                          color: themeProvider.isDarkMode
                                              ? white
                                              : black,
                                          decoration: TextDecoration.none,
                                          fontSize: 22),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  children: [
                                    Text(
                                        rewardController.roseColl >= 1000
                                            ? NumberFormat.compact().format(
                                                rewardController.roseColl)
                                            : "${rewardController.roseColl}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500)
                                        //style: TextStyle(color: black),
                                        ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "Collection".tr(),
                                      style: TextStyle(
                                          fontFamily: 'Handlee',
                                          fontWeight: FontWeight.w700,
                                          color: themeProvider.isDarkMode
                                              ? white
                                              : black,
                                          decoration: TextDecoration.none,
                                          fontSize: 22),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        50.0, 15.0, 50.0, 10.0),
                                    child: ElevatedButton(
                                      child: Text(
                                          rewardController.adBtnTimerDuration
                                                      .inSeconds >
                                                  0
                                              ? "${rewardController.adBtnTimerDuration.toString().split('.').first.padLeft(8, "0")}"
                                              : "Watch Video".tr(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600)),
                                      onPressed:
                                          rewardController.adCollectBtnEnabled
                                              ? () {
                                                  print("Reward by Ad Opened");
                                                  rewardController
                                                      .collectRewardByAd();
                                                }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        primary: mRed,
                                        onPrimary: white,
                                        elevation: 5,
                                        side: BorderSide(color: mRed, width: 2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.7)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        50.0, 15.0, 50.0, 10.0),
                                    child: ElevatedButton(
                                      child: Text(
                                          rewardController.freeBtnTimerDuration !=
                                                      null &&
                                                  rewardController
                                                          .freeBtnTimerDuration
                                                          .inSeconds >
                                                      0
                                              ? "${rewardController.freeBtnTimerDuration.toString().split('.').first.padLeft(8, "0")}"
                                              : "Daily Collect".tr(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600)),
                                      onPressed: rewardController
                                              .freeCollectBtnEnabled
                                          ? () {
                                              print("Collected");
                                              showRoseDialog(context);
                                              rewardController
                                                  .updateRewardByFree();
                                              Fluttertoast.showToast(
                                                  msg: "Collected".tr(),
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 3,
                                                  backgroundColor: mRed,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        primary: mRed,
                                        onPrimary: white,
                                        elevation: 5,
                                        side: BorderSide(color: mRed, width: 2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.7)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "LitPie once given to the other\n user by you cannot be taken back."
                                .tr(),
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
        ),
      );
    });
  }

  Future showRoseDialog(context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext buildContext) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
            //  Navigator.push(context, CupertinoPageRoute(builder: (context) => Welcome()));
          });
          return Center(
            child: Container(
              margin: EdgeInsets.all(100.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.transparent,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 5)
                ],
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              width: _screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              height: _screenWidth >= miniScreenWidth ? 80.0 : 60.0,
              child: themeProvider.isDarkMode
                  ? Image.asset(
                      "assets/images/litpielogo.png",
                      height: _screenWidth >= miniScreenWidth ? 50 : 40,
                    )
                  : Image.asset(
                      "assets/images/litpielogo.png",
                      height: _screenWidth >= miniScreenWidth ? 50 : 40,
                    ),
            ),
          );
        });
  }
}
