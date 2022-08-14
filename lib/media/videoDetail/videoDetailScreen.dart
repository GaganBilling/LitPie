import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/media/videoDetail/VideoScrollPage.dart';
import 'package:litpie/media/videoDetail/videoScrollListController.dart';
import 'package:litpie/media/videoDetail/videoScrollPageView.dart';
import 'package:litpie/media/videoDetail/videoScrollScaffold.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class VideoDetailScreen extends StatefulWidget {
  final List<Videos> allVideos;
  final int videoIndex;
  final String userUID;

  const VideoDetailScreen(
      {Key key,
      @required this.allVideos,
      @required this.videoIndex,
      @required this.userUID})
      : super(key: key);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen>
    with WidgetsBindingObserver {
  // double _maxScreenWidth;
  VideoScrollPageController _pageController;

  VideoScrollListController _videoListController;

  FirebaseController _firebaseController = FirebaseController();

  Videos currentVideoDetail;
  int _currentIndex;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.allVideos.isNotEmpty)
      try {
        _videoListController.currentPlayer.pause();
      } catch (e) {
        print("Video Error: $e");
      }
    super.dispose();
  }

  @override
  void initState() {
    _pageController = VideoScrollPageController(initialPage: widget.videoIndex);
    _videoListController =
        VideoScrollListController(initVideoIndex: widget.videoIndex);
    _currentIndex = widget.videoIndex;
    WidgetsBinding.instance.addObserver(this);
    _videoListController.init(
      pageController: _pageController,
      initialList: widget.allVideos
          .map(
            (e) => VPVideoController(
              videoInfo: e,
              // builder: () => VideoPlayerController.network(apiVideosURL + e.videoUrl),
              builder: () => VideoPlayerController.network(e.videoUrl),
            ),
          )
          .toList(),
      videoProvider: (int index, List<VPVideoController> list) async {
        return widget.allVideos
            .map(
              (e) => VPVideoController(
                videoInfo: e,
                builder: () => VideoPlayerController.network(e.videoUrl),
              ),
            )
            .toList();
      },
    );
    _videoListController.addListener(() {
      if (mounted) setState(() {});
    });
    currentVideoDetail =
        _videoListController.playerOfIndex(widget.videoIndex).videoInfo;
    super.initState();
  }

  IconButton deleteIconButton(var themeProvider) {
    return IconButton(
        icon: Icon(
          (CupertinoIcons.delete),
          color: Colors.blueGrey,
          size: 25,
        ),
        onPressed: () {
          _videoListController.playerList[_currentIndex].controller.pause();

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: themeProvider.isDarkMode
                      ? black.withOpacity(.5)
                      : white.withOpacity(.5),
                  content: Container(
                    // height: MediaQuery.of(context).size.height / 5,
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
                              // print("Current Index: $currentVideoId");
                              if (_currentIndex != null) {
                                try {
                                  if (mounted)
                                    setState(() {
                                      if (widget.allVideos[_currentIndex] !=
                                          null) {
                                        var result = widget.allVideos.remove(
                                            widget.allVideos[_currentIndex]);
                                        List<Map<String, dynamic>> dataList =
                                            [];
                                        if (widget.allVideos.length > 0) {
                                          widget.allVideos
                                              .forEach((element) async {
                                            dataList.add({
                                              "video": element.videoUrl,
                                              "thumbnail": element.thumbnailUrl,
                                              "id": element.videoid,
                                              "createdAt": element.createdAt,
                                              "createdBy": element.createdBy
                                            });
                                          });
                                          if (result == true) {
                                            _firebaseController.userColReference
                                                .doc(_firebaseController
                                                    .currentFirebaseUser.uid)
                                                .collection(
                                                    videosCollectionName)
                                                .doc(_firebaseController
                                                    .currentFirebaseUser.uid)
                                                .update({
                                              "videos": dataList
                                            }).whenComplete(() {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Video Deleted Successfully!!"
                                                          .tr(),
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 3,
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);

                                              if(mounted) setState(() {


                                              });

                                              _videoListController.addListener(() {
                                                if (mounted) setState(() {

                                                });
                                              });

                                              currentVideoDetail =
                                                  _videoListController.playerOfIndex(_currentIndex,isDelete: true,currentIndex: _currentIndex).videoInfo;
                                            });
                                          }
                                        } else {
                                          _firebaseController.userColReference
                                              .doc(_firebaseController
                                                  .currentFirebaseUser.uid)
                                              .collection(videosCollectionName)
                                              .doc(_firebaseController
                                                  .currentFirebaseUser.uid)
                                              .update({
                                            "videos": []
                                          }).whenComplete(() {});
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Video Deletion Failed!!".tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.blueGrey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                      Navigator.of(context).pop();
                                      //API
                                    });
                                  // Navigator.of(context).pop();
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                            child: Text(
                              "Delete".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              //padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7)),
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
                            child: Text(
                              "Cancel".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary:
                                  themeProvider.isDarkMode ? mBlack : white,
                              onPrimary: Colors.blue[700],
                              //padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  IconButton reportIconButton() {
    return IconButton(
        icon: Icon((CupertinoIcons.flag), size: 25, color: Colors.blueGrey),
        onPressed: () {
          _videoListController.playerList[_currentIndex].controller.pause();
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) => ReportUser(
                    currentUserUID: _firebaseController.currentFirebaseUser.uid,
                    secondUserUID: widget.userUID,
                    typeOfReport: TypeOfReport.video,
                    url: widget.allVideos[_currentIndex].videoUrl,
                    thumbnailUrl: widget.allVideos[_currentIndex].thumbnailUrl,
                    mediaID: widget.allVideos[_currentIndex].videoid,
                  ));
        });
  }

  @override
  Widget build(BuildContext context) {
    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    bool hasBackground = hasBottomPadding;
    // hasBackground = tabBarType != TikTokPageTag.home; below line
    hasBackground = true;
    if (hasBottomPadding) {
      hasBackground = true;
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: VideoScrollScaffold(
        hasBottomPadding: hasBackground,
        enableGesture: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25),
            color: Colors.blueGrey,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            _videoListController.currentPlayer != null &&
                    _videoListController.playerList[_currentIndex].controller
                        .value.isInitialized
                ? _firebaseController.currentFirebaseUser.uid == widget.userUID
                    ? deleteIconButton(themeProvider)
                    : reportIconButton()
                : Container()
          ],
          //upload again
        ),
        // onPullDownRefresh: _fetchData,
        page: Container(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              int sensitivity = 30;
              if (details.delta.dy > sensitivity) {
                // Down Swipe
                Navigator.pop(context);
              }
              // else if(details.delta.dy < -sensitivity){
              //   // Up Swipe
              // }
            }, //temporary commented
            child: Stack(
              children: <Widget>[
                AbsorbPointer(
                  absorbing: !_videoListController
                      .playerOfIndex(_currentIndex)
                      .controller
                      .value
                      .isInitialized,
                  child: VideoScrollPageView.builder(
                    key: Key('home'),
                    onPageChanged: (pIndex) {
                      currentVideoDetail =
                          _videoListController.playerOfIndex(pIndex).videoInfo;
                      _currentIndex = pIndex;
                      _videoListController.playerList[_currentIndex].controller.play();
                      setState(() {});
                    },
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    //direction change
                    itemCount: _videoListController.videoCount,
                    itemBuilder: (context, i) {
                      var player = _videoListController.playerOfIndex(i);
                      var data = player.videoInfo;

                      // video
                      Widget currentVideo = Center(
                        child: AspectRatio(
                          aspectRatio: player.controller.value.aspectRatio,
                          child: VideoPlayer(player.controller),
                        ),
                      );

                      currentVideo = VideoScrollPage(
                        hidePauseIcon: !player.showPauseIcon.value,
                        aspectRatio: 9 / 16.0,
                        key: Key(data.videoid + '$i'),
                        tag: data.videoUrl,
                        bottomPadding: hasBottomPadding ? 16.0 : 16.0,
                        player: player.controller,
                        video: currentVideo,
                      );
                      //
                      return currentVideo;
                    },
                  ),
                ),
                if (!_videoListController
                    .playerOfIndex(_currentIndex)
                    .controller
                    .value
                    .isInitialized)
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(mRed),
                      ),
                    ),
                  ),
                if (!_videoListController
                    .playerOfIndex(_currentIndex)
                    .controller
                    .value
                    .isInitialized)
                  Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.black87,
                            highlightColor: Colors.black38,
                            direction: ShimmerDirection.ltr,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )),
                if (widget.allVideos != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.allVideos.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(entry.key,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut),
                          child: Container(
                              width: 5.0,
                              height: 5.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == entry.key
                                    ? Colors.red
                                    : Colors.white,
                              )),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
