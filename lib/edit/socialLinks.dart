import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class SocialLinks extends StatefulWidget {
  @override
  _SocialLinks createState() => _SocialLinks();
}

class _SocialLinks extends State<SocialLinks>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController instagramController = new TextEditingController();
  TextEditingController facebookController = new TextEditingController();
  TextEditingController _snapchatController = new TextEditingController();
  TextEditingController _tikTokController = new TextEditingController();
  TextEditingController _twitterController = new TextEditingController();
  TextEditingController _youtubeController = new TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;

  String insta, fb, snap, twitter, youtube, website, tiktok;

  CreateAccountData accountData;

  Future<CreateAccountData> getUser() async {
    final User user = auth.currentUser;
    return _reference
        .doc(user.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.data()));
  }

  Map<String, dynamic> socioInfo = {};

  Future setUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(accountData.uid)
        .set({'socioInfo': socioInfo}, SetOptions(merge: true));
  }

  void initState() {
    super.initState();
    getUser().then((value) {
      if (!mounted) return;

      setState(() {
        accountData = value;
        if( value.socioInfo!=null) {
        if( value.socioInfo.isNotEmpty)  {
            instagramController.text = value.socioInfo['insta'];
            facebookController.text = value.socioInfo['fb'];
            _snapchatController.text = value.socioInfo['snap'];
            _tikTokController.text = value.socioInfo['tiktok'];
            _twitterController.text = value.socioInfo['twitter'];
            _youtubeController.text = value.socioInfo['youtube'];

            insta = value.socioInfo['insta'];
            fb = value.socioInfo['fb'];
            snap = value.socioInfo['snap'];
            tiktok = value.socioInfo['tiktok'];
            twitter = value.socioInfo['twitter'];
            youtube = value.socioInfo['youtube'];
          }
        }
        // website = value.socioInfo['website'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (socioInfo.length > 0) {}
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: ElevatedButton(
                  child: Text(
                    "SAVE".tr(),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      print('validation successful');
                      if (socioInfo.length > 0) {
                        setUserData();
                      }
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          msg: "Updated".tr(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.blueGrey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: mRed,
                      onPrimary: white,
                      padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          child: Text(
                            "My Social links".tr(),
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 30 : 20,
                                fontWeight: FontWeight.w400),
                          ),
                          padding: EdgeInsets.only(
                            top: 40,
                            left: 30,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "Facebook",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: facebookController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'fb': text});
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: themeProvider.isDarkMode ? white : black,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(color: lRed)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(color: mRed, width: 3)),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(color: mRed)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(color: mRed, width: 3)),
                            hintText:
                                "Type/Paste complete url/link here.....".tr(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "Instagram",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: instagramController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'insta': text});
                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: themeProvider.isDarkMode ? white : black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              hintText: "Type/Paste complete url/link here....."
                                  .tr()),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "Snapchat",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: _snapchatController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'snap': text});
                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: themeProvider.isDarkMode ? white : black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              hintText: "Type/Paste complete url/link here....."
                                  .tr()),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "TikTok",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: _tikTokController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'tiktok': text});
                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: themeProvider.isDarkMode ? white : black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              hintText: "Type/Paste complete url/link here....."
                                  .tr()),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "Twitter",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: _twitterController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'twitter': text});
                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: themeProvider.isDarkMode ? white : black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              hintText: "Type/Paste complete url/link here....."
                                  .tr()),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text(
                            "YouTube",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 22 : 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: _youtubeController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text) {
                            socioInfo.addAll({'youtube': text});
                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: themeProvider.isDarkMode ? white : black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: mRed, width: 3)),
                              hintText: "Type/Paste complete url/link here....."
                                  .tr()),
                        ),
                      ),
                      /* SizedBox(height: 30,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(

                          padding: EdgeInsets.only(left: 25),
                          child: Text("Website",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                        child: TextFormField(
                          controller: _websiteController,
                          validator: _validateLink,
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (text){
                            socioInfo.addAll({'website':text});

                          },
                          decoration: InputDecoration(
                              errorStyle: TextStyle(color: themeProvider.isDarkMode? white :black,),

                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: lRed)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(color: mRed ,width: 3)),
                                  errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: mRed)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: mRed, width: 3)),

                              hintText: "Paste complete url/link here....."),
                        ),

                      ),


                      */
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _validateLink(String value) {
    if (value.length > 100) {
      return "Cannot exceed 100 letters.".tr();
    }
  }
}
