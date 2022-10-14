import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/Home/onlineUsers.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/swipe.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/swipe_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/mobileAdsController.dart';
import 'package:litpie/controller/swipeController.dart';
import 'package:litpie/variables.dart';
import 'package:location/location.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/location/allowLocation.dart';
import 'package:litpie/models/allStoriesModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../controller/localNotificationController.dart';
import 'explorePlans.dart';
import 'globalPollScreen.dart';

class Home extends StatefulWidget {
  final int homeRedirectIndex;

  const Home({Key key, this.homeRedirectIndex = 0}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  CollectionReference docRef = FirebaseFirestore.instance.collection('users');
  CollectionReference planRef =
      FirebaseFirestore.instance.collection('Notifications');
  FirebaseAuth auth = FirebaseAuth.instance;
  PageController postScreenPageController = PageController(
    viewportFraction: 1,
  );
  ScrollController onlineScreenScrollController = ScrollController();
  ScrollController pollScreenScrollController = ScrollController();
  SwipeProvider globalSwipeController;

  //double _maxScreenWidth;
  TabController _tabController;
  ScrollController _scrollViewController;
  CreateAccountData currentUser;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Location location = Location();

  bool isLoading = false;
  bool hasMore = true;
  List<CreateAccountData> tempPlansUsers = [];
  List<QueryDocumentSnapshot> tempPlansDocs = [];
  List<Object> allUsersRows = [];
  List<Object> allPlansRows = [];
  MobileAdsController _mobileAdsController = MobileAdsController();
  FirebaseController _firebaseController = FirebaseController();
  String deviceToken = "";

  Map<String, dynamic> userData = {};

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future setUserData(Map<String, dynamic> userData) async {
    final auth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .set(userData, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this, length: 4, initialIndex: widget.homeRedirectIndex);
    _scrollViewController = ScrollController();
    print("checking1");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      globalSwipeController = Provider.of<SwipeProvider>(context, listen: false);
      print("checking data availablity");

      var data = await _getCurrentUser();
      if (data != null) {
        print("data available");
      }
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  _updateLocation() async {
    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        //TurnLocationOn
        Navigator.of(context).pushReplacementNamed('/TurnLocationOn');
      } else {
        await _updateLocationData();
      }
    } else {
      await _updateLocationData();
    }
  }

  _updateLocationData() async {
    var currentLocation = await getLocationCoordinates();
    if (currentLocation == null) {
    } else {
      userData.addAll(
        {
          'location': {
            'latitude': currentLocation['latitude'],
            'longitude': currentLocation['longitude'],
            'address': currentLocation['PlaceName'],
          },
        },
      );
      setUserData(userData);
      // Navigator.of(context).pushReplacementNamed('/BottomNav');
    }
  }

  Future<CreateAccountData> _getCurrentUser() async {
    User user = auth.currentUser;

    print("inside current user");
    return docRef.doc(user.uid).get().then((data) async {
      currentUser = CreateAccountData.fromDocument(data.data());
      if (mounted) setState(() {});
      //getInitialStories();
      getInitialPost();

      // configurePushNotification(currentUser);
      return currentUser;
    });
  }

  Future<AllStoriesModel> getInitialStories() async {
    try {
      setState(() async {
        allStoriesModel = await StoriesApiController()
            .getInitialStoriesWithPagination(currentUserId: currentUser.uid);
        if (mounted) setState(() {});
      });

      return allStoriesModel;
    } catch (e) {
      print("Story Load From Api Error: $e");
    }
    return null;
  }

  Query loadExplorePlansQuery() {
    if (currentUser.showGender == 'everyone') {
      return planRef
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max'])
          .orderBy('age', descending: false);
    } else {
      return planRef
          .where('editInfo.userGender', isEqualTo: currentUser.showGender)
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max']);
    }
  }

