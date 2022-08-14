import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaPage.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaPageView.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaScaffold.dart';
import 'package:litpie/media/storyMediaDetail/storyMediaVideoScrollListController.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class StoryMediaDetailScreen extends StatefulWidget {
  const StoryMediaDetailScreen({
    Key key,
    @required this.allStories,
    @required this.storyIndex,
    @required this.userUID,
  }) : super(key: key);

  @override
  _StoryMediaDetailScreenState createState() => _StoryMediaDetailScreenState();

  final UserStoriesModel allStories;
  final int storyIndex;
  final String userUID;
}

class _StoryMediaDetailScreenState extends State<StoryMediaDetailScreen>
    with WidgetsBindingObserver {

  StoryMediaPageController _pageController;

  StoryMediaVideoScrollListController _videoListController;

  FirebaseController _firebaseController = FirebaseController();

  // Videos currentVideoDetail;
  Stories currentStoryDetail;
  int _currentIndex;
  int _videoListCounter = 0;

  List<dynamic> storyVideoImagesDynamicList = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (storyVideoImagesDynamicList.isNotEmpty)
      try {
        if (_videoListController.currentPlayer != null) {
          if (!_videoListController.currentPlayer.isDispose)
            _videoListController.currentPlayer.pause();
        }
      } catch (e) {
      }

    super.dispose();
  }

  loadVideoController() {
    _videoListController.init(
      pageController: _pageController,
      initialList: widget.allStories.stories.map(
        (e) {
          if (e.type == "video")
            return VPVideoController(
              storyInfo: e,
              builder: () =>
                  VideoPlayerController.network(apiStoriesURL + e.url),
            );
        },
      ).toList(),
      videoProvider: (int index, List<VPVideoController> list) async {
        return widget.allStories.stories.map(
          (e) {
            if (e.type == "video")
              return VPVideoController(
                storyInfo: e,
                builder: () =>
                    VideoPlayerController.network(apiVideosURL + e.url),
              );
          },
        ).toList();
      },
    );
  }

  final _transformationController = TransformationController();
  TapDownDetails _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        //   ..translate(-position.dx * 2, -position.dy * 2)
        //   ..scale(3.0);
        // Fox a 2x zoom
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  void initState() {
    _pageController = StoryMediaPageController(initialPage: widget.storyIndex);
    _videoListController = StoryMediaVideoScrollListController(
        initVideoIndex: widget.storyIndex, storiesModel: widget.allStories);
    _currentIndex = widget.storyIndex;
    loadVideoController();

    storyVideoImagesDynamicList =
        List.generate(widget.allStories.stories.length, (index) {
      if (widget.allStories.stories[index].type == "video") {
        VPVideoController vpVideoController =
            _videoListController.playerList[_videoListCounter];
        _videoListCounter++;
        return vpVideoController;
      } else {
        return apiStoriesURL + widget.allStories.stories[index].url;
      }
    });
    WidgetsBinding.instance.addObserver(this);

    _videoListController.addListener(() {
      if (mounted) setState(() {});
    });
    currentStoryDetail = widget.allStories.stories[widget.storyIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget currentPage;

    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    bool hasBackground = hasBottomPadding;
    hasBackground = true;
    if (hasBottomPadding) {
      hasBackground = true;
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    IconButton deleteIconButton() {
      return IconButton(
          icon: Icon(
            (CupertinoIcons.delete),
            color: Colors.blueGrey,
            size: 25,
          ),
          onPressed: () {
            String currentStoryId = currentStoryDetail.storyid;

            //pause video before delete
            if (widget.allStories.stories[_currentIndex].type == "video") {
              _videoListController.playerList[_currentIndex].controller.pause();
            }

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
                                currentStoryId = widget
                                    .allStories.stories[_currentIndex].storyid;
                                print("Delete Index : $currentStoryId");
                                if (currentStoryId != null) {
                                  try {
                                    StoriesApiController()
                                        .deletStory(storyId: currentStoryId)
                                        .then((deleted) async {
                                      if (deleted) {
                                        Fluttertoast.showToast(
                                            msg: "Story Deleted Successfully!!"
                                                .tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.blueGrey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);

                                        // userVideosModel.videos.removeAt(_currentIndex);
                                        // _videoListController.playerList[_currentIndex].dispose();
                                        // if (storyVideoImagesDynamicList[
                                        //             _currentIndex]
                                        //         .runtimeType
                                        //         .toString() ==
                                        //     "VPVideoController") {
                                        //   print(
                                        //       "VPVideoController Found in Delete!");
                                        //   int _videoIndex =
                                        //       _videoListController
                                        //           .playerList
                                        //           .indexOf(
                                        //               storyVideoImagesDynamicList[
                                        //                   _currentIndex]);
                                        //   print("Video Index at Delete $_videoIndex");
                                        //   //from video controllers list
                                        //   _videoListController.playerList
                                        //       .removeAt(_videoIndex);
                                        //
                                        // }

                                        _videoListController.playerList
                                            .removeAt(_currentIndex);

                                        //from global data
                                        widget.allStories.stories
                                            .removeAt(_currentIndex);

                                        //form widget tree
                                        storyVideoImagesDynamicList
                                            .removeAt(_currentIndex);

                                        print(
                                            "storyVideoImagesDynamicList Length : ${storyVideoImagesDynamicList.length}");

                                        if (storyVideoImagesDynamicList
                                                .isEmpty ||
                                            _currentIndex ==
                                                storyVideoImagesDynamicList
                                                        .length -
                                                    1) {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          return;
                                        }
                                        Navigator.of(context).pop();
                                        // await loadVideoController();
                                        if (_currentIndex ==
                                            storyVideoImagesDynamicList
                                                .length) {
                                          // _videoListController.index.value = _currentIndex;

                                          await _pageController.previousPage(
                                              duration:
                                                  Duration(milliseconds: 200),
                                              curve: Curves.easeInOut);
                                          print(
                                              "Page Controller Index: ${_pageController.page.toInt()}");

                                          _currentIndex =
                                              _pageController.page.toInt();
                                        }
                                        if (mounted) setState(() {});
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Story Deletion Failed!!, Try Again."
                                                    .tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.blueGrey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    });
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
                                // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
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
            print(widget.userUID);
            //pause video before report
            if (widget.allStories.stories[_currentIndex].type == "video") {
              _videoListController.playerList[_currentIndex].controller.pause();
            }
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) => ReportUser(
                      currentUserUID:
                          _firebaseController.currentFirebaseUser.uid,
                      secondUserUID: widget.userUID,
                      typeOfReport:
                          widget.allStories.stories[_currentIndex].type ==
                                  "video"
                              ? TypeOfReport.storyVideo
                              : TypeOfReport.storyImage,
                      url: widget.allStories.stories[_currentIndex].url,
                      thumbnailUrl:
                          widget.allStories.stories[_currentIndex].type ==
                                  "video"
                              ? widget.allStories.stories[_currentIndex]
                                  .thumbnailUrl
                              : "",
                      mediaID: widget.allStories.stories[_currentIndex].storyid,
                    ));
          });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: StoryMediaScaffold(
        hasBottomPadding: hasBackground,
        enableGesture: true,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25),
            color: Colors.blueGrey,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            widget.allStories.stories[_currentIndex].type == "video"
                ? _videoListController.currentPlayer != null &&
                        _videoListController.playerList[_currentIndex]
                            .controller.value.isInitialized
                    ? _firebaseController.currentFirebaseUser.uid ==
                            widget.userUID
                        ? deleteIconButton()
                        : reportIconButton()
                    : Container()
                : _firebaseController.currentFirebaseUser.uid == widget.userUID
                    ? deleteIconButton()
                    : reportIconButton()
          ],
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
            },
            child: Stack(
              // index: currentPage == null ? 0 : 1,
              children: <Widget>[
                AbsorbPointer(
                  absorbing:
                      widget.allStories.stories[_currentIndex].type == "video"
                          ? !_videoListController
                              .playerOfIndex(_currentIndex)
                              .controller
                              .value
                              .isInitialized
                          : false,
                  child: VideoScrollPageView.builder(
                    key: Key('home'),
                    onPageChanged: (pIndex) {
                      currentStoryDetail = widget.allStories.stories[pIndex];
                      _currentIndex = pIndex;
                      if (mounted) setState(() {});
                    },
                    controller: _pageController,
                    scrollDirection: Axis.horizontal, //direction change
                    // itemCount: _videoListController.videoCount,
                    itemCount: storyVideoImagesDynamicList.length,
                    itemBuilder: (context, i) {
                      if (widget.allStories.stories[i].type == "video") {
                        var player = _videoListController.playerOfIndex(i);
                        var data = widget.allStories.stories[i];

                        // video
                        Widget currentVideo = Center(
                          child: AspectRatio(
                            aspectRatio: player.controller.value.aspectRatio,
                            child: VideoPlayer(player.controller),
                          ),
                        );
                        currentVideo = StoryMediaPage(
                          hidePauseIcon: !player.showPauseIcon.value,
                          aspectRatio: 9 / 16.0,
                          key: Key(data.url + '$i'),
                          tag: data.url,
                          bottomPadding: hasBottomPadding ? 16.0 : 16.0,
                          // userInfoWidget: VideoUserInfo(
                          //   desc: data.desc,
                          //   bottomPadding: hasBottomPadding ? 16.0 : 50.0,
                          // ),
                          player: player.controller,
                          // rightButtonColumn: buttons, //right buttons
                          video: currentVideo,
                        );
                        //   _videoIndex++;
                        return currentVideo;
                      } else {
                        return GestureDetector(
                          onDoubleTapDown: _handleDoubleTapDown,
                          onDoubleTap: _handleDoubleTap,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            panEnabled:
                                false, // Set it to false to prevent panning.
                            // boundaryMargin: EdgeInsets.all(80),
                            minScale: 1,
                            maxScale: 4,
                            child: CachedNetworkImage(
                              imageUrl:
                                  storyVideoImagesDynamicList[i].toString(),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (widget.allStories.stories[_currentIndex].type == "video")
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
                if (widget.allStories.stories[_currentIndex].type == "video")
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
                currentPage ?? Container(),
                if (storyVideoImagesDynamicList != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: storyVideoImagesDynamicList
                          .asMap()
                          .entries
                          .map((entry) {
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
