import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/media/newGlobalStory/NewGlobalStoryUserInfo.dart';
import 'package:litpie/media/newGlobalStory/newGlobalStoryListController.dart';
import 'package:litpie/media/newGlobalStory/newGlobalStoryPage.dart';
import 'package:litpie/media/newGlobalStory/newGlobalStoryPageView.dart';
import 'package:litpie/media/newGlobalStory/newGlobalStoryScaffold.dart';
import 'package:litpie/models/allStoriesModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class NewGlobalStoryScreen extends StatefulWidget {
  const NewGlobalStoryScreen({
    Key key,
    @required this.allStories,
    @required this.storyIndex,
    // @required this.userUID,
  }) : super(key: key);

  @override
  _NewGlobalStoryScreenState createState() => _NewGlobalStoryScreenState();

  final AllStoriesModel allStories;
  final int storyIndex;
}

class _NewGlobalStoryScreenState extends State<NewGlobalStoryScreen>
    with WidgetsBindingObserver {
  NewGlobalStoryPageController _pageController;

  NewGlobalStoryListController _videoListController;

  FirebaseController _firebaseController = FirebaseController();

  SingleStory currentStoryDetail;
  int _currentIndex;
  int _videoListCounter = 0;
  String lastStoryId;
  bool hasMore = true;
  bool isLoading = false;

  List<dynamic> storyVideoImagesDynamicList = [];
  List<CreateAccountData> storyUsersDetails = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_videoListController.currentPlayer != null) {
      if (!_videoListController.currentPlayer.isDispose)
        _videoListController.currentPlayer.pause();
    }
    super.dispose();
  }

  loadStoryViewWidgets({AllStoriesModel allStoriesModel}) {
    storyVideoImagesDynamicList
        .addAll(List.generate(allStoriesModel.singleStory.length, (index) {
      if (allStoriesModel.singleStory[index].type == "video") {
        VPVideoController vpVideoController =
            _videoListController.playerList[_videoListCounter];
        _videoListCounter++;
        return vpVideoController;
      } else {
        return apiStoriesURL + allStoriesModel.singleStory[index].url;
      }
    }));
  }

  Future<void> getStoryUsersDetail(
      {@required AllStoriesModel storyModel}) async {
    storyModel.singleStory.forEach((element) async {
      String userId = element.uid;
      DocumentSnapshot userDoc =
          await _firebaseController.userColReference.doc(userId).get();
      storyUsersDetails.add(CreateAccountData.fromDocument(userDoc.data()));
      setState(() {});
      return;
    });
  }

  loadMoreVideoController({@required AllStoriesModel storyModel}) {
    getStoryUsersDetail(storyModel: storyModel);
    _videoListController.loadMoreInit(
      laterList: storyModel.singleStory.map(
        (e) {
          if (e.type == "video")
            return VPVideoController(
              storyInfo: e,
              builder: () =>
                  VideoPlayerController.network(apiStoriesURL + e.url),
            );
        },
      ).toList(),
    );

    loadStoryViewWidgets(allStoriesModel: storyModel);
  }

  loadVideoController({@required AllStoriesModel storyModel}) {
    getStoryUsersDetail(storyModel: storyModel);
    _videoListController.init(
      pageController: _pageController,
      initialList: storyModel.singleStory.map(
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
        return storyModel.singleStory.map(
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
    loadStoryViewWidgets(allStoriesModel: storyModel);
  }

  Future<AllStoriesModel> loadMoreGlobalStories() async {
    if (!hasMore) return null;
    if (isLoading) return null;
    isLoading = true; //removed setState

    print("Last Story Id On Load More: $lastStoryId");
    AllStoriesModel tempStoriesModel;
    try {
      tempStoriesModel = await StoriesApiController()
          .getLaterStoriesWithPagination(
              currentUserId: _firebaseController.currentFirebaseUser.uid,
              lastStoryId: lastStoryId,
              limit: 5);
      if (tempStoriesModel.singleStory.length != 0) {
        widget.allStories.itemCount += tempStoriesModel.itemCount;
        widget.allStories.singleStory.addAll(tempStoriesModel.singleStory);
        // loadVideoController(storyModel: tempStoriesModel);
        loadMoreVideoController(storyModel: tempStoriesModel);
        if (mounted) setState(() {});
      } else {
        print("No More Stories");
        hasMore = false; //removed SetState
      }
      isLoading = false; //removed SetState
      return tempStoriesModel;
    } catch (e) {
      isLoading = false; //removed SetState
      print("Story Load From Api Error: $e");
    }
    return null;
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
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  void initState() {
    lastStoryId = widget.allStories
        .singleStory[widget.allStories.singleStory.length - 1].storyid;
    _pageController =
        NewGlobalStoryPageController(initialPage: widget.storyIndex);
    _videoListController = NewGlobalStoryListController(
        initVideoIndex: widget.storyIndex, storiesModel: widget.allStories);
    _currentIndex = widget.storyIndex;
    WidgetsBinding.instance.addObserver(this);

    loadVideoController(storyModel: widget.allStories);
    _videoListController.addListener(() {
      if (mounted) setState(() {});
    });
    currentStoryDetail = widget.allStories.singleStory[widget.storyIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    bool hasBackground = hasBottomPadding;
    hasBackground = true;
    if (hasBottomPadding) {
      hasBackground = true;
    }
    IconButton reportIconButton() {
      return IconButton(
          icon: Icon((CupertinoIcons.flag), size: 25, color: Colors.blueGrey),
          onPressed: () {
            print(widget.allStories.singleStory[_currentIndex].uid);
            //pause video before report
            if (widget.allStories.singleStory[_currentIndex].type == "video") {
              _videoListController.playerList[_currentIndex].controller.pause();
            }
            showDialog(
                // barrierDismissible: true,
                context: context,
                builder: (context) => ReportUser(
                      currentUserUID:
                          _firebaseController.currentFirebaseUser.uid,
                      secondUserUID:
                          widget.allStories.singleStory[_currentIndex].uid,
                      typeOfReport:
                          widget.allStories.singleStory[_currentIndex].type ==
                                  "video"
                              ? TypeOfReport.storyVideo
                              : TypeOfReport.storyImage,
                      url: widget.allStories.singleStory[_currentIndex].url,
                      thumbnailUrl:
                          widget.allStories.singleStory[_currentIndex].type ==
                                  "video"
                              ? widget.allStories.singleStory[_currentIndex]
                                  .thumbnailUrl
                              : "",
                      mediaID:
                          widget.allStories.singleStory[_currentIndex].storyid,
                    ));
          });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: NewGlobalStoryScaffold(
        hasBottomPadding: hasBackground,
        enableGesture: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25),
            color: Colors.blueGrey,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            widget.allStories.singleStory[_currentIndex].type == "video"
                ? _videoListController.currentPlayer != null &&
                        _videoListController.playerList[_currentIndex]
                            .controller.value.isInitialized
                    ? reportIconButton()
                    : Container()
                : reportIconButton()
          ],
        ),
        // onPullDownRefresh: _fetchData,
        page: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            // index: currentPage == null ? 0 : 1,
            children: <Widget>[
              AbsorbPointer(
                absorbing:
                    widget.allStories.singleStory[_currentIndex].type == "video"
                        ? !_videoListController
                            .playerOfIndex(_currentIndex)
                            .controller
                            .value
                            .isInitialized
                        : false,
                child: VideoScrollPageView.builder(
                  key: Key('home'),
                  onPageChanged: (pIndex) {
                    currentStoryDetail = widget.allStories.singleStory[pIndex];
                    _currentIndex = pIndex;
                    if (pIndex == widget.allStories.singleStory.length - 3) {
                      loadMoreGlobalStories();
                      // setState(() {});
                    }
                    if (mounted) setState(() {});
                  },
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  //direction change
                  // itemCount: _videoListController.videoCount,
                  itemCount: storyVideoImagesDynamicList.length,
                  itemBuilder: (context, i) {
                    if (widget.allStories.singleStory[i].type == "video") {
                      var player = _videoListController.playerOfIndex(i);
                      var data = widget.allStories.singleStory[i];

                      // video
                      Widget currentVideo = Center(
                        child: AspectRatio(
                          aspectRatio: player.controller.value.aspectRatio,
                          child: VideoPlayer(player.controller),
                        ),
                      );
                      currentVideo = NewGlobalStoryPage(
                        aspectRatio: 9 / 16.0,
                        key: Key(data.url + '$i'),
                        tag: data.url,
                        bottomPadding: hasBottomPadding ? 16.0 : 16.0,

                        player: player.controller,
                        // rightButtonColumn: buttons, //right buttons
                        video: currentVideo,
                      );

                      return Stack(
                        children: [
                          currentVideo,
                          if (storyUsersDetails.isNotEmpty &&
                              storyUsersDetails[i] != null)
                            GlobalStoryUserInfo(
                                currentUser: _firebaseController.cUserData,
                                storyUser: storyUsersDetails[i],
                                userRef: _firebaseController.userColReference),
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onDoubleTapDown: _handleDoubleTapDown,
                              onDoubleTap: _handleDoubleTap,
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                panEnabled: false,
                                // Set it to false to prevent panning.
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
                            ),
                          ),
                          if (storyUsersDetails.isNotEmpty &&
                              storyUsersDetails.length > i)
                            if (storyUsersDetails[i] != null)
                              Align(
                                alignment: Alignment.topLeft,
                                child: GlobalStoryUserInfo(
                                    currentUser: _firebaseController.cUserData,
                                    storyUser: storyUsersDetails[i],
                                    userRef:
                                        _firebaseController.userColReference),
                              ),
                        ],
                      );
                    }
                  },
                ),
              ),
              if (widget.allStories.singleStory[_currentIndex].type == "video")
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
              if (widget.allStories.singleStory[_currentIndex].type == "video")
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
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.black87,
                          highlightColor: Colors.black38,
                          direction: ShimmerDirection.btt,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black, //check
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
