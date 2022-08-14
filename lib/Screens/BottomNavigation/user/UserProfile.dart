import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import 'package:litpie/Screens/my_post/myPost.dart';
import 'package:litpie/Screens/planDate.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/UploadMedia/UploadImages/uplopad_videosFirebase.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/edit/editInfo.dart';
import 'package:litpie/media/addImage.dart';
import 'package:litpie/media/addVideo2.dart';
import 'package:litpie/media/imageDetail.dart';
import 'package:litpie/media/imageWidget.dart';
import 'package:litpie/media/profilePicfullScreen.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaDetailScreen.dart';
import 'package:litpie/media/videoDetail/videoDetailScreen.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

bool isLoading = false;

class UserProfile extends StatefulWidget {
  int currentIndex;

  List<String> imageList;
  final User currentUser;

  UserProfile(
    this.currentUser, {
    Key key,
    this.imageList,
    this.currentIndex,
  }) : super(key: key);

  @override
  _UserState createState() => new _UserState();
}

class _UserState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  FirebaseController _firebaseController = FirebaseController();
  Future<DocumentSnapshot> likeCountDoc;
  String currentUserId;
  GlobalKey<State<Tooltip>> toolTipKey = GlobalKey<State<Tooltip>>();

  CreateAccountData currentUserData;
  UserImagesModel userImagesModel = UserImagesModel();

  Future<CreateAccountData> _getUserData() async {
    await loadImages();
    await loadVideos();
   // await loadStories();
    await getUser().then((value) {
      currentUserData = value;
      //_getStoryLikeCount();
      if (mounted) setState(() {});
      return value;
    });
    return null;
  }

  /*Future<DocumentSnapshot> _getStoryLikeCount() {
    likeCountDoc = _firebaseController.userColReference
        .doc(currentUserId)
        .collection('R')
        .doc('count')
        .get()
        .then((value) {
      return value;
    });
    return null;
  }*/

  @override
  void initState() {
    super.initState();
    currentUserId = _firebaseController.currentFirebaseUser.uid;
    _getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<UserImagesModel> loadImages() async {
    List<Map<String,dynamic>> imageList = await ImageController().getAllImages(uid: currentUserId);
    List<Images> image = [];
    if(imageList.length>0) {
      imageList.forEach((element) {
        Images images = Images.fromJson(element);
        image.add(images);
      });
      if (image.length > 0) {
        image = image.reversed.toList();
      }
      userImagesModel.images = image;
      if (mounted) setState(() {});
    }else{
      userImagesModel.images = image;
    }
    return userImagesModel;
  }

  Future<UserVideosModel> loadVideos() async {
    var list = await VideoController().getAllVideos(currentUserId);
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

  /*Future<UserStoriesModel> loadStories() async {
    //APi Call
    userStoriesModel =
        await StoriesApiController().getStories(uid: currentUserId);
    if (mounted) setState(() {});
    return userStoriesModel;
  }*/

  Future<CreateAccountData> getUser() async {
    CreateAccountData cUserData =
        await _firebaseController.getCurrentUserData();
    return cUserData;
  }

  Future mediaDialog(context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: themeProvider.isDarkMode ? dRed : white,
                          child: Text(
                            "What do you want to upload?".tr(),
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: "Upload Images".tr(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.image_outlined,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    _screenWidth >= miniScreenWidth ? 220 : 180,
                              ),
                              child: Text(
                                "Upload Image".tr(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 16
                                        : 14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (userImagesModel == null) {
                                if (userImagesModel.images.length == null) {
                                  if (userImagesModel.images.length <
                                      imageUploadLimit) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddImages(
                                                  imageFrom:
                                                      ImageFrom.normalImage,
                                                ))).then((value) async {});
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "You can't upload more than".tr() +
                                            " $imageUploadLimit " +
                                            "Images!!".tr(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.blueGrey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please Wait...".tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.blueGrey,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              } else {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => AddImages(
                                              imageFrom: ImageFrom.normalImage,
                                              callback: (value) async {
                                                Future.delayed(Duration.zero);
                                                if (value) {
                                                  await _getUserData();
                                                }
                                              },
                                            )))
                                    .whenComplete(() async {
                                  setState(() {
                                    print("Image Screen Refresh!!!");
                                  });
                                });
                              }
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
                        message: " Upload Video".tr(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.video_call_outlined,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    _screenWidth >= miniScreenWidth ? 220 : 180,
                              ),
                              child: Text(
                                " Upload Video".tr(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 16
                                        : 14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (userVideosModel != null) {
                                if (userVideosModel.videos.length != null) {
                                  if (userVideosModel.videos.length <
                                      videoUploadLimit) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => AddVideo2(
                                                  videoFrom: "normal",
                                                  callback: (value) async {
                                                    if (value != null &&
                                                        value) {
                                                      await loadVideos();
                                                    }
                                                  },
                                                )))
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "You can't upload more than".tr() +
                                            " $videoUploadLimit " +
                                            "Videos!!".tr(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.blueGrey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please Wait...".tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.blueGrey,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              } else {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => AddVideo2(
                                              videoFrom: "normal",
                                              callback: (value) async {
                                                if (value != null && value) {
                                                  await loadVideos();
                                                }
                                              },
                                            )))
                                    .whenComplete(() {
                                  //Video Load Call
                                  setState(() {
                                    print("Video Screen Refresh!!!");
                                  });
                                });
                              }
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

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: currentUserData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FloatingActionButton(
                        backgroundColor: mRed,
                        elevation: 10,
                        foregroundColor: white,
                        heroTag: "editProfile",
                        child: Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditInfo()))
                              .whenComplete(() {
                            _getUserData();
                          });
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        foregroundColor: white,
                        heroTag: "roseBtn",
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
                            //     :
                            Padding(
                          padding: const EdgeInsets.only(
                              left: 6.0, top: 6, right: 6, bottom: 2),
                          child: Image.asset("assets/images/litpielogo.png"),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoseCollec()));
                        },
                      ),
                      FutureBuilder<DocumentSnapshot>(
                          future: likeCountDoc,
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data.exists) {
                                return Text(
                                  snapshot.data["roseRec"] >= 1000
                                      ? NumberFormat.compact()
                                          .format(snapshot.data["roseRec"])
                                      : "${snapshot.data['roseRec']}",
                                  //style: TextStyle(color: black),
                                );
                              } else {
                                return Text(
                                  '...',
                                  //style: TextStyle(color: black),
                                );
                              }
                            } else {
                              return Text(
                                "...",
                                //style: TextStyle(color: black),
                              );
                            }
                          }),
                      SizedBox(
                        height: 6,
                      ),
                      FloatingActionButton(
                        backgroundColor: mRed,
                        elevation: 10,
                        foregroundColor: white,
                        heroTag: "mediaBtn",
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          //size: 20,
                        ),
                        onPressed: () async {
                          await mediaDialog(context).whenComplete(() async {});
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => RoseCollec()));
                        },
                      ),
                    ],
                  )
                : Container(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: currentUserData == null
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: SafeArea(
                    child: RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: mRed,
                      onRefresh: () async {
                        return await _getUserData() ?? true;
                      },
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilePicScreen()))
                                      .whenComplete(() async {
                                    currentUserData = await _firebaseController
                                        .getUserData(uid: currentUserId);
                                    if (mounted) setState(() {});
                                  });
                                },
                                child: Center(
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
                                            child: currentUserData.profilepic !=
                                                        null &&
                                                    currentUserData
                                                        .profilepic.isNotEmpty
                                                ? CachedNetworkImage(
                                                    height: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 150
                                                        : 125,
                                                    width: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 150
                                                        : 125,
                                                    fit: BoxFit.fill,
                                                    imageUrl: currentUserData
                                                        .profilepic,
                                                    useOldImageOnUrlChange:
                                                        true,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(
                                                      radius: 15,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.error,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 30,
                                                        ),
                                                        Text(
                                                          "Enable to load".tr(),
                                                          style: TextStyle(
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          Center(
                                                              child: Text(
                                                                  "upload profile pic"
                                                                      .tr(),
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Handlee',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          white,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize: _screenWidth >=
                                                                              miniScreenWidth
                                                                          ? 16
                                                                          : 15))),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                      ),
                                      if (currentUserData.isVaccinated != null)
                                        if (currentUserData.isVaccinated)
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Tooltip(
                                              key: toolTipKey,
                                              message: "I Am Vaccinated".tr(),
                                              textStyle: TextStyle(
                                                  color: Colors.white),
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
                                                  tooltip
                                                      .ensureTooltipVisible();

                                                  Timer(Duration(seconds: 1),
                                                      () {
                                                    toolTipKey.currentState
                                                        .deactivate();
                                                  });
                                                },
                                                child: Container(
                                                  width: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 35
                                                      : 30,
                                                  height: _screenWidth >=
                                                          miniScreenWidth
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
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  _screenWidth >= miniScreenWidth ? 220 : 180,
                            ),
                            child: Text(
                              currentUserData.name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 20 : 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),

                          SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: "My Posts".tr(),
                                preferBelow: false,
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyPollScreen()));
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: _screenWidth >= miniScreenWidth
                                          ? 150
                                          : 130,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mRed,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.poll_outlined,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                _screenWidth >= miniScreenWidth
                                                    ? 90
                                                    : 70,
                                          ),
                                          child: Text(
                                            "My Posts".tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 16
                                                    : 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Tooltip(
                                message: "Plan Now".tr(),
                                preferBelow: false,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PlanDate()));
                                    // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CreatePollScrenn()));
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: _screenWidth >= miniScreenWidth
                                          ? 150
                                          : 130,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mRed,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.calendar_today,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                _screenWidth >= miniScreenWidth
                                                    ? 90
                                                    : 70,
                                          ),
                                          child: Text(
                                            "Plan Now".tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 16
                                                    : 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //dont delete this

                          // temporary button to upload direct to firebase
                          // ElevatedButton(
                          //     onPressed: () async {
                          // click it
                          //       //if(terms == false || terms == null){
                          //
                          //    _firebaseController.pollColReference.get().then((value) {
                          //    value.docs.forEach((element) {
                          //         _firebaseController.pollColReference.doc(element.id).update({
                          //           "PollQuestion.duration" :Timestamp.fromDate(Timestamp.now().toDate().add(Duration(days: 10))),
                          //       });
                          // _firebaseController.userColReference.get().then((value){
                          //   value.docs.forEach((element) {
                          //     //     // _firebaseController.userColReference.doc(element.id).collection("plans").doc(element.id).update({
                          //     //     //   "createdAt":Timestamp.now()
                          //     //     // });
                          //     //     _firebaseController.userColReference.doc(element.id).update({
                          //     //       "accountCreatedOn":Timestamp.now(),
                          //     //       "termsAccepted":terms,
                          //     //       "termsAcceptedOn":Timestamp.now(),
                          //     //       "lastLogin":Timestamp.now(),
                          //     //
                          //     //
                          //     //     });
                          //     //   });
                          //     // });
                          //  // }
                          // _firebaseController.userColReference
                          //     .get()
                          //     .then((value) {
                          //   value.docs.forEach((element) {
                          //       _firebaseController.userColReference.doc(element.id).collection("plans").doc(element.id).update({
                          //         "planplacepic": ""
                          //       });
                          //
                          //       _firebaseController.userColReference.doc(element.id).collection("plans").doc(element.id).update({
                          //         "pTimeStamp":Timestamp.fromDate(Timestamp.now().toDate().add(Duration(days: 10)))
                          //       });
                          //
                          //       _firebaseController.userColReference.doc(element.id).update({
                          //         "accountCreatedOn":Timestamp.now()

                          //     _firebaseController.userColReference
                          //         .doc(element.id)
                          //         .update({"ADMIN": false});
                          //   });
                          // });
                          // GlobalKey<NavigatorState> _key = GlobalKey<NavigatorState>();
                          // LocalNotification _localNotificationController = LocalNotification(navigatorKey: _key);
                          // await _localNotificationController.showFcmNotification(title: "Hii IOS User", msg: "Body Message to IOS", screen: "like_notification", sound: true, vibrate: true);
                          // },
                          // child: Text("Change / Update")),

                          //Stories.....
                        /*  if (userStoriesModel != null &&
                              userStoriesModel.stories.length > 0)
                            Container(
                              height: 100,
                              padding: EdgeInsets.only(
                                  left: userStoriesModel.stories.length >= 3
                                      ? 10
                                      : 10),
                              child: GridView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: userStoriesModel.stories.length,
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2 / 2,
                                    crossAxisSpacing: 20,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var story = userStoriesModel.stories[index];
                                    // var video = snapshot.data.data()["videos"][index];
                                    return InkWell(
                                      onTap: () async {

                                        await Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    StoryMediaDetailScreen(
                                                        allStories:
                                                            userStoriesModel,
                                                        storyIndex: index,
                                                        userUID:
                                                            currentUserId)))
                                            .whenComplete(() {
                                          setState(() {
                                            print("upload complete");
                                          });
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        height: 130,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: mYellow.withOpacity(0.8),
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
                                                      Icons.play_arrow_rounded,
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
                            ),*/

                          SizedBox(
                            height: 10,
                          ),

                          //Images

                          userImagesModel.images == null
                              ? Container(
                                  height: 10,
                                  child: Center(child: SizedBox.shrink()))
                              : (userImagesModel.images.length > 0
                                  ? Container(
                                      height: _screenWidth >= miniScreenWidth
                                          ? 130.0
                                          : 110,
                                      padding: EdgeInsets.only(
                                          left:
                                              userImagesModel.images.length >= 3
                                                  ? 10
                                                  : 10),
                                      child: CustomScrollView(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        slivers: <Widget>[
                                          SliverPadding(
                                            padding: const EdgeInsets.all(10),
                                            sliver:
                                                _buildContent(userImagesModel),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: 20, child: SizedBox.shrink())),

                          SizedBox(
                            height: 20.0,
                          ),

                          userVideosModel != null &&
                                  userVideosModel.videos != null
                              ? (userVideosModel.videos.length > 0
                                  ? Container(
                                      height: _screenWidth >= miniScreenWidth
                                          ? 130.0
                                          : 110,
                                      // padding: EdgeInsets.only(left: userVideosModel.videos.length >= 3 ? 10 : 10),
                                      padding: EdgeInsets.only(
                                          left:
                                              userVideosModel.videos.length >= 3
                                                  ? 10
                                                  : 10),
                                      child: GridView.builder(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount:
                                              userVideosModel.videos.length,
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
                                                videosModel: userVideosModel,
                                                currentIndex: index);
                                          }),
                                    )
                                  : Container(
                                      child: Center(
                                        child: SizedBox.shrink(),
                                      ),
                                    ))
                              : Container(
                                  child: Center(
                                    child: SizedBox.shrink(),
                                  ),
                                ),
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () => detailDialog(
                                context, currentUserData.editInfo['bio']),
                            child: Visibility(
                                visible:
                                    currentUserData.editInfo['bio'] != null &&
                                        currentUserData.editInfo['bio'] != "",
                                child: Column(
                                  children: [
                                    // Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: CommonSwipeWidget()
                                                .swipeHeaders("Bio :-".tr()),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      currentUserData.editInfo[
                                                                  'bio'] !=
                                                              null
                                                          ? currentUserData
                                                              .editInfo['bio']
                                                              .toString()
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
                                  ],
                                )),
                          ),

                          GestureDetector(
                            onTap: () => detailDialog(
                                context, currentUserData.editInfo['future']),
                            child: Visibility(
                                visible: currentUserData.editInfo['future'] !=
                                        null &&
                                    currentUserData.editInfo['future'] != "",
                                child: Column(
                                  children: [
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Container(
                                      height: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: CommonSwipeWidget()
                                                .swipeHeaders(
                                                    "Future plans :-".tr()),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      currentUserData.editInfo[
                                                                  'future'] !=
                                                              null
                                                          ? currentUserData
                                                              .editInfo[
                                                                  'future']
                                                              .toString()
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
                                  ],
                                )),
                          ),

                          GestureDetector(
                            onTap: () => detailDialog(
                                context, currentUserData.editInfo['hereFor']),
                            child: Visibility(
                                visible: currentUserData.editInfo['hereFor'] !=
                                        null &&
                                    currentUserData.editInfo['hereFor'] != "",
                                child: Column(
                                  children: [
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Container(
                                      height: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: CommonSwipeWidget()
                                                .swipeHeaders(
                                                    "Here for :-".tr()),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      currentUserData.editInfo[
                                                                  'hereFor'] !=
                                                              null
                                                          ? currentUserData
                                                              .editInfo[
                                                                  'hereFor']
                                                              .toString()
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
                                  ],
                                )),
                          ),

                          GestureDetector(
                            onTap: () => detailDialog(
                                context, currentUserData.editInfo['talkToMe']),
                            child: Visibility(
                                visible: currentUserData.editInfo['talkToMe'] !=
                                        null &&
                                    currentUserData.editInfo['talkToMe'] != "",
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Container(
                                      height: 70,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: CommonSwipeWidget()
                                                .swipeHeaders(
                                                    "Talk to me only if :-"
                                                        .tr()),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              physics: BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      currentUserData.editInfo[
                                                                  'talkToMe'] !=
                                                              null
                                                          ? currentUserData
                                                              .editInfo[
                                                                  'talkToMe']
                                                              .toString()
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
                                  ],
                                )),
                          ),
                          Visibility(
                              visible: currentUserData.hobbies != null &&
                                  currentUserData.hobbies.isNotEmpty,
                              child: Column(
                                children: [
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  // SizedBox(height: 10,),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12.0),
                                          child: CommonSwipeWidget()
                                              .swipeHeaders(
                                                  "My Interests :- ".tr()),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12.0),
                                          child: Wrap(
                                            children: CommonSwipeWidget()
                                                .getWrapInterestList(
                                                    currentUserData.hobbies),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          currentUserData?.socioInfo!=null?     Column(
                            children: [
                              Divider(
                                color: Colors.grey,
                              ),
                              Container(
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: CommonSwipeWidget().swipeHeaders(
                                          "Social links :-".tr()),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 25),
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
                                                    visible: currentUserData
                                                                    .socioInfo[
                                                                'snap'] !=
                                                            null &&
                                                        currentUserData
                                                            .socioInfo['snap']
                                                            .isNotEmpty,
                                                    child: CommonSwipeWidget()
                                                        .getSocialLinkWidget(
                                                            "assets/images/snapIcon.jpg",
                                                            () {
                                                      _launchURL(
                                                          currentUserData
                                                                  .socioInfo[
                                                              'snap']);
                                                    })),
                                                Visibility(
                                                    visible: currentUserData
                                                                    .socioInfo[
                                                                'fb'] !=
                                                            null &&
                                                        currentUserData
                                                            .socioInfo['fb']
                                                            .isNotEmpty,
                                                    child: CommonSwipeWidget()
                                                        .getSocialLinkWidget(
                                                            "assets/images/fbIcon.jpg",
                                                            () {
                                                      _launchURL(
                                                          currentUserData
                                                                  .socioInfo[
                                                              'fb']);
                                                    })),
                                                Visibility(
                                                    visible: currentUserData
                                                                    .socioInfo[
                                                                'tiktok'] !=
                                                            null &&
                                                        currentUserData
                                                            .socioInfo[
                                                                'tiktok']
                                                            .isNotEmpty,
                                                    child: CommonSwipeWidget()
                                                        .getSocialLinkWidget(
                                                            "assets/images/tiktokIcon.jpg",
                                                            () {
                                                      _launchURL(
                                                          currentUserData
                                                                  .socioInfo[
                                                              'tiktok']);
                                                    })),
                                                Visibility(
                                                  visible: currentUserData
                                                                  .socioInfo[
                                                              'insta'] !=
                                                          null &&
                                                      currentUserData
                                                          .socioInfo['insta']
                                                          .isNotEmpty,
                                                  child: CommonSwipeWidget()
                                                      .getSocialLinkWidget(
                                                          "assets/images/instaIcon.jpg",
                                                          () {
                                                    _launchURL(currentUserData
                                                        .socioInfo['insta']);
                                                  }),
                                                ),
                                                Visibility(
                                                  visible: currentUserData
                                                                  .socioInfo[
                                                              'youtube'] !=
                                                          null &&
                                                      currentUserData
                                                          .socioInfo[
                                                              'youtube']
                                                          .isNotEmpty,
                                                  child: CommonSwipeWidget()
                                                      .getSocialLinkWidget(
                                                          "assets/images/youtubeIcon.jpg",
                                                          () {
                                                    _launchURL(currentUserData
                                                            .socioInfo[
                                                        'youtube']);
                                                  }),
                                                ),
                                                Visibility(
                                                    visible: currentUserData
                                                                    .socioInfo[
                                                                'twitter'] !=
                                                            null &&
                                                        currentUserData
                                                            .socioInfo[
                                                                'twitter']
                                                            .isNotEmpty,
                                                    child: CommonSwipeWidget()
                                                        .getSocialLinkWidget(
                                                            "assets/images/twitterIcon.jpg",
                                                            () {
                                                      _launchURL(
                                                          currentUserData
                                                                  .socioInfo[
                                                              'twitter']);
                                                    })),
                                                Visibility(
                                                    visible: currentUserData
                                                                    .socioInfo[
                                                                'website'] !=
                                                            null &&
                                                        currentUserData
                                                            .socioInfo[
                                                                'website']
                                                            .isNotEmpty,
                                                    child: CommonSwipeWidget()
                                                        .getSocialLinkWidget(
                                                            "assets/images/websiteIcon.jpg",
                                                            () {
                                                      _launchURL(
                                                          currentUserData
                                                                  .socioInfo[
                                                              'website']);
                                                    })),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ):SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
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

  InkWell _buildVideoThumbnail(
      {@required BuildContext context,
      @required UserVideosModel videosModel,
      @required int currentIndex}) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => VideoDetailScreen(
            allVideos: videosModel.videos,
            videoIndex: currentIndex,
            userUID: currentUserId,
          ),
        ))
            .whenComplete(() {
              if(mounted)
                setState(() {

                });
        });
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
                blurRadius: 1)
          ],
          //border: Border.all(color: lRed, width: 1.0),

          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Container(
            key: Key(videosModel.videos[currentIndex].videoid),
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
                    // apiVideosURL + videosModel.videos[currentIndex].thumbnailUrl,
                    videosModel.videos[currentIndex].thumbnailUrl ?? ""),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );

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

  SliverGrid _buildContent(UserImagesModel userImagesModel) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: 20,
        childAspectRatio: 2 / 2,
        crossAxisSpacing: 20,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String img_url = userImagesModel.images[index].imageUrl;
          return ImageWidget(
            imageList: img_url,
            onImageTap: () async => Navigator.push(
              context,
              _createGalleryDetail(userImagesModel, index),
            ).whenComplete(() {
              setState(() {});
            }),
          );
        },
        childCount: userImagesModel.images.length,
      ),
    );
  }

  MaterialPageRoute _createGalleryDetail(
      UserImagesModel imagesModel, int index) {
    return MaterialPageRoute(
      builder: (context) =>
          ImageDetail(imagesModel: imagesModel, currentIndex: index),
    );
  }
}
