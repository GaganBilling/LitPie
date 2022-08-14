import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/location/allowLocation.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class ShowGender extends StatefulWidget {
  @override
  _ShowGenderState createState() => _ShowGenderState();
}

class _ShowGenderState extends State<ShowGender> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final auth = FirebaseAuth.instance;
  bool man = false;
  bool woman = false;
  bool everyone = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                    "Interested in?".tr(),
                    style: TextStyle(
                        fontSize: _screenWidth >= miniScreenWidth ? 30 : 20,
                        fontWeight: FontWeight.w400),
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
                      "MEN".tr(),
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
                        everyone = false;
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
                      "WOMEN".tr(),
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
                        everyone = false;
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
                      "EVERYONE".tr(),
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
                        everyone = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: everyone ? mRed : Colors.blueGrey,
                      onPrimary: white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.7)),
                    ),
                  ),
                ),
              ),
              (man || woman || everyone)
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
                              if (man) {
                                showGender = "man";
                              } else if (woman) {
                                showGender = "woman";
                              } else {
                                showGender = "everyone";
                              }
                              // print(widget.userData);

                              insertData();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => AllowLocation()));
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
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  var showGender;

  insertData() {
    _reference.doc(auth.currentUser.uid).set({
      "showGender": showGender,
    }, SetOptions(merge: true)).then((_) {});
  }
}