  Future<void> getInitialPost() async {
    plansLoading = true;
    if (!hasMore) {
      print("No More Explore Plans");
      return;
    }
    if (isLoading) return;
    // setState(() {
    //   isLoading = true;
    // });
    isLoading = true;

    QuerySnapshot querySnapshot;
    if (plansLastDocument == null) {
      plansUsers = [];
      plansDocs = [];
      try {
        querySnapshot = await loadExplorePlansQuery().limit(plansLimit).get();
      } catch (e) {
        print(e.toString());
      }
      print(querySnapshot);
    } else {
      querySnapshot = await loadExplorePlansQuery()
          .limit(plansLimit)
          .startAfterDocument(plansLastDocument)
          .get();
    }

    if (querySnapshot.docs.length < plansLimit) {
      hasMore = false;
    }

    if (querySnapshot.docs.length <= 0) {
      print("No Plan Found");
    } else {
      plansLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    await filterPlansUsers(querySnapshot: querySnapshot);

    print("plansDocs.length < plansLimit: ${plansDocs.length < plansLimit}");

    if (plansDocs.length < plansLimit) {
      isLoading = false;
      getInitialPost();
    }

    print("Explore Plans Length : ${plansDocs.length}");
    isLoading = false;
    plansLoading = false;
    if (mounted) setState(() {});
  }

  Future<bool> filterPlansUsers({@required QuerySnapshot querySnapshot}) async {
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        QuerySnapshot querySnap;
        querySnap = await querySnapshot.docs[i].reference
            .collection('plans')
            .where('pTimeStamp', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('pTimeStamp', descending: true)
            .get();

        if (querySnap.docs.length != 0) {
          print("Plans Collection : ${querySnap.docs}");

          CreateAccountData temp =
              CreateAccountData.fromDocument(querySnapshot.docs[i].data());
          print("temp2 " + temp.coordinates['lattitude']);
          var distance = Constants()
              .calculateDistance(currentUser: currentUser, anotherUser: temp);
          temp.distanceBW = distance.round();
          if (distance <= currentUser.maxDistance &&
              temp.uid != currentUser.uid &&
              !temp.isBlocked &&
              !temp.isDeleted &&
              !temp.isHidden &&
              await BlockUserController().blockedExistOrNot(
                      currentUserId: currentUser.uid,
                      anotherUserId: temp.uid) ==
                  null) {
            // if (mounted)
            // setState(() {
            if (i % 2 == 0 && i != 0) {
              allUsersRows
                  .add(_mobileAdsController.loadMediumBannerAd()..load());
              allPlansRows.add("plan-doc-space");
            }
            allUsersRows.add(temp);
            tempPlansUsers.add(temp); //user detail
            tempPlansDocs.add(querySnap.docs[0]); //only one plan
            allPlansRows.add(querySnap.docs[0]);
            // });
          } else {
            print("Distance Not Match");
          }
        } else {
          print("Post Not Found!");
        }
      }
      if (i == querySnapshot.docs.length - 1) {
        plansDocs.addAll(allPlansRows);
        plansUsers.addAll(allUsersRows);
        tempPlansUsers.clear();
        tempPlansDocs.clear();
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: NestedScrollView(
                controller: _scrollViewController,
                headerSliverBuilder:
                    (BuildContext context, bool boxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      pinned: false,
                      snap: true,
                      title: TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          unselectedLabelColor: Colors.blueGrey,
                          unselectedLabelStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                          labelColor: white,
                          labelPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: mRed),
                          tabs: [
                            Tab(
                              iconMargin: EdgeInsets.all(0.0),
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(0);
                                  Future.delayed(Duration(seconds: 2), () {
                                    if (globalSwipeController != null) {
                                      if (!globalSwipeController.isFetching) {
                                        if (globalSwipeController
                                                .swipeCardModelList.length <=
                                            0) {
                                          if (_tabController.index == 0 &&
                                              mounted) {
                                            Fluttertoast.showToast(
                                                msg: "Moving to Next".tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            _tabController.animateTo(1);
                                          }
                                        }
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: themeProvider.isDarkMode
                                        ? Border.all(
                                            color: Colors.transparent, width: 1)
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("SWIPE").tr(),
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  // await getInitialPost();

                                  _tabController.animateTo(1);
                                  Future.delayed(Duration(seconds: 2),
                                      () async {
                                    if (plansUsers != null &&
                                        !plansLoading) if (plansUsers.isEmpty) {
                                      if (_tabController.index == 2) {
                                        plansLastDocument = null;
                                        hasMore = true;
                                        await getInitialPost().then((v) {
                                          if (plansUsers != null) if (plansUsers
                                                  .isEmpty &&
                                              mounted) {
                                            Fluttertoast.showToast(
                                                msg: "Moving to Next".tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            _tabController.animateTo(3);
                                          }
                                        });
                                      }
                                    }
                                  });
                                  if (postScreenPageController.hasClients) {
                                    if (postScreenPageController.page >= 1) {
                                      postScreenPageController.animateToPage(0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.fastOutSlowIn);
                                    }
                                  }
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: themeProvider.isDarkMode
                                        ? Border.all(
                                            color: Colors.transparent, width: 1)
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("EXPLORE").tr(),
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(2);

                                  if (pollScreenScrollController.hasClients) {
                                    if (pollScreenScrollController.offset > 100)
                                      pollScreenScrollController.animateTo(
                                          pollScreenScrollController
                                              .initialScrollOffset,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.fastOutSlowIn);
                                  }
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: themeProvider.isDarkMode
                                        ? Border.all(
                                            color: Colors.transparent, width: 1)
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("POST".tr()),
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(3);

                                  if (mounted)
                                    Future.delayed(Duration(seconds: 4), () {
                                      if (onlineUsers != null) {
                                        if (isOnline &&
                                            !onlineUserIsFetching) if (onlineUsers
                                                .length <=
                                            0) {
                                          if (_tabController.index == 3 &&
                                              mounted)
                                            Fluttertoast.showToast(
                                                msg: "Moving to Next".tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          /* _tabController.animateTo(4);*/
                                        }
                                      }
                                    });

                                  if (onlineScreenScrollController.hasClients) {
                                    if (onlineScreenScrollController.offset >
                                        100)
                                      onlineScreenScrollController.animateTo(
                                          onlineScreenScrollController
                                              .initialScrollOffset,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.fastOutSlowIn);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: themeProvider.isDarkMode
                                        ? Border.all(
                                            color: Colors.transparent, width: 1)
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                  ),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("WAVE").tr(),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ];
                },
                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      Center(
                          child: SwipeScreen(
                        parentTabController: _tabController,
                      )),
                      Center(
                          child: ExplorePlans(
                        pageController: postScreenPageController,
                      )),
                      Center(
                          child: GlobalPollScreen(
                        scrollController: pollScreenScrollController,
                      )),
                      Center(
                          child: OnlineUsers(
                        parentTabController: _tabController,
                        scrollController: onlineScreenScrollController,
                      )),
                    ]),
              ),
            )),
      ),
    );
  }
}
