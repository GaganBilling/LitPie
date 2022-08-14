import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/edit/ShowGender.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class Gender extends StatefulWidget {
  @override
  _GenderState createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  bool man = false;
  bool woman = false;
  bool other = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(
                child: Image.asset("assets/images/practicelogo.png"),
                height: 100,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  child: Text(
                    "I am a,".tr(),
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                  ),
                  padding: EdgeInsets.only(
                    top: 40,
                    left: 30,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(80.0, 15.0, 80.0, 10.0),
                  child: ElevatedButton(
                    child: Text(
                      "MAN".tr(),
                      style: TextStyle(
                        fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                        fontWeight: FontWeight.w500,
                        // color: man ? mRed : Colors.blueGrey
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        woman = false;
                        man = true;
                        other = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: man ? mRed : Colors.blueGrey,
                      onPrimary: white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.7)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(80.0, 15.0, 80.0, 10.0),
                  child: ElevatedButton(
                    child: Text(
                      "WOMAN".tr(),
                      style: TextStyle(
                        fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                        fontWeight: FontWeight.w500,
                        // color: man ? mRed : Colors.blueGrey
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        woman = true;
                        man = false;
                        other = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: woman ? mRed : Colors.blueGrey,
                      onPrimary: white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.7)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(80.0, 15.0, 80.0, 10.0),
                  child: ElevatedButton(
                    child: Text(
                      "OTHER".tr(),
                      style: TextStyle(
                        fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                        fontWeight: FontWeight.w500,
                        // color: man ? mRed : Colors.blueGrey
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        woman = false;
                        man = false;
                        other = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: other ? mRed : Colors.blueGrey,
                      onPrimary: white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.7)),
                    ),
                  ),
                ),
              ),
              (man || woman || other)
                  ? SizedBox(
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
                        child: ElevatedButton(
                            child: Text("Continue".tr(),
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 22
                                        : 18,
                                    fontWeight: FontWeight.w600)),
                            onPressed: () {
                              var userGender;
                              if (man) {
                                userGender = "man";
                              } else if (woman) {
                                userGender = "woman";
                              } else {
                                userGender = "other";
                              }
                              editInfo.addAll({'userGender': userGender});
                              setUserData(editInfo);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => ShowGender()));
                            },
                            style: ElevatedButton.styleFrom(
                                primary: mRed,
                                onPrimary: white,
                                elevation: 5,
                                side: BorderSide(color: mRed, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20.7)))),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (editInfo.length > 0) {
      setUserData(editInfo);
    }
  }

  Map<String, dynamic> editInfo = {};

  Future setUserData(Map<String, dynamic> editInfo) async {
    final auth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .set({'editInfo': editInfo}, SetOptions(merge: true));
  }
}
