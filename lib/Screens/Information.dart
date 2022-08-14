import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/ApiController/ImagesApiController.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/BottomNavigation/Chat/RealtimeChat/RTChatPage.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/UploadMedia/UploadImages/uplopad_videosFirebase.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaDetailScreen.dart';
import 'package:litpie/media/videoDetail/videoDetailScreen.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/moreOptionDialog.dart';
import 'package:litpie/widgets/photoCard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class Info extends StatefulWidget {
  final CreateAccountData currentUser;
  final CreateAccountData user;

  Info(this.user, this.currentUser);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");

  //double _maxScreenWidth;
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  BlockedUserModel blockedModel;
  final BlockUserController blockUserController = BlockUserController();

  UserImagesModel _userImagesModel;
  UserVideosModel _userVideosModel;
  UserStoriesModel _userStoriesModel;
  bool adminBlock = false;
  SharedPreferences prefs;

  Future<UserImagesModel> loadImages() async {
    // APi Call
    _userImagesModel =
        await ImagesApiController().getImages(uid: widget.user.uid);
    if (mounted) setState(() {});
    return _userImagesModel;
  }

  Future<UserVideosModel> loadVideos() async {
    //APi Call
    var data = await VideoController().getAllVideos(widget.user.uid);
    List<Videos> videosList = [];
    if (data.length > 0) {
      data.forEach((element) {
        Videos video = Videos.fromJson(element);
        videosList.add(video);
      });
    }
    if (videosList.length > 0) {
      _userVideosModel.videos = videosList;
    }
    return _userVideosModel;
  }

  Future<UserStoriesModel> loadStories() async {
    try {
      _userStoriesModel =
          await StoriesApiController().getStories(uid: widget.user.uid);
      if (mounted) setState(() {});
      return _userStoriesModel;
    } catch (e) {}
    //APi Call
  }

  FirebaseController _firebaseController = FirebaseController();
  Future<DocumentSnapshot> likeCountDoc;
  int userRecord;
  bool isFetched = false;

  Future<DocumentSnapshot> _getLikeCount() {
    likeCountDoc = _firebaseController.userColReference
        .doc(widget.user.uid)
        .collection('R')
        .doc('count')
        .get()
        .then((value) {
      return value;
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    init();
    var distance = Constants().calculateDistance(
        currentUser: widget.currentUser, anotherUser: widget.user);
    widget.user.distanceBW = distance.round();
    _getLikeCount();
    loadImages().then((value) {
      if (value != null) {
        widget.user.imageUrl = [];
        value.images.forEach((element) {
          widget.user.imageUrl.add(apiImagesURL + element.imageUrl);
        });
        if (mounted) setState(() {});
      }
    });
    if (adminBlock = widget.user.isBlocked == true) {
      adminBlock = true;
    }
    if (adminBlock = widget.user.isBlocked == false) {
      adminBlock = false;
    }
    loadVideos();
    loadStories();
  }

  Future<void> init() async {
    blockedModel = await blockUserController.blockedExistOrNot(
        currentUserId: widget.currentUser.uid, anotherUserId: widget.user.uid);

    if (mounted)
      setState(() {
        isFetched = true;
      });
    return;
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: (blockedModel != null && isFetched) ||
                (widget.user.isBlocked ||
                    widget.user.isHidden ||
                    widget.user.isDeleted)
            ? null
            : AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 50),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0), //bio != null? "$bio":'',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 180.0,
                      ),
                      FloatingActionButton(
                        backgroundColor: mRed,
                        elevation: 0,
                        foregroundColor: white,
                        heroTag: "chat",
                        child: Icon(
                          (CupertinoIcons.chat_bubble_text),
                          size: 35,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => RTChatPage(
                                      sender: widget.currentUser,
                                      second: widget.user,
                                      chatId: Constants().generateChatId(
                                          widget.user.uid,
                                          widget.currentUser.uid),
                                    ))),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          foregroundColor: white,
                          heroTag: "Rbtn",
                          shape: StadiumBorder(
                              side: BorderSide(color: mRed, width: 2)),
                          child:
                              // Icon(
                              //   Icons.favorite,
                              //   color: Colors.green,
                              //   size: 40,
                              // ),

                              // themeProvider.isDarkMode
                              //     ? Image.asset("assets/images/RoseDark.png")
                              //     : Image.asset("assets/images/RoseLight.png"),
                              Padding(
                            padding: const EdgeInsets.only(
                                left: 6.0, top: 6, right: 6, bottom: 2),
                            child: Image.asset("assets/images/litpielogo.png"),
                          ),
                          onPressed: () {
                            checkRoseCount(context);
                            HapticFeedback.heavyImpact();
                          }),

                      FutureBuilder<DocumentSnapshot>(
                          future: likeCountDoc,
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data.exists) {
                                if (userRecord == null)
                                  userRecord = snapshot.data['roseRec'];
                                return Text(
                                  userRecord >= 1000
                                      ? NumberFormat.compact()
                                          .format(userRecord)
                                      : "$userRecord",
                                  //style: TextStyle(color: white),
                                );
                              } else {
                                return Text(
                                  '...',
                                  //style: TextStyle(color: white),
                                );
                              }
                            } else {
                              return Text(
                                "...",
                                //style: TextStyle(color: white),
                              );
                            }
                          }),

                      // StreamBuilder<DocumentSnapshot>(
                      //
                      //   //stream: _reference.snapshots(),
                      //     stream: _reference.doc(widget.user.uid).collection('R').doc(
                      //         'count').snapshots(),
                      //     builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      //       if (snapshot.hasData) {
                      //         if (snapshot.data.exists) {
                      //           int userRecord;
                      //           userRecord = snapshot.data['roseRec'];
                      //           return Text("$userRecord");
                      //         } else {
                      //           return Text('...');
                      //         }
                      //       } else {
                      //         return Text("...");
                      //       }
                      //     }),
                    ],
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode ? dRed : white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: themeProvider.isDarkMode ? white : black,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.user.name.toUpperCase(),
              style: TextStyle(
                color: themeProvider.isDarkMode ? white : black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            elevation: 0,
            actions: <Widget>[
              Tooltip(
                message: "More".tr(),
                preferBelow: false,
                child: IconButton(
                  icon: Icon(
                    (CupertinoIcons.ellipsis_vertical),
                  ),
                  onPressed: () {
                    moreBtn(
                        context: context,
                        currentUser: widget.currentUser,
                        anotherUser: widget.user);
                  },
                ),
              ),
            ]),
        body: Container(
          //height: MediaQuery.of(context).size.height ,
          width: MediaQuery.of(context).size.width,
          color: themeProvider.isDarkMode ? dRed : white,
          child: blockedModel != null && isFetched
              ? blockedModel.blockedBy == widget.currentUser.uid
                  ? Center(
                      child: Text(
                        "UNBLOCK  TO  CONTINUE".tr(),
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.w700,
                            fontSize: 22.0,
                            color: lRed),
                      ),
                    )
                  : Center(
                      child: Text(
                        "USER  NOT AVAILABLE".tr(),
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.w700,
                            fontSize: 22.0,
                            color: lRed),
                      ),
                    )
              : widget.user.isBlocked ||
                      widget.user.isHidden ||
                      widget.user.isDeleted
                  ? Column(
                      children: [
                        Center(
                          child: Text(
                            "USER  NOT AVAILABLE".tr(),
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.w700,
                                fontSize: 22.0,
                                color: lRed),
                          ),
                        ),
                        widget.currentUser.ADMIN == true
                            ? Tooltip(
                                message: widget.user.isBlocked == true
                                    ? "Blocked"
                                    : "Not Blocked",
                                preferBelow: false,
                                child: Container(
                                  child: ListTile(
                                    title: Card(
                                      color: themeProvider.isDarkMode
                                          ? black
                                          : white,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: SwitchListTile(
                                            title: widget.user.isBlocked == true
                                                ? Text(
                                                    "Blocked",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  )
                                                : Text("Not Blocked",
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontSize: _screenWidth >=
                                                              miniScreenWidth
                                                          ? 18
                                                          : 15,
                                                    )),
                                            secondary:
                                                widget.user.isBlocked == true
                                                    ? Icon(Icons.block_outlined,
                                                        color: mRed)
                                                    : Icon(Icons.person_outline,
                                                        color: Colors.green),
                                            activeColor: Colors.blueGrey,
                                            inactiveThumbColor: mRed,
                                            inactiveTrackColor: Colors.grey,
                                            value: adminBlock,
                                            onChanged: (bool value) {
                                              // prefs.setBool('isBlocked', true);
                                              setState(() {
                                                adminBlock = value;
                                              });
                                              bool themeMode = true;
                                              if (value) {
                                                themeMode = true;
                                                _firebaseController
                                                    .userColReference
                                                    .doc(widget.user.uid)
                                                    .update({
                                                  "isBlocked": false,
                                                }).then((_) {
                                                  print('Blocked: $value');
                                                });
                                              }
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    )
                  : ListView(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blueGrey,
                                        offset: Offset(2, 2),
                                        spreadRadius: 1,
                                        blurRadius: 2)
                                  ],
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(
                                    80,
                                  ),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      80,
                                    ),
                                    child: widget.user.profilepic != null &&
                                            widget.user.profilepic.isNotEmpty
                                        ? CachedNetworkImage(
                                            height:
                                                _screenWidth >= miniScreenWidth
                                                    ? 150
                                                    : 125,
                                            width:
                                                _screenWidth >= miniScreenWidth
                                                    ? 150
                                                    : 125,
                                            fit: BoxFit.fill,
                                            imageUrl: widget.user.profilepic,
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
                                                )
                                              ],
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              80,
                                            ),
                                            child: Container(
                                              height: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 150
                                                  : 125,
                                              width: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 150
                                                  : 125,
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                        placeholderImage,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                              ),
                              if (widget.user.isVaccinated != null)
                                if (widget.user.isVaccinated)
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Tooltip(
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
                                          final dynamic tooltip =
                                              toolTipKey.currentState;
                                          tooltip.ensureTooltipVisible();

                                          Timer(Duration(seconds: 1), () {
                                            toolTipKey.currentState
                                                .deactivate();
                                          });
                                        },
                                        child: Container(
                                          width: _screenWidth >= miniScreenWidth
                                              ? 35
                                              : 30,
                                          height:
                                              _screenWidth >= miniScreenWidth
                                                  ? 35
                                                  : 30,
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
                        SizedBox(
                          height: 10,
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blueGrey,
                                        offset: Offset(2, 2),
                                        spreadRadius: 2,
                                        blurRadius: 3),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color:
                                      themeProvider.isDarkMode ? dRed : white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                    top: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 7.0),
                                              child: Text(
                                                " ${widget.user.age},",
                                                // textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2.0,
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${widget.user.name}"
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.accessibility_rounded,
                                              size: 14,
                                            ),
                                            SizedBox(
                                              width: 2.0,
                                            ),
                                            Text(
                                              widget.user.distanceBW <= 5
                                                  ? " Less than 5 Km.".tr()
                                                  : widget.user.distanceBW >=
                                                          1000
                                                      ? NumberFormat.compact()
                                                              .format(widget
                                                                  .user
                                                                  .distanceBW) +
                                                          " Km. approx. ".tr()
                                                      : "${widget.user.distanceBW}" +
                                                          " Km. approx. ".tr(),
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${widget.user.address}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        //Stories Section Start
                        _userStoriesModel != null &&
                                _userStoriesModel.stories.length > 0
                            ? Container(
                                height: 100,
                                padding: EdgeInsets.only(
                                    left: _userStoriesModel.stories.length >= 3
                                        ? 10
                                        : 0),
                                child: GridView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: _userStoriesModel.stories.length,
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2 / 2,
                                      crossAxisSpacing: 20,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var story =
                                          _userStoriesModel.stories[index];
                                      return InkWell(
                                        onTap: () async {
                                          await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      StoryMediaDetailScreen(
                                                          allStories:
                                                              _userStoriesModel,
                                                          storyIndex: index,
                                                          userUID:
                                                              widget.user.uid)))
                                              .whenComplete(() {
                                            setState(() {
                                              print("Refresh!!!");
                                            });
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          height: 130,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      mYellow.withOpacity(0.8),
                                                  offset: Offset(2, 2),
                                                  spreadRadius: 1,
                                                  blurRadius: 1)
                                            ],
                                            color: mRed,
                                            border: Border.all(
                                                color: mRed.withOpacity(0.7),
                                                width: 2.0),
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                            child: Container(
                                              height: 130,
                                              child: Center(
                                                child: story.type == "video"
                                                    ? Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                        size: 50,
                                                        color: Colors.black
                                                            .withOpacity(0.7),
                                                      )
                                                    : Container(),
                                              ),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    story.type == "video"
                                                        ? apiStoriesURL +
                                                            story.thumbnailUrl
                                                        : apiStoriesURL +
                                                            story.url,
                                                  ),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : SizedBox.shrink(),
                        //Story Section End

                        if (_userImagesModel != null &&
                            _userImagesModel.images.length > 0)
                          Column(
                            children: [
                              SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Material(
                                  color:
                                      themeProvider.isDarkMode ? dRed : white,
                                  elevation: 2,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .50,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.blueGrey,
                                                    offset: Offset(2, 2),
                                                    spreadRadius: 1,
                                                    blurRadius: 2),
                                              ],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: themeProvider.isDarkMode
                                                  ? dRed
                                                  : white,
                                            ),
                                            child: Stack(
                                              children: <Widget>[
                                                Center(
                                                    child: Text(
                                                  "Hold on, It's loading....."
                                                      .tr(),
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(color: white),
                                                )),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                  child: PhotoBrowser(
                                                    user: widget.user,
                                                    images:
                                                        _userImagesModel != null
                                                            ? _userImagesModel
                                                                .images
                                                            : [],
                                                    visiblePhotoIndex: 0,
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding:
                                                //   const EdgeInsets.only(
                                                //       bottom: 10),
                                                //   child: Align(
                                                //     alignment:
                                                //     Alignment.topLeft,
                                                //     child: Column(
                                                //       children: [
                                                //         Row(
                                                //           children: [
                                                //             SizedBox(width: 10, height: 20,),
                                                //             Text("${widget.user.name},"
                                                //                 .toUpperCase(),
                                                //               style: TextStyle(color: white,
                                                //                   fontSize: 20,
                                                //                   fontWeight: FontWeight
                                                //                       .bold),
                                                //             ),
                                                //             Padding(
                                                //               padding: const EdgeInsets.only(
                                                //                   top: 10.0),
                                                //               child: Text(
                                                //                 " ${widget.user
                                                //                     .editInfo['showMyAge'] !=
                                                //                     null ? !widget.user
                                                //                     .editInfo['showMyAge']
                                                //                     ? widget.user.age
                                                //                     : "" : widget.user.age}",
                                                //                 // textAlign: TextAlign.center,
                                                //                 style: TextStyle(color: white,
                                                //                     fontSize: 14,
                                                //                     fontWeight: FontWeight
                                                //                         .w500),
                                                //               ),
                                                //             ),
                                                //           ],
                                                //         ),
                                                //         Column(
                                                //           children: [
                                                //             Row(
                                                //               children: [
                                                //                 Icon(
                                                //                   Icons.accessibility_rounded,
                                                //                   size: 14, color: white,),
                                                //                 Text(
                                                //                   widget.user.distanceBW == 0
                                                //                       ? " Less than 1 Km.".tr()
                                                //                       : "${widget.user
                                                //                       .distanceBW}" +
                                                //                       " Km. approx. ".tr(),
                                                //                   style: TextStyle(
                                                //                     color: white,
                                                //                     fontSize: 14,),
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //             Row(
                                                //               children: [
                                                //                 Icon(
                                                //                   Icons.location_on_outlined,
                                                //                   size: 13, color: white,),
                                                //                 Expanded(
                                                //                   child: SingleChildScrollView(
                                                //                     scrollDirection: Axis
                                                //                         .horizontal,
                                                //                     child: Text(
                                                //                       "${widget.user
                                                //                           .address}",
                                                //                       style: TextStyle(
                                                //                         color: white,
                                                //                         fontSize: 13,
                                                //                       ),
                                                //                     ),
                                                //                   ),
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ],
                                                //         )
                                                //
                                                //       ],
                                                //     ),
                                                //
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        //Normal Video Section Start

                        if (_userVideosModel != null &&
                            _userVideosModel.videos.length > 0)
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 130,
                                padding: EdgeInsets.only(
                                    left: _userVideosModel.videos.length >= 3
                                        ? 10
                                        : 10),
                                child: GridView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: _userVideosModel.videos.length,
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2 / 2,
                                      crossAxisSpacing: 20,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return _buildVideoThumbnail(
                                          context: context,
                                          videosModel: _userVideosModel,
                                          currentIndex: index);
                                    }),
                              ),
                            ],
                          ),
                        //Normal Video Section End

                        GestureDetector(
                          onTap: () => detailDialog(
                              context, widget.user.editInfo['bio']),
                          child: Visibility(
                              visible: widget.user.editInfo['bio'] != null &&
                                  widget.user.editInfo['bio'] != "",
                              child: Column(
                                children: [
                                  // Divider(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      child: Wrap(
                                        children: [
                                          CommonSwipeWidget()
                                              .swipeHeaders("Bio :-".tr()),
                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.user.editInfo['bio'] !=
                                                          null
                                                      ? "${widget.user.editInfo['bio']}"
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.start,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        GestureDetector(
                          onTap: () => detailDialog(
                              context, widget.user.editInfo['future']),
                          child: Visibility(
                              visible: widget.user.editInfo['future'] != null &&
                                  widget.user.editInfo['future'] != "",
                              child: Column(
                                children: [
                                  // Divider(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      child: Wrap(
                                        children: [
                                          CommonSwipeWidget().swipeHeaders(
                                              "Future plans :-".tr()),
                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.user.editInfo[
                                                              'future'] !=
                                                          null
                                                      ? "${widget.user.editInfo['future']}"
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.start,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        GestureDetector(
                          onTap: () => detailDialog(
                              context, widget.user.editInfo['hereFor']),
                          child: Visibility(
                              visible:
                                  widget.user.editInfo['hereFor'] != null &&
                                      widget.user.editInfo['hereFor'] != "",
                              child: Column(
                                children: [
                                  // Divider(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      child: Wrap(
                                        children: [
                                          CommonSwipeWidget()
                                              .swipeHeaders("Here for :-".tr()),
                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.user.editInfo[
                                                              'hereFor'] !=
                                                          null
                                                      ? "${widget.user.editInfo['hereFor']}"
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.start,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        GestureDetector(
                          onTap: () => detailDialog(
                              context, widget.user.editInfo['talkToMe']),
                          child: Visibility(
                              visible:
                                  widget.user.editInfo['talkToMe'] != null &&
                                      widget.user.editInfo['talkToMe'] != "",
                              child: Column(
                                children: [
                                  // Divider(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      child: Wrap(
                                        children: [
                                          CommonSwipeWidget().swipeHeaders(
                                              "Talk to me only if :-".tr()),
                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.user.editInfo[
                                                              'talkToMe'] !=
                                                          null
                                                      ? "${widget.user.editInfo['talkToMe']}"
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.start,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        Visibility(
                            visible: widget.user.hobbies != null &&
                                widget.user.hobbies.isNotEmpty,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 2),
                                            spreadRadius: 2,
                                            blurRadius: 3),
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: themeProvider.isDarkMode
                                          ? dRed
                                          : white,
                                    ),
                                    child: Column(
                                      children: [
                                        CommonSwipeWidget().swipeHeaders(
                                            "My Interests :- ".tr()),
                                        Wrap(
                                          alignment: WrapAlignment.start,
                                          children: CommonSwipeWidget()
                                              .getWrapInterestList(
                                                  widget.user.hobbies),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),

                        Visibility(
                          visible: widget.user.socioInfo != null &&
                                  widget.user.socioInfo.isNotEmpty &&
                                  widget.user.socioInfo['fb'] != null &&
                                  widget.user.socioInfo['fb']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['insta'] != null &&
                                  widget.user.socioInfo['insta']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['snap'] != null &&
                                  widget.user.socioInfo['snap']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['twitter'] != null &&
                                  widget.user.socioInfo['twitter']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['tiktok'] != null &&
                                  widget.user.socioInfo['tiktok']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['website'] != null &&
                                  widget.user.socioInfo['website']
                                      .toString()
                                      .isNotEmpty ||
                              widget.user.socioInfo['youtube'] != null &&
                                  widget.user.socioInfo['youtube']
                                      .toString()
                                      .isNotEmpty,
                          child: Column(
                            children: [
                              // Divider(),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 8.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.blueGrey,
                                          offset: Offset(2, 2),
                                          spreadRadius: 2,
                                          blurRadius: 3),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color:
                                        themeProvider.isDarkMode ? dRed : white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonSwipeWidget()
                                          .swipeHeaders("Social links :-".tr()),
                                      Wrap(
                                        children: [
                                          Visibility(
                                            visible:
                                                widget.user.socioInfo['snap'] !=
                                                    null,
                                            child: CommonSwipeWidget()
                                                .getSocialLinkWidget(
                                                    "assets/images/snapIcon.jpg",
                                                    () {
                                              CommonSwipeWidget().launchURL(
                                                  widget
                                                      .user.socioInfo['snap']);
                                            }),
                                          ),
                                          Visibility(
                                            visible:
                                                widget.user.socioInfo['fb'] !=
                                                    null,
                                            child: CommonSwipeWidget()
                                                .getSocialLinkWidget(
                                                    "assets/images/fbIcon.jpg",
                                                    () {
                                              CommonSwipeWidget().launchURL(
                                                  widget.user.socioInfo['fb']);
                                            }),
                                          ),
                                          Visibility(
                                              visible: widget.user
                                                      .socioInfo['tiktok'] !=
                                                  null,
                                              child: CommonSwipeWidget()
                                                  .getSocialLinkWidget(
                                                      "assets/images/tiktokIcon.jpg",
                                                      () {
                                                CommonSwipeWidget().launchURL(
                                                    widget.user
                                                        .socioInfo['tiktok']);
                                              })),
                                          Visibility(
                                              visible: widget.user
                                                      .socioInfo['insta'] !=
                                                  null,
                                              child: CommonSwipeWidget()
                                                  .getSocialLinkWidget(
                                                      "assets/images/instaIcon.jpg",
                                                      () {
                                                CommonSwipeWidget().launchURL(
                                                    widget.user
                                                        .socioInfo['insta']);
                                              })),
                                          Visibility(
                                              visible: widget.user
                                                      .socioInfo['youtube'] !=
                                                  null,
                                              child: CommonSwipeWidget()
                                                  .getSocialLinkWidget(
                                                      "assets/images/youtubeIcon.jpg",
                                                      () {
                                                CommonSwipeWidget().launchURL(
                                                    widget.user
                                                        .socioInfo['youtube']);
                                              })),
                                          Visibility(
                                              visible: widget.user
                                                      .socioInfo['twitter'] !=
                                                  null,
                                              child: CommonSwipeWidget()
                                                  .getSocialLinkWidget(
                                                      "assets/images/twitterIcon.jpg",
                                                      () {
                                                CommonSwipeWidget().launchURL(
                                                    widget.user
                                                        .socioInfo['twitter']);
                                              })),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                        widget.currentUser.ADMIN == true
                            ? Tooltip(
                                message: widget.user.isBlocked == true
                                    ? "Blocked"
                                    : "Not Blocked",
                                preferBelow: false,
                                child: Container(
                                  child: ListTile(
                                    title: Card(
                                      color: themeProvider.isDarkMode
                                          ? black
                                          : white,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: SwitchListTile(
                                            title: widget.user.isBlocked == true
                                                ? Text(
                                                    "Blocked",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  )
                                                : Text("Not Blocked",
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontSize: _screenWidth >=
                                                              miniScreenWidth
                                                          ? 18
                                                          : 15,
                                                    )),
                                            secondary:
                                                widget.user.isBlocked == true
                                                    ? Icon(Icons.block_outlined,
                                                        color: mRed)
                                                    : Icon(Icons.person_outline,
                                                        color: Colors.green),
                                            activeColor: Colors.blueGrey,
                                            inactiveThumbColor: mRed,
                                            inactiveTrackColor: dRed,
                                            value: adminBlock,
                                            onChanged: (bool value) {
                                              //prefs.setBool('isBlocked', value);
                                              setState(() {
                                                adminBlock = value;
                                              });
                                              bool themeMode = true;
                                              if (value) {
                                                themeMode = false;
                                                _firebaseController
                                                    .userColReference
                                                    .doc(widget.user.uid)
                                                    .update({
                                                  "isBlocked": true,
                                                }).then((_) {
                                                  print('Blocked: $value');
                                                });
                                              }
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
        ),
      ),
    );
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
                        fontSize: _screenWidth >= miniScreenWidth ? 22 : 18)),
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

  InkWell _buildVideoThumbnail(
      {@required BuildContext context,
      @required UserVideosModel videosModel,
      @required int currentIndex}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VideoDetailScreen(
            allVideos: videosModel.videos,
            videoIndex: currentIndex,
            userUID: widget.user.uid,
          ),
        ));
      },
      child: Container(
        margin: EdgeInsets.all(5),
        height: 120,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.blueGrey,
                offset: Offset(2, 2),
                spreadRadius: 1.0,
                blurRadius: 2)
          ],
          //border: Border.all(color: lRed, width: 1.0),

          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Container(
            height: 130,
            child: Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 50,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  apiVideosURL + videosModel.videos[currentIndex].thumbnailUrl,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
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
              isUnfriend: true,
            ));

    if (value == "block" || value == "report") {
      init();
    } else if (value == "unfriend") {
      Navigator.of(context).pop();
    }
  }

  checkRoseCount(context) async {
    DocumentSnapshot docCurrent = await _reference
        .doc(widget.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    if (docCurrent['roseColl'] >= 1) {
      setState(() {
        userRecord++;
      });
      insertData();
      showRoseDialog(context);
      print("R Sent");
      Fluttertoast.showToast(
          msg: "Delivered".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: mRed,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      noRoseDialog(context);
    }
  }

  insertData() async {
    CollectionReference userRef =
        await _reference.doc(widget.user.uid).collection('R');
    DocumentSnapshot userCountDoc = await userRef.doc('count').get();
    DocumentSnapshot docCurrent = await _reference
        .doc(widget.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    DocumentSnapshot userDocData =
        await userRef.doc(widget.currentUser.uid).get();

    print('uid: ${widget.currentUser.uid}');
    _reference.doc(widget.currentUser.uid).collection('R').doc('count').update({
      "roseColl": docCurrent['roseColl'] - 1,
    });

    print('otherUid: ${widget.user.uid}');
    if (userCountDoc.data() != null) {
      print("userCount not null");
      if (userDocData.data() != null) {
        print("userDoc not null");

        try {
          int oldFresh = await userDocData['fresh'];
          int oldTotal = await userDocData['total'];
          userRef.doc(widget.currentUser.uid).update({
            "pictureUrl": widget.currentUser.profilepic,
            "fresh": oldFresh + 1,
            "total": oldTotal + 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': widget.currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      } else {
        print("userDoc null");

        try {
          userRef.doc(widget.currentUser.uid).set({
            "pictureUrl": widget.currentUser.profilepic,
            "fresh": 1,
            "total": 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': widget.currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      }
      userRef.doc('count').update({
        "roseRec": userCountDoc['roseRec'] + 1,
        "new": userCountDoc['new'] + 1,
        "isRead": false,
      });
    } else {
      print("Else");
      userRef.doc('count').set({
        "roseRec": 1,
        "new": 1,
        "isRead": false,
      });

      userRef.doc(widget.currentUser.uid).set({
        "pictureUrl": widget.currentUser.profilepic,
        "fresh": 1,
        "total": 1,
        'timestamp': DateTime.now(),
        //'type':"received",
        'isRead': false,
        'name': widget.currentUser.name,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });
    }
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

  Future noRoseDialog(context) async {
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
              Text(
                  "OOPS!!! You don't have any LitPie to give in your collection. Please go to your profile and collect it now."
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      color: white,
                      decoration: TextDecoration.none,
                      fontSize: _screenWidth >= miniScreenWidth ? 22 : 18)),
              SizedBox(
                height: 10,
              ),
              Tooltip(
                message: "Go Now".tr(),
                preferBelow: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 10.0),
                  child: Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: ElevatedButton(
                        child: Text("Go Now".tr(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoseCollec()));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: mRed,
                          onPrimary: white,
                          elevation: 3,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 35.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext buildContext) {
    //       Future.delayed(Duration(seconds: 5), () {
    //         Navigator.pop(context);
    //         //  Navigator.push(context, CupertinoPageRoute(builder: (context) => Welcome()));
    //       });
    //       return Center(
    //         child: Padding(
    //           padding: const EdgeInsets.all(20.0),
    //           child: Container(
    //             height: MediaQuery.of(context).size.height * .55,
    //             color: Colors.blueGrey.withOpacity(0.5),
    //             child: Align(
    //               alignment: Alignment.center,
    //               child: Text(
    //                   "OOPS!!! You don't have any ROSE to give in your collection. Please go to your profile and collect it now.".tr(),
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(fontFamily: 'Handlee',
    //                       fontWeight: FontWeight.w700, color:white,
    //                       decoration: TextDecoration.none, fontSize: 22)
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }

  _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
        );
      } else {
        Fluttertoast.showToast(
            msg: "URL: $url",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("url error:- $e");
    }
  }
}
