import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Registration/dateofBirth.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/edit/Gender.dart';
import 'package:litpie/edit/editInfo.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: themeProvider.isDarkMode ? black : white,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 120,
                          ),
                          Center(
                              child: SizedBox(
                                  child: Image.asset(
                            "assets/images/practicelogo.png",
                            height: 100,
                          ))),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 20.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Welcome to LITPIE.\nPlease follow these House Rules."
                                    .tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Always.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Meet in public places, during your initial discussions."
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Be yourself.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Make sure your photos/video, age, and bio are true to who you are."
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Play it cool.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Respect other and treat them as you would like to be treated"
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Stay safe.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Don't be too quick to give out personal information."
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Never ever.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Never share bank details or provide financial help to anyone you just met here."
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Be proactive.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Always report bad behavior.".tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "Messages.".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Messages will disappear after 24 Hours whether read or not.\n So it is better to stay active."
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(
                                "In Detail".tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Please read the Community Guidelines, Safety tips, Privacy Policy, Terms of Service for more information"
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 10.0),
                    child: ElevatedButton(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text("GOT IT".tr(),
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold))),
                        onPressed: () async {
                          User currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            if (currentUser.uid.length > 0) {
                              final snapshot = await FirebaseFirestore.instance
                                  .collection(userCollectionName)
                                  .doc(currentUser.uid)
                                  .collection(rCollectionName)
                                  .get();

                              if (snapshot.docs.length <= 0) {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => Gender()));
                              } else {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => EditInfo()));
                              }
                            } else {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => DateofBirth()));
                            }
                          } else {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => DateofBirth()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: mRed,
                            onPrimary: mYellow,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.7)))),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
