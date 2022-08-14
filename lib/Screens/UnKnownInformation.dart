import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../UploadMedia/UploadImages/uplopad_videosFirebase.dart';

class UnknownInfo extends StatefulWidget {
  final CreateAccountData currentUser;
  final CreateAccountData user;

  UnknownInfo(
    this.user,
    this.currentUser,
  );

  @override
  _UnknownInfoState createState() => _UnknownInfoState();
}

class _UnknownInfoState extends State<UnknownInfo> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");

  // double _maxScreenWidth;
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();
  BlockedUserModel blockedModel;
  final BlockUserController blockUserController = BlockUserController();

  UserImagesModel _userImagesModel = UserImagesModel();
  UserVideosModel _userVideosModel = UserVideosModel();
  UserStoriesModel _userStoriesModel = UserStoriesModel();

  /*Future<UserImagesModel> loadImages() async {
    // APi Call
    _userImagesModel =
        await ImagesApiController().getImages(uid: widget.user.uid);
    if (mounted) setState(() {});
    return _userImagesModel;
  }*/

  Future<UserImagesModel> loadImages() async {
    List<Map<String, dynamic>> imageList =
        await ImageController().getAllImages(uid: widget.user.uid);
    List<Images> image = [];
    if (imageList.length > 0) {
      imageList.forEach((element) {
        Images images = Images.fromJson(element);
        image.add(images);
      });
      if (image.length > 0) {
        image = image.reversed.toList();
      }
      _userImagesModel.images = image;
      if (mounted) setState(() {});
    } else {
      _userImagesModel.images = image;
    }
    if (mounted) setState(() {});
    return _userImagesModel;
  }

  Future<UserVideosModel> loadVideos() async {
    var list = await VideoController().getAllVideos(widget.user.uid);
    List<Videos> lis = [];
    if (list.length > 0) {
      list.forEach((element) {
        Videos video = Videos.fromJson(element);
        lis.add(video);
      });
    }
    if (lis.length > 0) {
      lis = lis.reversed.toList();
    }
    userVideosModel.videos = lis;

    if (mounted) setState(() {});
    return userVideosModel;
  }

  Future<UserStoriesModel> loadStories() async {
    try {
      _userStoriesModel =
          await StoriesApiController().getStories(uid: widget.user.uid);
      if (mounted) setState(() {});
      return _userStoriesModel;
    } catch (e) {
      print("Story Load From Api Error: $e");
    }
    //APi Call
  }

  FirebaseController _firebaseController = FirebaseController();
  Future<DocumentSnapshot> likeCountDoc;
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
    loadVideos();
    loadImages().then((value) {
      if (value != null) {
        widget.user.imageUrl = [];
        value.images.forEach((element) {
          widget.user.imageUrl.add(apiImagesURL + element.imageUrl);
        });
        if (mounted) setState(() {});
      }
    });

    //loadStories();
  }

  Future<void> init() async {
    blockedModel = await blockUserController.blockedExistOrNot(
        currentUserId: widget.currentUser.uid, anotherUserId: widget.user.uid);

    if (mounted)
      setState(() {
        isFetched = true;
      });
    isFetched = true;
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
                    // mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 70.0,
                      ),
                      FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          foregroundColor: white,
                          heroTag: "Rbtn",
                          shape: StadiumBorder(
                              side: BorderSide(color: mRed, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 6.0, top: 6, right: 6, bottom: 2),
                            child: Image.asset("assets/images/litpielogo.png"),
                          ),
                          onPressed: () {
                            checkRoseCount(context);
                            HapticFeedback.heavyImpact();
                          }),
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
                  ? Center(
                      child: Text(
                        "USER  NOT AVAILABLE".tr(),
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.w700,
                            fontSize: 22.0,
                            color: lRed),
                      ),
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
                                  // border: Border.all(
                                  //     color: mRed.withOpacity(0.7),
                                  //     width: 2.0),
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

                        Container(
                          //  width: MediaQuery.of(context).size.width * .70,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                // Divider(),
                                Container(
                                  //height: 65,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.blueGrey,
                                          offset: Offset(2, 2),
                                          spreadRadius: 1,
                                          blurRadius: 2),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color:
                                        themeProvider.isDarkMode ? dRed : white,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, top: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                        "${widget.user.name},"
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                        Icons
                                                            .accessibility_rounded,
                                                        size: 14,
                                                      ),
                                                      Text(
                                                        widget.user.distanceBW <=
                                                                5
                                                            ? " Less than 5 Km."
                                                                .tr()
                                                            : widget.user
                                                                        .distanceBW >=
                                                                    1000
                                                                ? NumberFormat
                                                                            .compact()
                                                                        .format(widget
                                                                            .user
                                                                            .distanceBW) +
                                                                    " Km. approx. "
                                                                        .tr()
                                                                : "${widget.user.distanceBW}" +
                                                                    " Km. approx. "
                                                                        .tr(),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 13,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            "${widget.user.address}",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
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
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),

                        //Stories Section Start
                        /*   _userStoriesModel != null &&
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
                                      // var video = snapshot.data.data()["videos"][index];
                                      return InkWell(
                                        onTap: () async {
                                          //video["url"];

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

                                          // await Navigator.of(context)
                                          //     .push(MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         StoryDetail(
                                          //           storyModel: _userStoriesModel,
                                          //           currentIndex: index,
                                          //         )))
                                          //     .whenComplete(() {
                                          //   setState(() {
                                          //     print("Refresh!!!");
                                          //   });
                                          // });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          height: 130,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      mYellow.withOpacity(0.8),
                                                  // color: Colors.blueGrey,
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
                            : Container(),*/

                        //Story Section End
                        (_userImagesModel.images == null)
                            ? SizedBox.shrink()
                            : (_userImagesModel.images.length > 0
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Material(
                                          color: themeProvider.isDarkMode
                                              ? dRed
                                              : white,
                                          elevation: 2,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .50,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                Colors.blueGrey,
                                                            offset:
                                                                Offset(2, 2),
                                                            spreadRadius: 1,
                                                            blurRadius: 2),
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
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Center(
                                                            child: Text(
                                                          "Hold on, It's loading....."
                                                              .tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: white),
                                                        )),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                          child: PhotoBrowser(
                                                            user: widget.user,
                                                            images: _userImagesModel !=
                                                                    null
                                                                ? _userImagesModel
                                                                    .images
                                                                : [],
                                                            visiblePhotoIndex:
                                                                0,
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
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink()),

                        //Normal Video Section Start

                        (_userVideosModel.videos == null)
                            ? SizedBox.shrink()
                            : (_userVideosModel.videos.length > 0
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Container(
                                        height: 130,
                                        padding: EdgeInsets.only(
                                            left: _userVideosModel
                                                        .videos.length >=
                                                    3
                                                ? 10
                                                : 10),
                                        child: GridView.builder(
                                            physics: BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount:
                                                _userVideosModel.videos.length,
                                            gridDelegate:
                                                SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 200,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 2 / 2,
                                              crossAxisSpacing: 20,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return _buildVideoThumbnail(
                                                  context: context,
                                                  videosModel: _userVideosModel,
                                                  currentIndex: index);
                                            }),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink()),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
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
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15, bottom: 5),
                                              child: Text(
                                                "Bio :-".tr(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    widget.user.editInfo[
                                                                'bio'] !=
                                                            null
                                                        ? "${widget.user.editInfo['bio']}"
                                                        : '',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
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
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15, bottom: 5),
                                              child: Text(
                                                "Future plans :-".tr(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              physics: BouncingScrollPhysics(),
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                      textAlign:
                                                          TextAlign.start,
                                                    )),
                                              ),
                                            ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
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
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15, bottom: 5),
                                              child: Text(
                                                "Here for :-".tr(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                      textAlign:
                                                          TextAlign.start,
                                                    )),
                                              ),
                                            ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
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
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15, bottom: 5),
                                              child: Text(
                                                "Talk to me only if :-".tr(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                      textAlign:
                                                          TextAlign.start,
                                                    )),
                                              ),
                                            ),
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
                                //Divider(),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CommonSwipeWidget().swipeHeaders(
                                            "My Interests :-".tr()),
                                        widget.user.hobbies.length == null
                                            ? SizedBox()
                                            : Wrap(
                                                children: CommonSwipeWidget()
                                                    .getWrapInterestList(
                                                        widget.user.hobbies),
                                              )
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
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
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
                                  height: 100,
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 15, bottom: 5),
                                          child: Text(
                                            "Social links :-".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Container(
                                            child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'snap'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'snap']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/snapIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: widget.user
                                                            .socioInfo['fb'] !=
                                                        null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'fb']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/fbIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'tiktok'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'tiktok']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/tiktokIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'insta'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'insta']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/instaIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'youtube'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'youtube']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/youtubeIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'twitter'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'twitter']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/twitterIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        widget.user.socioInfo[
                                                                'website'] !=
                                                            null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              _launchURL(widget
                                                                      .user
                                                                      .socioInfo[
                                                                  'website']),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Image.asset(
                                                                "assets/images/websiteIcon.jpg",
                                                                height: 50,
                                                                width: 50),
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // SliverGrid _buildContent(UserImagesModel imgModel) {
  //   return SliverGrid(
  //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //       maxCrossAxisExtent: 170,
  //       mainAxisSpacing: 20,
  //       childAspectRatio: 2 / 2,
  //       crossAxisSpacing: 20,
  //     ),
  //     delegate: SliverChildBuilderDelegate(
  //           (BuildContext context, int index) {
  //         String img_url =
  //             apiImagesURL + _userImagesModel.images[index].imageUrl;
  //         return ImageWidget(
  //           imageList: img_url,
  //           onImageTap: () async => Navigator.push(
  //             context,
  //             _createGalleryDetail(imgModel, index),
  //           ).whenComplete(() {
  //             setState(() {});
  //           }),
  //         );
  //       },
  //       childCount: _userImagesModel.images.length,
  //     ),
  //   );
  // }

  // MaterialPageRoute _createGalleryDetail(
  //     UserImagesModel imagesModel, int index) {
  //   return MaterialPageRoute(
  //     builder: (context) =>
  //         ImageDetail(imagesModel: _userImagesModel, currentIndex: index),
  //   );
  // }

  //
  // Text("$detail"*250,
  // textAlign: TextAlign.center,
  // style: TextStyle(
  // fontFamily: 'Handlee',
  // fontWeight: FontWeight.w700,
  // color: white,
  // decoration: TextDecoration.none,
  // fontSize: 22)),
  void detailDialog(context, String detail) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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

  InkWell _buildVideoThumbnail(
      {@required BuildContext context,
      @required UserVideosModel videosModel,
      @required int currentIndex}) {
    return InkWell(
      onTap: () {
        //video["url"];
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
              isUnfriend: false,
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
    print('uid: ${widget.currentUser.uid}');
    if (docCurrent['roseColl'] >= 1) {
      setState(() {
        //userRecord++;
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
