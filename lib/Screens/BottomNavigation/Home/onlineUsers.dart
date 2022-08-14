import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:litpie/Screens/Information.dart';
import 'package:litpie/Screens/UnKnownInformation.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/controller/mobileAdsController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';


class OnlineUsers extends StatefulWidget {
  final ScrollController scrollController;
  final TabController parentTabController;

  const OnlineUsers({Key key, @required this.scrollController, @required this.parentTabController}) : super(key: key);

  @override
  _OnlineUsers createState() => _OnlineUsers();
}

class _OnlineUsers extends State<OnlineUsers> with AutomaticKeepAliveClientMixin {
  final CollectionReference _reference = FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;
  MobileAdsController _mobileAdsController = MobileAdsController();

  CreateAccountData currentUser;

  List<CreateAccountData> tempOnlineUsers = [];
  List<Object> allRows = [];

  // double _maxScreenWidth;
  DocumentSnapshot lastDocument;
  bool hasMore = true;
  bool isLoading = false;
  int docLimit = 10;
  SharedPreferences prefs;
  FirebaseController _firebaseController = FirebaseController();

  int adsGap = 8;

  Future<CreateAccountData> getUser() async {
    currentUser = await _firebaseController.currentUserData;
    return currentUser;
  }

  @override
  void initState() {
    super.initState();

    getUser().then((cUser) async {
      prefs = await SharedPreferences.getInstance();
      isOnline = cUser.isOnline;
      getOnlineUsers();
      if (mounted) setState(() {});
    });

    widget.scrollController.addListener(() {
      double maxScroll = widget.scrollController.position.maxScrollExtent;
      double currentScroll = widget.scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getOnlineUsers();
      }
    });
  }

  Query query() {
    if (currentUser.showGender == 'everyone') {
      return _reference
          .where('isOnline', isEqualTo: true)
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max'])
          .orderBy('age', descending: false)
          .limit(docLimit);
    } else {
      return _reference
          .where('isOnline', isEqualTo: true)
          .where('editInfo.userGender', isEqualTo: currentUser.showGender)
          .where('age', isGreaterThanOrEqualTo: currentUser.ageRange['min'])
          .where('age', isLessThanOrEqualTo: currentUser.ageRange['max'])
          .orderBy('age', descending: false)
          .limit(docLimit);
    }
  }

  Future<void> getOnlineUsers() async {
    try {
      onlineUserIsFetching = true;
      if (!hasMore) {
        print('No More Online Users');
        return;
      }
      if (isLoading) return;

      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        onlineUsers = [];
        querySnapshot = await query().get();
      } else {
        if (mounted)
          setState(() {
            isLoading = true;
          });
        querySnapshot = await query().startAfterDocument(lastDocument).get();
      }
      // if (querySnapshot.docs.length < docLimit) {
      //
      // }
      if (querySnapshot.docs.length <= 0) {
        hasMore = false;
        print("No Online Users Found");
      } else {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        CreateAccountData temp = CreateAccountData.fromDocument(querySnapshot.docs[i].data());
        var distance = Constants().calculateDistance(currentUser: currentUser, anotherUser: temp);
        temp.distanceBW = distance.round();
        if (distance <= currentUser.maxDistance &&
            temp.uid != currentUser.uid &&
            !temp.isBlocked &&
            !temp.isDeleted &&
            !temp.isHidden &&
            await BlockUserController().blockedExistOrNot(currentUserId: currentUser.uid, anotherUserId: temp.uid) == null) {
          tempOnlineUsers.add(temp);
          if (i % adsGap == 0 && i != 0) {
            allRows.add(temp);
            allRows.add(_mobileAdsController.loadBannerAd());
          } else {
            allRows.add(temp);
          }
        } else {
          //print("Distance Not Match");
        }
      }

      print("Temp Online Users Length: ${tempOnlineUsers.length}");
      if (tempOnlineUsers.length < docLimit) {
        if (mounted)
          setState(() {
            isLoading = false;
          });
        getOnlineUsers();
      }

      if (mounted)
        setState(() {
          onlineUserIsFetching = false;
          onlineUsers.addAll(allRows);
          allRows.clear();
          tempOnlineUsers.clear();
          isLoading = false;
        });
      print("OnlineUsers Length: ${onlineUsers.length}");
    } catch (e) {
      print("error occur");
      print(e);
    }
    // print("pUsers: $pUsers");
  }

  Stream<DocumentSnapshot> waveRequestStream({@required CreateAccountData anotherUser}) {
    return _reference.doc(currentUser.uid).collection('onlineWave').doc(anotherUser.uid).snapshots();
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: isOnline == null
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : Column(
                children: [
                  isOnline == null
                      ? SizedBox(
                          height: _screenWidth >= miniScreenWidth ? MediaQuery.of(context).size.height * .80 : MediaQuery.of(context).size.height * .70,
                        )
                      : ListTile(
                          title: Card(
                            color: themeProvider.isDarkMode ? mBlack : white,
                            child: Padding(
                              padding: _screenWidth >= miniScreenWidth ? EdgeInsets.only(left: 20, right: 20) : EdgeInsets.only(left: 10, right: 10),
                              child: SwitchListTile(
                                  title: isOnline
                                      ? Text(
                                          "You are online".tr(),
                                          style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 18 : 16),
                                        )
                                      : Text(
                                          "You are offline".tr(),
                                          style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 18 : 16),
                                        ),
                                  secondary: isOnline ? Icon(Icons.supervised_user_circle_outlined, color: Colors.green) : Icon(Icons.do_disturb_off_outlined, color: mRed),
                                  activeColor: Colors.green,
                                  inactiveThumbColor: mRed,
                                  inactiveTrackColor: dRed,
                                  value: isOnline,
                                  onChanged: (value) {
                                    if (mounted)
                                      setState(() {
                                        isOnline = value;
                                        prefs.setBool('isOnline', value);
                                      });
                                    bool userStatus = false;
                                    if (value) {
                                      userStatus = true;
                                      hasMore = true;
                                      getOnlineUsers();
                                    }

                                    currentUser.isOnline = userStatus;
                                    // CreateAccountData(isOnline: userStatus ,);

                                    _reference.doc(auth.currentUser.uid).update({
                                      "isOnline": userStatus,
                                    }).then((_) {
                                      print('isOnline: $value');
                                    });

                                    //stream builder -> user -> build - >home / bottom nave / main -> call
                                  }),
                            ),
                          ),
                        ),
                  isOnline == false || isOnline == null
                      ? Expanded(
                          child: Center(
                            child: Text(
                              "Go Online to WAVE.".tr(),
                              style: TextStyle(
                                  fontFamily: 'Handlee',
                                  fontWeight: FontWeight.w700,
                                  // color: lRed,
                                  decoration: TextDecoration.none,
                                  fontSize: _screenWidth >= miniScreenWidth ? 22 : 18),
                            ),
                          ),
                        )
                      : Expanded(
                          child: onlineUserIsFetching == true
                              ? Center(
                                  child: LinearProgressCustomBar(),
                                )
                              : onlineUsers.length > 0
                                  ? RefreshIndicator(
                                      color: Colors.white,
                                      backgroundColor: mRed,
                                      onRefresh: () {
                                        if (mounted)
                                          setState(() {
                                            lastDocument = null;
                                            hasMore = true;
                                            isLoading = false;
                                            onlineUsers = null;
                                          });
                                        return getOnlineUsers();
                                      },
                                      child: ListView.separated(
                                          addAutomaticKeepAlives: true,
                                          separatorBuilder: (BuildContext context, int index) => themeProvider.isDarkMode
                                              ? Divider(
                                                  color: Colors.grey,
                                                  height: 2,
                                                )
                                              : Divider(
                                                  color: Colors.grey,
                                                  height: 3,
                                                ),
                                          // Divider(height: 3),
                                          controller: widget.scrollController,
                                          itemCount: onlineUsers.length,
                                          // shrinkWrap: true,
                                          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                          itemBuilder: (context, index) {
                                            if (onlineUsers[index] is CreateAccountData) {
                                              return Container(
                                                // decoration: BoxDecoration(
                                                //   border: Border(bottom: BorderSide()),
                                                // ),
                                                height: _screenWidth >= miniScreenWidth ? 100.0 : 80.0,
                                                width: double.infinity,
                                                child: ListTile(
                                                    title: Padding(
                                                      padding: const EdgeInsets.all(0.0),
                                                      child: Padding(
                                                        padding: _screenWidth >= miniScreenWidth ? EdgeInsets.all(20.0) : EdgeInsets.all(10.0), //changed from 20.0
                                                        // padding: EdgeInsets.only(left:20,right: 20),
                                                        child: (InkWell(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 0),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    boxShadow: [BoxShadow(color: Colors.blueGrey, offset: Offset(1, 2), spreadRadius: 0, blurRadius: 0)],
                                                                    color: Colors.blueGrey,
                                                                    borderRadius: BorderRadius.circular(
                                                                      80,
                                                                    ),
                                                                  ),
                                                                  child: onlineUsers != null && onlineUsers[index].profilepic.isNotEmpty
                                                                      ? ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                            80,
                                                                          ),
                                                                          child: CachedNetworkImage(
                                                                            height: _screenWidth >= miniScreenWidth ? 55 : 45,
                                                                            width: _screenWidth >= miniScreenWidth ? 55 : 45,
                                                                            fit: BoxFit.fill,
                                                                            imageUrl: onlineUsers[index].profilepic,
                                                                            useOldImageOnUrlChange: true,
                                                                            placeholder: (context, url) => CupertinoActivityIndicator(
                                                                              radius: 1,
                                                                            ),
                                                                            errorWidget: (context, url, error) => Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Icon(
                                                                                  Icons.error,
                                                                                  color: Colors.blueGrey,
                                                                                  size: 1,
                                                                                ),
                                                                                Text(
                                                                                  "Error".tr(),
                                                                                  style: TextStyle(
                                                                                    color: Colors.blueGrey,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                            80,
                                                                          ),
                                                                          child: Container(
                                                                            height: _screenWidth >= miniScreenWidth ? 55 : 45,
                                                                            width: _screenWidth >= miniScreenWidth ? 55 : 45,
                                                                            child: Image.asset(placeholderImage, fit: BoxFit.cover),
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: _screenWidth >= miniScreenWidth ? const EdgeInsets.only(left: 20) : const EdgeInsets.only(left: 10),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height: _screenWidth >= miniScreenWidth ? 10 : 8,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Align(
                                                                          alignment: FractionalOffset.topLeft,
                                                                          child: Container(
                                                                            constraints: BoxConstraints(maxWidth: _screenWidth >= miniScreenWidth ? 180 : 120),
                                                                            child: Text(
                                                                              onlineUsers[index]?.name != null ? "${onlineUsers[index].name.toUpperCase()}," : "",
                                                                              style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 16 : 14, fontWeight: FontWeight.w600),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              //maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(top: 5.0),
                                                                          child: Text(
                                                                            " ${onlineUsers[index].age}",
                                                                            // textAlign: TextAlign.center,
                                                                            style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 14 : 12, fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: _screenWidth >= miniScreenWidth ? 10 : 7,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons.accessibility_rounded,
                                                                          size: _screenWidth >= miniScreenWidth ? 14 : 12,
                                                                        ),
                                                                        Text(
                                                                          onlineUsers[index]?.distanceBW != null
                                                                              ? onlineUsers[index].distanceBW <= 5
                                                                                  ? " Less than 5 Km.".tr()
                                                                                  : onlineUsers[index].distanceBW >= 1000
                                                                                      ? NumberFormat.compact().format(onlineUsers[index].distanceBW) + " Km. approx. ".tr()
                                                                                      : " ${onlineUsers[index].distanceBW}" + " Km. approx. ".tr()
                                                                              : "",
                                                                          //style: TextStyle(fontSize: 18),
                                                                          style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 15 : 13, fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: () {
                                                            showDialog(
                                                                barrierDismissible: false,
                                                                context: context,
                                                                builder: (context) {
                                                                  return UnknownInfo(onlineUsers[index], currentUser);
                                                                });
                                                            //Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateName()));
                                                          },
                                                        )),
                                                      ),
                                                    ),
                                                    trailing: Wrap(
                                                      children: [
                                                        if (currentUser != null)
                                                          StreamBuilder<DocumentSnapshot>(
                                                              stream: waveRequestStream(anotherUser: onlineUsers[index]),
                                                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                                if (snapshot.hasData) {
                                                                  if (snapshot.data.exists) {
                                                                    if (snapshot.data["request"] == "sent" && snapshot.data['isRead'] == false) {
                                                                      return buildRequestButton(
                                                                          title: "Cancel".tr(),
                                                                          onTap: () {
                                                                            HapticFeedback.heavyImpact();
                                                                            //Cancel onTap
                                                                            cancelRequest(index);
                                                                            Fluttertoast.showToast(
                                                                                msg: "Cancelled !!".tr(),
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 3,
                                                                                backgroundColor: Colors.blueGrey,
                                                                                textColor: Colors.white,
                                                                                fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);
                                                                          });
                                                                    }
                                                                    if (snapshot.data["request"] == "received" && snapshot.data['isRead'] == false) {
                                                                      return buildRequestButton(
                                                                          title: "Wave back".tr(),
                                                                          onTap: () {
                                                                            HapticFeedback.heavyImpact();
                                                                            //Accept onTap
                                                                            // acceptRequest(index);
                                                                            acceptRequest(onlineUsers[index], index);
                                                                            Fluttertoast.showToast(
                                                                                msg: "You Waved back!!".tr(),
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 3,
                                                                                backgroundColor: Colors.blueGrey,
                                                                                textColor: Colors.white,
                                                                                fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);
                                                                          });
                                                                    }
                                                                    if (snapshot.data['isRead'] == true) {
                                                                      return buildAcceptButton(
                                                                          title: "Tap to Chat".tr(),
                                                                          onTap: () {
                                                                            showDialog(
                                                                                barrierDismissible: false,
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return Info(onlineUsers[index], currentUser);
                                                                                });
                                                                          });
                                                                    }
                                                                    return buildRequestButton(
                                                                        title: "Cancel".tr(),
                                                                        onTap: () {
                                                                          HapticFeedback.heavyImpact();
                                                                          //Cancel onTap
                                                                          cancelRequest(index);
                                                                          Fluttertoast.showToast(
                                                                              msg: "Canceled!!".tr(),
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 3,
                                                                              backgroundColor: Colors.blueGrey,
                                                                              textColor: Colors.white,
                                                                              fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);
                                                                        });
                                                                  } else {
                                                                    return buildRequestButton(
                                                                        title: "Wave".tr(),
                                                                        onTap: () {
                                                                          HapticFeedback.heavyImpact();
                                                                          // sendRequest(index);
                                                                          sendRequest(onlineUsers[index], index);
                                                                          Fluttertoast.showToast(
                                                                              msg: "You Waved!!".tr(),
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 3,
                                                                              backgroundColor: Colors.blueGrey,
                                                                              textColor: Colors.white,
                                                                              fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);
                                                                        });
                                                                  }
                                                                } else {
                                                                  return buildRequestButton(
                                                                      title: "Wave".tr(),
                                                                      onTap: () {
                                                                        HapticFeedback.heavyImpact();
                                                                        //sendRequest(index);
                                                                        sendRequest(onlineUsers[index], index);
                                                                        Fluttertoast.showToast(
                                                                            msg: "You Waved!!".tr(),
                                                                            toastLength: Toast.LENGTH_SHORT,
                                                                            gravity: ToastGravity.BOTTOM,
                                                                            timeInSecForIosWeb: 3,
                                                                            backgroundColor: Colors.blueGrey,
                                                                            textColor: Colors.white,
                                                                            fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);
                                                                      });
                                                                }
                                                              }),
                                                      ],
                                                    )),

                                                // ListTile(
                                                //   title: Text(onlineUsers[index].name),
                                                // ),
                                              );
                                            } else {
                                              final adContainer = Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                height: _screenWidth >= miniScreenWidth ? 60.0 : 50,
                                                child: AdWidget(
                                                  // key: new UniqueKey(),
                                                  ad: onlineUsers[index] as BannerAd..load(),
                                                ),
                                              );
                                              return StatefulBuilder(
                                                builder: (context, setS) {
                                                  return adContainer;
                                                },
                                              );
                                            }
                                          }),
                                    )
                                  : SingleChildScrollView(
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
                                                  Icons.accessibility,
                                                  size: _screenWidth >= miniScreenWidth ? 100 : 100,
                                                  color: white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8.0,
                                          ),
                                          Text(
                                            "There's no Online user to WAVE,\n now it's time to Plan\n or Explore a DATE \n or watch STORIES or \n create or make your Vote count in POLLS"
                                                .tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Handlee',
                                                fontWeight: FontWeight.w700,
                                                color: lRed,
                                                decoration: TextDecoration.none,
                                                fontSize: _screenWidth >= miniScreenWidth ? 25 : 18),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                  isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5),
                          child: Center(child: LinearProgressCustomBar()),
                        )
                      : Container()
                ],
              ),
      ),
    );
  }

  sendRequest(CreateAccountData accountData, int index) async {
    _reference.doc(onlineUsers[index].uid).get().then((value) async {
      if (value.get('isOnline') == true) {
        await checkRoseCount(accountData).then((checked) {
          if (checked) {
            insertRoseData(accountData);

            _reference.doc(currentUser.uid).collection('onlineWave').doc(onlineUsers[index].uid).set({
              'onlineWave': onlineUsers[index].uid,
              'userName': onlineUsers[index].name,
              'request': "sent",
              'isRead': false,
              // 'waveTo':onlineUsers[index].uid,
              // 'waveBy':currentUser.uid,
            }, SetOptions(merge: true)).then((_) {
              print("success!");
            });

            _reference.doc(onlineUsers[index].uid).collection('onlineWave').doc(currentUser.uid).set({
              'onlineWave': currentUser.uid,
              'request': "received",
              'userName': currentUser.name,
              'isRead': false,
              // 'waveTo':onlineUsers[index].uid,
              // 'waveBy':currentUser.uid,
            }, SetOptions(merge: true)).then((_) {
              print("success!");
            });
          } else {
            noRoseDialog(context);
          }
        });
      } else {
        //Toast // User is Offline
        Fluttertoast.showToast(
            msg: "User is offline!! \n Re-Fetching Online Users",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14);

        // Refresh
        if (mounted)
          setState(() {
            lastDocument = null;
            hasMore = true;
            isLoading = false;
            onlineUsers = null;
          });
        await getOnlineUsers();
      }
    });
  }

  cancelRequest(int index) async {
    DocumentSnapshot docCurrent = await _firebaseController.userColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').get();
    _firebaseController.userColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').update({
      "roseColl": docCurrent['roseColl'] + 4,
    });

    //Delete Request In Current User Database
    _reference.doc(currentUser.uid).collection('onlineWave').doc(onlineUsers[index].uid).get().then((waveRequest) {
      if (waveRequest.data()["request"] == "sent") {
        waveRequest.reference.delete();
      }
    });

    //Delete Request In other User Database
    _reference.doc(onlineUsers[index].uid).collection('onlineWave').doc(currentUser.uid).get().then((waveRequest) {
      if (waveRequest.data()["request"] == "received") {
        waveRequest.reference.delete();
      }
    });
  }

  Future<bool> checkRoseCount(CreateAccountData accountData) async {
    DocumentSnapshot docSnap = await _firebaseController.userColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').get();

    if (docSnap['roseColl'] >= 5) {
      return true;
    } else {
      return false;
    }
  }

  acceptRequest(CreateAccountData accountData, int index) async {
    await checkRoseCount(accountData).then((checked) {
      if (checked) {
        insertRoseData(accountData);
        _reference.doc(currentUser.uid).collection('onlineWave').doc(onlineUsers[index].uid).get().then((waveRequest) {
          FirebaseFirestore.instance.collection("/users/${currentUser.uid}/onlineWave").doc('${waveRequest.data()["onlineWave"]}').update({'isRead': true});
        });
        _reference.doc(onlineUsers[index].uid).collection('onlineWave').doc(currentUser.uid).get().then((waveRequest) {
          FirebaseFirestore.instance.collection("/users/${onlineUsers[index].uid}/onlineWave").doc('${waveRequest.data()["onlineWave"]}').update({'isRead': true});
        });
      } else {
        noRoseDialog(context);
      }
    });
  }

  insertRoseData(CreateAccountData accountData) async {
    String usrId = accountData.uid;
    CollectionReference userRef = await _firebaseController.userColReference.doc(usrId).collection('R');
    DocumentSnapshot userCountDoc = await userRef.doc('count').get();
    DocumentSnapshot docCurrent = await _firebaseController.userColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').get();
    DocumentSnapshot userDocData = await userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).get();

    print('uid: ${_firebaseController.firebaseAuth.currentUser.uid}');
    _firebaseController.userColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').update({
      "roseColl": docCurrent['roseColl'] - 5,
    });

    print('otherUid: $usrId');
    if (userCountDoc.data() != null) {
      print("userCount not null");
      if (userDocData.data() != null) {
        print("userDoc not null");

        try {
          int oldFresh = await userDocData['fresh'];
          int oldTotal = await userDocData['total'];
          userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).update({
            "pictureUrl": currentUser.profilepic,
            "fresh": oldFresh + 1,
            "total": oldTotal + 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      } else {
        print("userDoc null");

        try {
          userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).set({
            "pictureUrl": currentUser.profilepic,
            "fresh": 1,
            "total": 1,
            'timestamp': DateTime.now(),
            //'type':"received",
            'isRead': false,
            'name': currentUser.name,
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

      userRef.doc(_firebaseController.firebaseAuth.currentUser.uid).set({
        "pictureUrl": currentUser.profilepic,
        "fresh": 1,
        "total": 1,
        'timestamp': DateTime.now(),
        //'type':"received",
        'isRead': false,
        'name': currentUser.name,
      }, SetOptions(merge: true)).then((_) {
        print("success!");
      });
    }
  }

  //no use to show
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
                boxShadow: [BoxShadow(color: Colors.transparent, offset: Offset(2, 2), spreadRadius: 2, blurRadius: 5)],
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            backgroundColor: Colors.blueGrey.withOpacity(0.5),
            children: [
              Text("OOPS!!! You need 5 LitPie's to WAVE in your collection. Please go to your profile and collect it now.".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee', fontWeight: FontWeight.w700, color: white, decoration: TextDecoration.none, fontSize: _screenWidth >= miniScreenWidth ? 22 : 18)),
              SizedBox(
                height: 10,
              ),
              Tooltip(
                message: "Go Now".tr(),
                preferBelow: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 10.0),
                  child: ElevatedButton(
                    child: Text("Go Now".tr(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 22 : 18, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RoseCollec()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: mRed,
                      onPrimary: white,
                      elevation: 3,
                      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 35.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget buildAcceptButton({@required String title, @required VoidCallback onTap}) {
    return Container(
      constraints: BoxConstraints(),
      child: Wrap(
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              children: [
                SizedBox(
                  height: _screenWidth >= miniScreenWidth ? 10 : 5,
                ),
                SizedBox(
                    height: _screenWidth >= miniScreenWidth ? 50 : 35,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: _screenWidth >= miniScreenWidth ? 35 : 25,
                    )
                    //     themeProvider.isDarkMode?Image.asset("assets/images/handShakeDark.png")
                    //         :Image.asset("assets/images/handShakeLight.png")
                    ),
                Text(title),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequestButton({@required String title, @required VoidCallback onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      constraints: BoxConstraints(),
      child: Wrap(
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              children: [
                SizedBox(
                  height: _screenWidth >= miniScreenWidth ? 10 : 5,
                ),
                SizedBox(
                    height: _screenWidth >= miniScreenWidth ? 50 : 35,
                    child: themeProvider.isDarkMode ? Image.asset("assets/images/WaveDark.png") : Image.asset("assets/images/WaveLight.png")),
                Text(title),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
