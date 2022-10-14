import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/swipe_provider.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaDetailScreen.dart';
import 'package:litpie/media/videoDetail/videoDetailScreen.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/swipeCardModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/ShimmerWidget.dart';
import 'package:litpie/widgets/moreOptionDialog.dart';
import 'package:litpie/widgets/photoCard.dart';
import 'package:litpie/widgets/swipeStack.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:easy_localization/easy_localization.dart';

class SwipeScreen extends StatefulWidget {
  final TabController parentTabController;

  const SwipeScreen({Key key, @required this.parentTabController})
      : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  ThemeProvider themeProvider;
  SwipeProvider swipeProvider;

  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    swipeProvider = Provider.of<SwipeProvider>(context, listen: false);
    swipeProvider.exceedSwipes = swipeCount >= swipeProvider.freeSwipe;


    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    swipeProvider = Provider.of<SwipeProvider>(context);
    print("inside swipe screen - "+ swipeProvider.swipeCardModelList.length.toString());

    swipeProvider.screenWidth = MediaQuery.of(context).size.width;
    return Consumer<SwipeProvider>(builder: (context, swipeProvider, child) {
      Future.delayed(Duration(seconds: 0), () {
        if (!swipeProvider.isFetching) {
          if (swipeProvider.swipeCardModelList.length <= 0) {
            if (widget.parentTabController.index == 0 && mounted) {
              Fluttertoast.showToast(
                  msg: "Moving to Next".tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                  fontSize: 16.0);
              widget.parentTabController.animateTo(1);
            }
          }
        }
      });
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: mRed,
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? dRed : white,
          ),
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: swipeProvider.exceedSwipes,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? dRed : white,
                      ),
                      height: double.infinity,
                      child: swipeProvider.isFetching
                              ? SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 10.0),
                                    child: Shimmer.fromColors(
                                      baseColor: themeProvider.isDarkMode
                                          ? Colors.black26
                                          : Colors.grey[300],
                                      highlightColor: themeProvider.isDarkMode
                                          ? Colors.white10
                                          : Colors.grey[100],
                                      period: Duration(milliseconds: 1500),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 9,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ShimmerWidget.rectangular(
                                                        width: 200, height: 15),
                                                    SizedBox(height: 7.0),
                                                    ShimmerWidget.rectangular(
                                                        width: 300, height: 10),
                                                    SizedBox(height: 7.0),
                                                    ShimmerWidget.rectangular(
                                                        width: 300, height: 10),
                                                    SizedBox(height: 7.0),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ShimmerWidget.circular(
                                                    width: 40.0,
                                                    height: 40.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          ShimmerWidget.circular(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.50,
                                            shapeBorder: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Container(
                                            child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 15.0),
                                              itemBuilder: (context, index) =>
                                                  ShimmerWidget.circular(
                                                width: 100.0,
                                                height: 100.0,
                                                shapeBorder:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              itemCount: 3,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              primary: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : (swipeProvider.swipeCardModelList.length == 0
                                  ? Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: lRed,
                                                  radius: 80,
                                                  child: Icon(
                                                    Icons.accessibility,
                                                    size: 140,
                                                    color: white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Text(
                                              "There's no one new around you,\n it's time to plan or explore a DATE \n or WAVE to the people near by or \n create or see new POST"
                                                  .tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.w700,
                                                  color: lRed,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: swipeProvider
                                                              .screenWidth >=
                                                          miniScreenWidth
                                                      ? 25
                                                      : 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SwipeStackCustom(
                                      key: swipeProvider.swipeKey,
                                      padding: EdgeInsets.fromLTRB(
                                          7.0, 20.0, 7.0, 10.0),
                                      children: swipeProvider.swipeCardModelList
                                          .map((swipeCardObj) {
                                        return SwiperItem(builder:
                                            (SwiperPosition position,
                                                double progress) {
                                          SwipeCardModel swipeCard =
                                              swipeCardObj;
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .70,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Container(
                                                            // height: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              color: themeProvider
                                                                      .isDarkMode
                                                                  ? dRed
                                                                  : white,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 7.0),
                                                                          child:
                                                                              Text(
                                                                            " ${swipeCard.createAccountData.age},",
                                                                            // textAlign: TextAlign.center,
                                                                            style:
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            child:
                                                                                Text(
                                                                              " ${swipeCard.createAccountData.name}".toUpperCase(),
                                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.accessibility_rounded,
                                                                              size: 14,
                                                                              color: themeProvider.isDarkMode ? Colors.white : black,
                                                                            ),
                                                                            swipeCard.createAccountData.distanceBW != null ? Text(
                                                                              swipeCard.createAccountData.distanceBW <= 5
                                                                                  ? " Less than 5 Km.".tr()
                                                                                  : swipeCard.createAccountData.distanceBW >= 1000
                                                                                      ? NumberFormat.compact().format(swipeCard.createAccountData.distanceBW) + " Km. approx. ".tr()
                                                                                      : "${swipeCard.createAccountData.distanceBW}" + " Km. approx. ".tr(),
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                              ),
                                                                            ) : Text(""),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(Icons.location_on_outlined,
                                                                                size: 13,
                                                                                color: mRed),
                                                                            Expanded(
                                                                              child: Text(
                                                                                "${swipeCard.createAccountData.address}",
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(0),
                                                            child: Column(
                                                              children: [
                                                                // Divider(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  child: swipeProvider
                                                                              .swipeCardModelList
                                                                              .length !=
                                                                          0
                                                                      ? FloatingActionButton(
                                                                          heroTag:
                                                                              UniqueKey(),
                                                                          elevation:
                                                                              0,
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          shape:
                                                                              StadiumBorder(side: BorderSide(color: mRed, width: 2)),
                                                                          child: themeProvider.isDarkMode
                                                                              ? Padding(
                                                                                  padding: const EdgeInsets.only(left: 6.0, top: 6, right: 6, bottom: 2),
                                                                                  child: Image.asset(
                                                                                    "assets/images/litpielogo.png",
                                                                                  ),
                                                                                )
                                                                              : Padding(
                                                                                  padding: const EdgeInsets.only(left: 6.0, top: 6, right: 6, bottom: 2),
                                                                                  child: Image.asset("assets/images/litpielogo.png"),
                                                                                ),
                                                                          onPressed:
                                                                              () {
                                                                            HapticFeedback.heavyImpact();
                                                                            if (swipeProvider.swipeCardModelList.length >
                                                                                0) {
                                                                              print("Tap");
                                                                              swipeProvider.checkRoseCount(
                                                                                swipeCard.createAccountData,
                                                                                context,
                                                                              );
                                                                              //  swipeKey.currentState.swipeRight();
                                                                            }
                                                                          },
                                                                        )
                                                                      : Container(),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                  if (swipeCard.stories !=
                                                          null &&
                                                      swipeCard.stories.stories
                                                              .length >
                                                          0)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        height: 100,
                                                        child: GridView.builder(
                                                            physics:
                                                                AlwaysScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            itemCount: swipeCard
                                                                .stories
                                                                .stories
                                                                .length,
                                                            gridDelegate:
                                                                SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  200,
                                                              mainAxisSpacing:
                                                                  10,
                                                              childAspectRatio:
                                                                  2 / 2,
                                                              crossAxisSpacing:
                                                                  20,
                                                            ),
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              var story = swipeCard
                                                                      .stories
                                                                      .stories[
                                                                  index];

                                                              return InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (context) => StoryMediaDetailScreen(
                                                                                allStories: swipeCard.stories,
                                                                                storyIndex: index,
                                                                                userUID: swipeCard.createAccountData.uid,
                                                                              )))
                                                                      .whenComplete(() {
                                                                    setState(
                                                                        () {});
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  height: 130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: mYellow.withOpacity(
                                                                              0.8),
                                                                          // color: Colors.blueGrey,
                                                                          offset: Offset(2,
                                                                              2),
                                                                          spreadRadius:
                                                                              1,
                                                                          blurRadius:
                                                                              1)
                                                                    ],
                                                                    color: mRed,
                                                                    border: Border.all(
                                                                        color: mRed.withOpacity(
                                                                            0.7),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      100,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(100)),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          130,
                                                                      child:
                                                                          Center(
                                                                        child: story.type ==
                                                                                "video"
                                                                            ? Icon(
                                                                                Icons.play_arrow_rounded,
                                                                                size: 50,
                                                                                color: Colors.black.withOpacity(0.7),
                                                                              )
                                                                            : Container(),
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(
                                                                            story.type == "video"
                                                                                ? apiStoriesURL + story.thumbnailUrl
                                                                                : apiStoriesURL + story.url,
                                                                          ),
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ),
                                                    ),

                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Material(
                                                    color:
                                                        themeProvider.isDarkMode
                                                            ? dRed
                                                            : white,
                                                    elevation: 2,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      child: Container(
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: swipeProvider
                                                                          .screenWidth >=
                                                                      miniScreenWidth
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      .55
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      .50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      offset:
                                                                          Offset(2,
                                                                              2),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          3),
                                                                ],
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)),
                                                                color: themeProvider
                                                                        .isDarkMode
                                                                    ? dRed
                                                                    : white,
                                                              ),
                                                              child: Stack(
                                                                children: <
                                                                    Widget>[
                                                                  Center(
                                                                    child: Text(
                                                                      "Loading....."
                                                                          .tr(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          color:
                                                                              white),
                                                                    ),
                                                                  ),
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20)),
                                                                    child:
                                                                        PhotoBrowser(
                                                                      user: swipeCard
                                                                          .createAccountData,
                                                                      // imageUrl :
                                                                      //  index.imageUrl.isEmpty? imageUrl2:
                                                                      //  index.imageUrl ?? "" ,
                                                                      images: swipeCard.images !=
                                                                              null
                                                                          ? swipeCard
                                                                              .images
                                                                              .images
                                                                          : [],
                                                                      visiblePhotoIndex:
                                                                          0,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        48.0),
                                                                    child: position.toString() ==
                                                                            "SwiperPosition.Left"
                                                                        ? Align(
                                                                            alignment:
                                                                                Alignment.centerRight,
                                                                            child:
                                                                                Transform.rotate(
                                                                              angle: pi / 1,
                                                                              child: Container(
                                                                                height: 90,
                                                                                width: 110,
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: mYellow)),
                                                                                child: Center(
                                                                                  child: Icon(
                                                                                    Icons.cancel_outlined,
                                                                                    color: mRed,
                                                                                    size: 80,
                                                                                  ),
                                                                                  // Text("NOPE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 32)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : position.toString() ==
                                                                                "SwiperPosition.Right"
                                                                            ? Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Transform.rotate(
                                                                                  angle: pi / 17,
                                                                                  child: Container(
                                                                                    height: 90,
                                                                                    width: 110,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: mYellow)),
                                                                                    child: Center(
                                                                                      child: Icon(
                                                                                        Icons.check_circle_outline,
                                                                                        color: Colors.green,
                                                                                        size: 80,
                                                                                      ),
                                                                                      // Text("LIKE", style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 32)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                  ),
                                                                  if (swipeCard
                                                                          .createAccountData
                                                                          .isVaccinated !=
                                                                      null)
                                                                    if (swipeCard
                                                                        .createAccountData
                                                                        .isVaccinated)
                                                                      Positioned(
                                                                        top: 15,
                                                                        right:
                                                                            10,
                                                                        child:
                                                                            Tooltip(
                                                                          key: swipeProvider
                                                                              .toolTipKey,
                                                                          message:
                                                                              "I Am Vaccinated".tr(),
                                                                          textStyle:
                                                                              TextStyle(color: Colors.white),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                mRed,
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              // toolTipKey.currentState.ensureTooltipVisible();
                                                                              final dynamic tooltip = swipeProvider.toolTipKey.currentState;
                                                                              tooltip.ensureTooltipVisible();

                                                                              Timer(Duration(seconds: 1), () {
                                                                                swipeProvider.toolTipKey.currentState.deactivate();
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  //swipe ends
                                                  //Normal Videos
                                                  swipeCard.userVideosModel !=
                                                              null &&
                                                          swipeCard
                                                                  .userVideosModel
                                                                  .videos
                                                                  .length >
                                                              0
                                                      ? Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Container(
                                                            //alignment:Alignment.centerLeft,
                                                            height: 130,
                                                            padding: EdgeInsets.only(
                                                                left: swipeCard
                                                                            .userVideosModel
                                                                            .videos
                                                                            .length >=
                                                                        3
                                                                    ? 10
                                                                    : 10),
                                                            child: GridView
                                                                .builder(
                                                                    physics:
                                                                        AlwaysScrollableScrollPhysics(),
                                                                    // change
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    primary:
                                                                        true,
                                                                    // how to test now.. there are no videos wait let me check the id i upload it from other deviceokok
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemCount: swipeCard
                                                                        .userVideosModel
                                                                        .videos
                                                                        .length,
                                                                    gridDelegate:
                                                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                                                      maxCrossAxisExtent:
                                                                          200,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                      childAspectRatio:
                                                                          2 / 2,
                                                                      crossAxisSpacing:
                                                                          20,
                                                                    ),
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index2) {
                                                                      // var video = swipeCard
                                                                      //     .userVideosModel
                                                                      //     .videos[index2];
                                                                      return InkWell(
                                                                        onTap:
                                                                            () {
                                                                          //video["url"];
                                                                          Navigator.of(context)
                                                                              .push(MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                VideoDetailScreen(
                                                                              allVideos: swipeCard.userVideosModel.videos,
                                                                              videoIndex: index2,
                                                                              userUID: swipeCard.createAccountData.uid,
                                                                            ),
                                                                          ));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.all(5),
                                                                          height:
                                                                              150,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            boxShadow: [
                                                                              BoxShadow(color: Colors.blueGrey, offset: Offset(2, 2), spreadRadius: 1.0, blurRadius: 1)
                                                                            ],
                                                                            //border: Border.all(color: lRed, width: 1.0),
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20)),
                                                                          ),
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(15)),
                                                                            child:
                                                                                Container(
                                                                              height: swipeProvider.screenWidth >= miniScreenWidth ? 130.0 : 100,
                                                                              child: Center(
                                                                                child: Icon(
                                                                                  Icons.play_arrow_rounded,
                                                                                  size: 50,
                                                                                  color: Colors.black.withOpacity(0.7),
                                                                                ),
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                  fit: BoxFit.fill,

                                                                                  // image: NetworkImage(apiVideosURL + video.thumbnailUrl,), fit: BoxFit.fill,
                                                                                  // image: CachedNetworkImageProvider(apiVideosURL + video.thumbnailUrl),
                                                                                  image: CachedNetworkImageProvider(swipeCard.userVideosModel.videos[index2].thumbnailUrl),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),

                                                  Visibility(
                                                      visible: swipeCard
                                                                      .createAccountData
                                                                      .editInfo[
                                                                  'bio'] !=
                                                              null &&
                                                          swipeCard.createAccountData
                                                                      .editInfo[
                                                                  'bio'] !=
                                                              "",
                                                      child: GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () => detailDialog(
                                                            context,
                                                            swipeCard
                                                                .createAccountData
                                                                .editInfo['bio']),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Divider(),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0,
                                                                      top:
                                                                          15.0),
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.0,
                                                                        vertical:
                                                                            8.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        offset: Offset(
                                                                            2,
                                                                            2),
                                                                        spreadRadius:
                                                                            2,
                                                                        blurRadius:
                                                                            3),
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20)),
                                                                  color: themeProvider
                                                                          .isDarkMode
                                                                      ? dRed
                                                                      : white,
                                                                ),
                                                                child: Wrap(
                                                                  children: [
                                                                    CommonSwipeWidget()
                                                                        .swipeHeaders(
                                                                            "Bio :-".tr()),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              15),
                                                                      child: Align(
                                                                          alignment: Alignment.centerLeft,
                                                                          child: Text(
                                                                            swipeCard.createAccountData.editInfo['bio'] != null
                                                                                ? "${swipeCard.createAccountData.editInfo['bio']}"
                                                                                : '',
                                                                            style:
                                                                                TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          )),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),

                                                  Visibility(
                                                      visible: swipeCard
                                                                      .createAccountData
                                                                      .editInfo[
                                                                  'future'] !=
                                                              null &&
                                                          swipeCard.createAccountData
                                                                      .editInfo[
                                                                  'future'] !=
                                                              "",
                                                      child: GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () => detailDialog(
                                                            context,
                                                            swipeCard
                                                                    .createAccountData
                                                                    .editInfo[
                                                                'future']),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 4.0,
                                                                  right: 4.0,
                                                                  top: 15.0),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.0,
                                                                    vertical:
                                                                        8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    offset:
                                                                        Offset(
                                                                            2,
                                                                            2),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        3),
                                                              ],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                              color: themeProvider
                                                                      .isDarkMode
                                                                  ? dRed
                                                                  : white,
                                                            ),
                                                            child: Wrap(
                                                              children: [
                                                                CommonSwipeWidget()
                                                                    .swipeHeaders(
                                                                        "Future plans :-"
                                                                            .tr()),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              15),
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        swipeCard.createAccountData.editInfo['future'] !=
                                                                                null
                                                                            ? "${swipeCard.createAccountData.editInfo['future']}"
                                                                            : '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )),

                                                  Visibility(
                                                      visible: swipeCard
                                                                      .createAccountData
                                                                      .editInfo[
                                                                  'hereFor'] !=
                                                              null &&
                                                          swipeCard.createAccountData
                                                                      .editInfo[
                                                                  'hereFor'] !=
                                                              "",
                                                      child: GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () {
                                                          detailDialog(
                                                              context,
                                                              swipeCard
                                                                      .createAccountData
                                                                      .editInfo[
                                                                  'hereFor']);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 4.0,
                                                                  right: 4.0,
                                                                  top: 15.0),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.0,
                                                                    vertical:
                                                                        8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    offset:
                                                                        Offset(
                                                                            2,
                                                                            2),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        3),
                                                              ],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                              color: themeProvider
                                                                      .isDarkMode
                                                                  ? dRed
                                                                  : white,
                                                            ),
                                                            child: Wrap(
                                                              children: [
                                                                CommonSwipeWidget()
                                                                    .swipeHeaders(
                                                                        "Here for :-"
                                                                            .tr()),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              15),
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        swipeCard.createAccountData.editInfo['hereFor'] !=
                                                                                null
                                                                            ? "${swipeCard.createAccountData.editInfo['hereFor']}"
                                                                            : '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )),

                                                  Visibility(
                                                      visible: swipeCard
                                                                      .createAccountData
                                                                      .editInfo[
                                                                  'talkToMe'] !=
                                                              null &&
                                                          swipeCard.createAccountData
                                                                      .editInfo[
                                                                  'talkToMe'] !=
                                                              "",
                                                      child: GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () => detailDialog(
                                                            context,
                                                            swipeCard
                                                                    .createAccountData
                                                                    .editInfo[
                                                                'talkToMe']),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 4.0,
                                                                  right: 4.0,
                                                                  top: 15.0),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.0,
                                                                    vertical:
                                                                        8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    offset:
                                                                        Offset(
                                                                            2,
                                                                            2),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        3),
                                                              ],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                              color: themeProvider
                                                                      .isDarkMode
                                                                  ? dRed
                                                                  : white,
                                                            ),
                                                            child: Wrap(
                                                              children: [
                                                                CommonSwipeWidget()
                                                                    .swipeHeaders(
                                                                        "Talk to me only if :-"
                                                                            .tr()),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              15),
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        swipeCard.createAccountData.editInfo['talkToMe'] !=
                                                                                null
                                                                            ? "${swipeCard.createAccountData.editInfo['talkToMe']}"
                                                                            : '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                  Visibility(
                                                      visible: swipeCard
                                                                  .createAccountData
                                                                  .hobbies !=
                                                              null &&
                                                          swipeCard
                                                              .createAccountData
                                                              .hobbies
                                                              .isNotEmpty,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 4.0,
                                                                right: 4.0,
                                                                top: 15.0),
                                                        child: Container(
                                                          child: Column(
                                                            children: [
                                                              Divider(),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            12.0,
                                                                        vertical:
                                                                            4.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        offset: Offset(
                                                                            2,
                                                                            2),
                                                                        spreadRadius:
                                                                            2,
                                                                        blurRadius:
                                                                            3),
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20)),
                                                                  color: themeProvider
                                                                          .isDarkMode
                                                                      ? dRed
                                                                      : white,
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    CommonSwipeWidget()
                                                                        .swipeHeaders(
                                                                            "My Interests :- ".tr()),
                                                                    Wrap(
                                                                      alignment:
                                                                          WrapAlignment
                                                                              .start,
                                                                      children: CommonSwipeWidget().getWrapInterestList(swipeCard
                                                                          .createAccountData
                                                                          .hobbies),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )),
                                                  Visibility(
                                                    visible: swipeCard.createAccountData.socioInfo != null &&
                                                            swipeCard
                                                                .createAccountData
                                                                .socioInfo
                                                                .isNotEmpty &&
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['fb'] !=
                                                                null &&
                                                            swipeCard.createAccountData.socioInfo['fb']
                                                                .toString()
                                                                .isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['insta'] != null &&
                                                            swipeCard.createAccountData.socioInfo['insta']
                                                                .toString()
                                                                .isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['snap'] != null &&
                                                            swipeCard.createAccountData.socioInfo['snap']
                                                                .toString()
                                                                .isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['twitter'] != null &&
                                                            swipeCard.createAccountData.socioInfo['twitter']
                                                                .toString()
                                                                .isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['tiktok'] != null &&
                                                            swipeCard
                                                                .createAccountData
                                                                .socioInfo['tiktok']
                                                                .toString()
                                                                .isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['website'] != null && swipeCard.createAccountData.socioInfo['website'].toString().isNotEmpty ||
                                                        swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['youtube'] != null && swipeCard.createAccountData.socioInfo['youtube'].toString().isNotEmpty,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4.0,
                                                              right: 4.0,
                                                              top: 15.0),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    12.0,
                                                                vertical: 4.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .blueGrey,
                                                                offset: Offset(
                                                                    2, 2),
                                                                spreadRadius: 2,
                                                                blurRadius: 3),
                                                          ],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? dRed
                                                              : white,
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonSwipeWidget()
                                                                .swipeHeaders(
                                                                    "Social links :-"
                                                                        .tr()),
                                                            Wrap(
                                                              children: [
                                                                Visibility(
                                                                  visible: swipeCard.createAccountData.socioInfo != null && swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['snap'] !=
                                                                      null,
                                                                  child: CommonSwipeWidget()
                                                                      .getSocialLinkWidget(
                                                                          "assets/images/snapIcon.jpg",
                                                                          () {
                                                                    CommonSwipeWidget().launchURL(swipeCard
                                                                        .createAccountData
                                                                        .socioInfo['snap']);
                                                                  }),
                                                                ),
                                                                Visibility(
                                                                  visible: swipeCard.createAccountData.socioInfo != null && swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['fb'] !=
                                                                      null,
                                                                  child: CommonSwipeWidget()
                                                                      .getSocialLinkWidget(
                                                                          "assets/images/fbIcon.jpg",
                                                                          () {
                                                                    CommonSwipeWidget().launchURL(swipeCard
                                                                        .createAccountData
                                                                        .socioInfo['fb']);
                                                                  }),
                                                                ),
                                                                Visibility(
                                                                    visible:
                                                                    swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['tiktok'] !=
                                                                            null,
                                                                    child: CommonSwipeWidget()
                                                                        .getSocialLinkWidget(
                                                                            "assets/images/tiktokIcon.jpg",
                                                                            () {
                                                                      CommonSwipeWidget().launchURL(swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['tiktok']);
                                                                    })),
                                                                Visibility(
                                                                    visible:
                                                                    swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['insta'] !=
                                                                            null,
                                                                    child: CommonSwipeWidget()
                                                                        .getSocialLinkWidget(
                                                                            "assets/images/instaIcon.jpg",
                                                                            () {
                                                                      CommonSwipeWidget().launchURL(swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['insta']);
                                                                    })),
                                                                Visibility(
                                                                    visible:
                                                                    swipeCard.createAccountData.socioInfo != null &&  swipeCard.createAccountData.socioInfo['youtube'] !=
                                                                            null,
                                                                    child: CommonSwipeWidget()
                                                                        .getSocialLinkWidget(
                                                                            "assets/images/youtubeIcon.jpg",
                                                                            () {
                                                                      CommonSwipeWidget().launchURL(swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['youtube']);
                                                                    })),
                                                                Visibility(
                                                                    visible:
                                                                    swipeCard.createAccountData.socioInfo != null && swipeCard.createAccountData.socioInfo['twitter'] !=
                                                                            null,
                                                                    child: CommonSwipeWidget()
                                                                        .getSocialLinkWidget(
                                                                            "assets/images/twitterIcon.jpg",
                                                                            () {
                                                                      CommonSwipeWidget().launchURL(swipeCard
                                                                          .createAccountData
                                                                          .socioInfo['twitter']);
                                                                    })),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    // height:100
                                                    margin: EdgeInsets.only(
                                                        top: 50, bottom: 50.0),
                                                    alignment: Alignment.center,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        moreBtn(
                                                          context: context,
                                                          currentUser:
                                                              swipeProvider
                                                                  .currentUserData,
                                                          anotherUser: swipeCard
                                                              .createAccountData,
                                                        );
                                                      },
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Tooltip(
                                                              message:
                                                                  "More".tr(),
                                                              preferBelow:
                                                                  false,
                                                              child: Icon(
                                                                (Icons
                                                                    .info_outline_rounded),
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 12.0,
                                                            ),
                                                            Text(
                                                              "${swipeCard.createAccountData.name.toUpperCase()}",
                                                              style: TextStyle(
                                                                fontSize: 22,
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                      }).toList(growable: true),
                                      threshold: 30,
                                      maxAngle: 100,
                                      visibleCount: 1,
                                      historyCount: 1,
                                      stackFrom: StackFrom.Right,
                                      translationInterval: 5,
                                      scaleInterval: 0.08,
                                      onSwipe: (int index,
                                          SwiperPosition position) async {
                                        //_adsCheck(countswipe);
                                        //TODO: uncomment for swipe functionality
                                        print(position);
                                        print(swipeProvider
                                            .swipeCardModelList[index]
                                            .createAccountData
                                            .name);

                                        if (position == SwiperPosition.Left) {
                                          await swipeProvider.firebaseController
                                              .userColReference
                                              .doc(swipeProvider
                                                  .currentUserData.uid)
                                              .collection("CheckedUser")
                                              .doc(swipeProvider
                                                  .swipeCardModelList[index]
                                                  .createAccountData
                                                  .uid)
                                              .set(
                                            {
                                              'DislikedUser': swipeProvider
                                                  .swipeCardModelList[index]
                                                  .createAccountData
                                                  .uid,
                                              'timestamp': DateTime.now(),
                                            },
                                          );

                                          if (index <
                                              swipeProvider
                                                  .swipeCardModelList.length) {
                                            swipeProvider.swipeCardRemoved
                                                .clear();
                                            swipeProvider.swipeCardRemoved.add(
                                                swipeProvider
                                                    .swipeCardModelList[index]);
                                            // swipeProvider.users.removeAt(index);   //below line will work for this
                                            swipeProvider.removeSwipeCard(
                                                swipeCardModel: swipeProvider
                                                    .swipeCardModelList[index]);
                                          }

                                          //humare likedBy mese delete karna hai
                                          if (swipeProvider.likedByList.any(
                                              (element) =>
                                                  element.id ==
                                                  swipeProvider
                                                      .swipeCardModelList[index]
                                                      .createAccountData
                                                      .uid)) {
                                            await swipeProvider
                                                .firebaseController
                                                .notificationColReference
                                                .doc(swipeProvider
                                                    .currentUserData.uid)
                                                .collection("LikedBy")
                                                .doc(swipeProvider
                                                    .swipeCardModelList[index]
                                                    .createAccountData
                                                    .uid)
                                                .delete();
                                          }
                                        }
                                        //
                                        else if (position ==
                                            SwiperPosition.Right) {
                                          if (swipeProvider.likedByList.any(
                                              (element) =>
                                                  element.id ==
                                                  swipeProvider
                                                      .swipeCardModelList[index]
                                                      .createAccountData
                                                      .uid)) {
                                            swipeProvider.showMatchDialog(
                                                context, index);

                                            //TONE
                                            playAudioTone();
                                            //Match Count Create
                                            swipeProvider
                                                .insertNotificationCount(
                                                    swipeProvider
                                                        .swipeCardModelList[
                                                            index]
                                                        .createAccountData);

                                            //humare likedBy mese delete karna hai
                                            await swipeProvider
                                                .firebaseController
                                                .userColReference
                                                .doc(swipeProvider
                                                    .currentUserData.uid)
                                                .collection("LikedBy")
                                                .doc(swipeProvider
                                                    .swipeCardModelList[index]
                                                    .createAccountData
                                                    .uid)
                                                .delete();
                                          } else {
                                            //likeduser not match
                                            await swipeProvider
                                                .firebaseController
                                                .userColReference
                                                .doc(swipeProvider
                                                    .swipeCardModelList[index]
                                                    .createAccountData
                                                    .uid)
                                                .collection("LikedBy")
                                                .doc(swipeProvider
                                                    .currentUserData.uid)
                                                .set(
                                              {
                                                'LikedBy': swipeProvider
                                                    .currentUserData.uid,
                                                'timestamp':
                                                    FieldValue.serverTimestamp()
                                              },
                                            );
                                          }

                                          await swipeProvider.firebaseController
                                              .userColReference
                                              .doc(swipeProvider
                                                  .currentUserData.uid)
                                              .collection("CheckedUser")
                                              .doc(swipeProvider
                                                  .swipeCardModelList[index]
                                                  .createAccountData
                                                  .uid)
                                              .set(
                                            {
                                              'LikedUser': swipeProvider
                                                  .swipeCardModelList[index]
                                                  .createAccountData
                                                  .uid,
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                            },
                                          );

                                          if (index <
                                              swipeProvider
                                                  .swipeCardModelList.length) {
                                            swipeProvider.swipeCardRemoved
                                                .clear();
                                            setState(() {
                                              swipeProvider.swipeCardRemoved
                                                  .add(swipeProvider
                                                          .swipeCardModelList[
                                                      index]);
                                              // swipeProvider.users.removeAt(index); //below line will work for this
                                              swipeProvider.removeSwipeCard(
                                                  swipeCardModel: swipeProvider
                                                          .swipeCardModelList[
                                                      index]);
                                            });
                                          }
                                        } else {
                                          debugPrint(
                                              "onSwipe $index $position");
                                        }
                                        await swipeProvider
                                            .getInitialSwipeCard(); // TODO: important
                                      },
                                      onRewind:
                                          (int index, SwiperPosition position) {
                                        swipeProvider.swipeKey.currentContext
                                            .dependOnInheritedWidgetOfExactType();
                                        // swipeProvider.users.insert(index, swipeProvider.userRemoved[0]); //TODO: important
                                        setState(() {
                                          swipeProvider.swipeCardRemoved
                                              .clear();
                                        });
                                        debugPrint("onRewind $index $position");
                                      },
                                    )),
                    ),
                  ],
                ),
              ),
              swipeProvider.exceedSwipes
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        color: Colors.blueGrey.withOpacity(0.5),
                        child: Dialog(
                          insetAnimationCurve: Curves.bounceInOut,
                          insetAnimationDuration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor:
                              themeProvider.isDarkMode ? dRed : white,
                          child: Container(
                              height: MediaQuery.of(context).size.height * .55,
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: lRed,
                                            radius: 30,
                                          ),
                                          Icon(
                                            Icons.error_outline,
                                            size: 60,
                                            color: themeProvider.isDarkMode
                                                ? dRed
                                                : white,
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "You have already used the maximum number of available swipes for 24 hrs. ,\n it's time to plan or explore a DATE \n or WAVE to the people nearby or \n create or see new POST"
                                            .tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Handlee',
                                            fontWeight: FontWeight.w700,
                                            color: lRed,
                                            decoration: TextDecoration.none,
                                            fontSize:
                                                swipeProvider.screenWidth >=
                                                        miniScreenWidth
                                                    ? 17
                                                    : 15),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      ))
                  : SizedBox.shrink(),
            ],
          ),
        ),
      );
    });
  }

  void moreBtn(
      {@required BuildContext context,
      @required CreateAccountData currentUser,
      @required CreateAccountData anotherUser}) async {
    var value = await showDialog(
        context: context,
        builder: (context) => MoreOptionDialog(
              currentUser: currentUser,
              anotherUser: anotherUser,
            ));
    print(value);
    if (value == "block") {
      try {
        // swipeKey.currentState.swipeLeft();
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void detailDialog(context, String detail) async {
    //final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Padding(
            padding: swipeProvider.screenWidth >= miniScreenWidth
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
                        fontSize: swipeProvider.screenWidth >= miniScreenWidth
                            ? 22
                            : 19)),
              ],
            ),
          );
        });
  }

  Future<AudioPlayer> playAudioTone() async {
    AudioCache cache = new AudioCache();
    return await cache.play("tone/tone.mp3");
  }

  bool get wantKeepAlive => true;
}
