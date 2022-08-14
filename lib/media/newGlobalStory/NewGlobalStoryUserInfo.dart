import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/roseCollection.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class GlobalStoryUserInfo extends StatefulWidget {
  const GlobalStoryUserInfo(
      {Key key,
      @required this.currentUser,
      @required this.storyUser,
      @required this.userRef})
      : super(key: key);

  @override
  _GlobalStoryUserInfoState createState() => _GlobalStoryUserInfoState();
  final CreateAccountData currentUser;
  final CreateAccountData storyUser;
  final CollectionReference userRef;
}

class _GlobalStoryUserInfoState extends State<GlobalStoryUserInfo> {
  Future<DocumentSnapshot> likeCountDoc;
  int userRecord;

  @override
  initState() {
    _getStoryLikeCount();

    super.initState();
  }

  Future<DocumentSnapshot> _getStoryLikeCount() {
    likeCountDoc = widget.userRef
        .doc(widget.storyUser.uid)
        .collection('R')
        .doc('count')
        .get()
        .then((value) {
      return value;
    });
    return null;
  }

  checkRoseCount(
      {@required CreateAccountData currentUser,
      @required CreateAccountData anotherUser}) async {
    DocumentSnapshot docCurrent = await widget.userRef
        .doc(widget.currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    if (docCurrent['roseColl'] >= 1) {
      setState(() {
        userRecord++;
      });
      insertData(currentUser: currentUser, anotherUser: anotherUser);
      showRoseDialog(context);
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

  Future showRoseDialog(context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext buildContext) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
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
              width: 130.0,
              height: 130.0,
              child: themeProvider.isDarkMode
                  ? Image.asset(
                      "assets/images/RoseDarkB.png",
                      height: 60,
                    )
                  : Image.asset(
                      "assets/images/RoseLightB.png",
                      height: 60,
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
            backgroundColor: Colors.blueGrey.withOpacity(0.8),
            children: [
              Text(
                  "OOPS!!! You don't have any ROSE to give in your collection. Please go to your profile and collect it now."
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      color: white,
                      decoration: TextDecoration.none,
                      fontSize: 22)),
              SizedBox(
                height: 10,
              ),
              Tooltip(
                message: "Go Now".tr(),
                preferBelow: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 10.0),
                  child: ElevatedButton(
                    child: Text("Go Now".tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
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
    //               child: Text("OOPS!!! You don't have any ROSE to give in your collection. Please go to your profile and collect it now.".tr(),
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                       fontFamily: 'Handlee',
    //                       fontWeight: FontWeight.w700,
    //                       color: themeProvider.isDarkMode ? black : white,
    //                       decoration: TextDecoration.none,
    //                       fontSize: 22)),
    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }

  insertData(
      {@required CreateAccountData currentUser,
      @required CreateAccountData anotherUser}) async {
    CollectionReference collectionRef =
        widget.userRef.doc(anotherUser.uid).collection('R');
    DocumentSnapshot userCountDoc = await collectionRef.doc('count').get();
    DocumentSnapshot docCurrent = await widget.userRef
        .doc(currentUser.uid)
        .collection('R')
        .doc('count')
        .get();
    DocumentSnapshot userDocData =
        await collectionRef.doc(currentUser.uid).get();

    widget.userRef.doc(currentUser.uid).collection('R').doc('count').update({
      "roseColl": docCurrent['roseColl'] - 1,
    });

    if (userCountDoc.data() != null) {
      if (userDocData.data() != null) {
        try {
          int oldFresh = await userDocData['fresh'];
          int oldTotal = await userDocData['total'];
          collectionRef.doc(currentUser.uid).update({
            "pictureUrl": currentUser.profilepic,
            "fresh": oldFresh + 1,
            "total": oldTotal + 1,
            'timestamp': DateTime.now(),
            'isRead': false,
            'name': currentUser.name,
          });
        } catch (e) {}
      } else {
        try {
          collectionRef.doc(currentUser.uid).set({
            "pictureUrl": currentUser.profilepic,
            "fresh": 1,
            "total": 1,
            'timestamp': DateTime.now(),
            'isRead': false,
            'name': currentUser.name,
          });
        } catch (e) {
          print("Firebase Error: $e");
        }
      }
      collectionRef.doc('count').update({
        "roseRec": userCountDoc['roseRec'] + 1,
        "new": userCountDoc['new'] + 1,
        "isRead": false,
      });
    } else {
      collectionRef.doc('count').set({
        "roseRec": 1,
        "new": 1,
        "isRead": false,
      });

      collectionRef.doc(currentUser.uid).set({
        "pictureUrl": currentUser.profilepic,
        "fresh": 1,
        "total": 1,
        'timestamp': DateTime.now(),
        'isRead': false,
        'name': currentUser.name,
      }, SetOptions(merge: true)).then((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0)
          .copyWith(top: 70.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.storyUser.profilepic.isEmpty
                    ? CircleAvatar(
                        backgroundImage: AssetImage(placeholderImage),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.contain,
                        imageUrl: widget.storyUser.profilepic,
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            backgroundImage: imageProvider,
                          );
                        },
                      ),
                SizedBox(
                  width: 6,
                ),
                widget.storyUser.name == "..."
                    ? Text(
                        "Loading.....".tr(),
                        style: TextStyle(color: white),
                      )
                    : Text(
                        "${widget.storyUser.name}".toUpperCase(),
                        style: TextStyle(
                          color: white,
                          fontSize: 17.0,
                          shadows: [
                            Shadow(
                                blurRadius: 13,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1.0, 1.0))
                          ],
                        ),
                      )
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  if (likeCountDoc != null) {
                    checkRoseCount(
                        currentUser: widget.currentUser,
                        anotherUser: widget.storyUser);
                  }
                },
                child:
                    //Icon(Icons.favorite, color: mRed,size: 40,)),
                    themeProvider.isDarkMode
                        ? SizedBox(
                            child: Image.asset("assets/images/RoseDark.png"),
                            height: 35,
                          )
                        : SizedBox(
                            child: Image.asset("assets/images/RoseLight.png"),
                            height: 35,
                          ),
              ),
              FutureBuilder<DocumentSnapshot>(
                  future: likeCountDoc,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.exists) {
                        if (userRecord == null)
                          userRecord = snapshot.data['roseRec'];
                        return Text(
                          userRecord >= 1000
                              ? NumberFormat.compact().format(userRecord)
                              : "$userRecord",
                          style: TextStyle(
                            color: white,
                            shadows: [
                              Shadow(
                                  blurRadius: 13,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1.0, 1.0))
                            ],
                          ),
                        );
                      } else {
                        return Text(
                          '...',
                          style: TextStyle(color: white),
                        );
                      }
                    } else {
                      return Text(
                        "...",
                        style: TextStyle(color: white),
                      );
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
