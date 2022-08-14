import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/media/newGlobalStory/newGlobalStoryDetailScreen.dart';
import 'package:litpie/models/allStoriesModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class StoryScreen extends StatefulWidget {
  final ScrollController scrollController;
  final TabController parentTabController;

  const StoryScreen(
      {Key key,
      @required this.scrollController,
      @required this.parentTabController})
      : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with AutomaticKeepAliveClientMixin {
  CollectionReference docRef = FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
  CreateAccountData currentUser;

  // double _maxScreenWidth;
  String cUID;

  bool hasMore = true;
  bool isLoading = false;

  Future<CreateAccountData> getUser() async {
    final User user = await auth.currentUser;
    return docRef
        .doc(user.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.data()));
  }

  //Get Stories For Load More
  Future<AllStoriesModel> getLaterStories() async {
    if (!hasMore) return null;
    if (isLoading) return null;
    if (mounted)
      setState(() {
        isLoading = true;
      });
    int storiesLength = allStoriesModel.singleStory.length;
    String lastStoryId = allStoriesModel.singleStory[storiesLength - 1].storyid;
    AllStoriesModel tempStoriesModel;
    try {
      tempStoriesModel = await StoriesApiController()
          .getLaterStoriesWithPagination(
              currentUserId: currentUser.uid,
              lastStoryId: lastStoryId,
              limit: globalStoryLimit);
      if (tempStoriesModel.singleStory.length != 0) {
        allStoriesModel.itemCount += tempStoriesModel.itemCount;
        allStoriesModel.singleStory.addAll(tempStoriesModel.singleStory);
        if (mounted) setState(() {});
      } else {
        print("No More Stories");
        if (mounted)
          setState(() {
            hasMore = false;
          });
      }
      if (mounted)
        setState(() {
          isLoading = false;
        });
      return tempStoriesModel;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Story Load From Api Error: $e");
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    getUser().then((cUser) async {
      cUID = await auth.currentUser.uid;
      currentUser = cUser;
      if (mounted) setState(() {});
    });

    if (mounted) setState(() {});

    widget.scrollController.addListener(() {
      double maxScroll = widget.scrollController.position.maxScrollExtent;
      double currentScroll = widget.scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        // getStories();
        getLaterStories();
      }
    });
  }

  Future<AllStoriesModel> _onStoryRefresh() async {
    try {
      allStoriesModel = await StoriesApiController()
          .getInitialStoriesWithPagination(currentUserId: currentUser.uid);
      if (mounted) setState(() {});
      return allStoriesModel;
    } catch (e) {}
    return null;
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? dRed : white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            allStoriesModel == null
                ? Expanded(
                    child: Center(
                      child: LinearProgressCustomBar(),
                    ),
                  )
                : allStoriesModel.singleStory.length <= 0
                    ? Expanded(
                        child: Center(
                          child: Container(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: lRed,
                                        radius: 60,
                                        child: Icon(
                                          Icons.image_search_rounded,
                                          size: 100,
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Text(
                                    "There's no new STORIES to watch,\n it's time to plan or explore a DATE or\n WAVE to the people nearby or \n create or make your Vote count in POLLS"
                                        .tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Handlee',
                                        fontWeight: FontWeight.w700,
                                        color: lRed,
                                        decoration: TextDecoration.none,
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 25
                                                : 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _onStoryRefresh,
                                color: Colors.white,
                                backgroundColor: mRed,
                                child: GridView.builder(
                                    controller: widget.scrollController,
                                    itemCount:
                                        allStoriesModel.singleStory.length,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10.0,
                                            mainAxisSpacing: 10.0),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          int start = index;
                                          int end = index <
                                                  allStoriesModel
                                                          .singleStory.length -
                                                      5
                                              ? index + 5
                                              : allStoriesModel
                                                  .singleStory.length;
                                          AllStoriesModel globalStoryModel =
                                              AllStoriesModel();
                                          globalStoryModel.itemCount = 5;
                                          globalStoryModel.singleStory =
                                              allStoriesModel.singleStory
                                                  .sublist(start, end);

                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewGlobalStoryScreen(
                                                          allStories:
                                                              globalStoryModel,
                                                          storyIndex: 0)))
                                              .whenComplete(() {
                                            setState(() {
                                              print("Refresh!!!");
                                            });
                                          });
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                                left: 0,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl: allStoriesModel
                                                              .singleStory[
                                                                  index]
                                                              .type ==
                                                          "video"
                                                      ? apiStoriesURL +
                                                          allStoriesModel
                                                              .singleStory[
                                                                  index]
                                                              .thumbnailUrl
                                                      : apiStoriesURL +
                                                          allStoriesModel
                                                              .singleStory[
                                                                  index]
                                                              .url,
                                                ),
                                              ),
                                              allStoriesModel.singleStory[index]
                                                          .type ==
                                                      "video"
                                                  ? Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                        size: 50,
                                                        color: Colors.black
                                                            .withOpacity(0.7),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            // if(!hasMore)
                            //   Container(
                            //     padding: EdgeInsets.all(10.0),
                            //     alignment: Alignment.center,
                            //     child: Text("No More Stories"),
                            //   ),
                          ],
                        ),
                      ),
            isLoading
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    child: Center(child: LinearProgressCustomBar()),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
