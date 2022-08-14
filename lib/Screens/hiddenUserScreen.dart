import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Registration/login.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class HiddenUser extends StatefulWidget {
  @override
  _HiddenUser createState() => _HiddenUser();
}

class _HiddenUser extends State<HiddenUser> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool _isHidden = true;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    getUser().then((value) async {
      prefs = await SharedPreferences.getInstance();
    });
  }

  Future<CreateAccountData> getUser() async {
    if (auth.currentUser != null) {
      final User user = auth.currentUser;
      return _reference
          .doc(user.uid)
          .get()
          .then((m) => CreateAccountData.fromDocument(m.data()));
    }
  }

  //double _maxScreenWidth;
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: lRed,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              SizedBox(
                  child: Image.asset(
                "assets/images/practicelogo.png",
                height: 100,
              )),
              SizedBox(
                height: 20,
              ),
              Text(
                "Your profile is now hidden.".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Handlee',
                    fontWeight: FontWeight.w700,
                    //  color: lRed,
                    decoration: TextDecoration.none,
                    fontSize: _screenWidth >= miniScreenWidth ? 24 : 20),
              ),
              ListTile(
                title: Card(
                  color: themeProvider.isDarkMode ? black : white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0, right: 0),
                    child: SwitchListTile(
                        title: _isHidden
                            ? Text(
                                "Profile hidden".tr(),
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 18
                                        : 15),
                              )
                            : Text("Profile visible".tr(),
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 18
                                        : 15)),
                        secondary: _isHidden
                            ? Icon(Icons.visibility_off_outlined, color: lRed)
                            : Icon(Icons.visibility_outlined,
                                color: Colors.green),
                        activeColor: mRed,
                        inactiveThumbColor: Colors.green,
                        inactiveTrackColor: dRed,
                        value: _isHidden,
                        onChanged: (value) {
                          prefs.setBool('isHidden', value);
                          setState(() {
                            _isHidden = value;
                          });
                          bool userStatus = false;
                          if (value) {
                            userStatus = true;
                          }

                          _reference.doc(auth.currentUser.uid).update({
                            "isHidden": userStatus,
                          }).then((_) {
                            print('Profile hidden: $value');
                          });
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => BottomNav()));
                        }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "You have turned your profile into hidden mode and your profile will also not appear for other users. To get into app you need to turn it on."
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      //color: lRed,
                      decoration: TextDecoration.none,
                      fontSize: _screenWidth >= miniScreenWidth ? 24 : 18),
                ),
              ),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(100.0, 15.0, 100.0, 10.0),
                  child: ElevatedButton(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text("Log Out".tr(),
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 18 : 15,
                                fontWeight: FontWeight.bold))),
                    onPressed: () async {
                      await _reference
                          .doc(auth.currentUser.uid)
                          .update({"isOnline": false}).then((_) async {
                        await Constants().deleteDeviceToken();
                        await auth.signOut().whenComplete(() {
                          //_firebaseMessaging.deleteInstanceID();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        });
                        // _ads.disable(_ad);;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: mRed,
                      onPrimary: white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.7)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
