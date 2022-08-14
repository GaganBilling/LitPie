import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Registration/login.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class UpdateEmail extends StatefulWidget {
  @override
  _UpdateEmail createState() => _UpdateEmail();
}

class _UpdateEmail extends State<UpdateEmail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  double _screenWidth;

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: mRed,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Update Email".tr(),
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: TextFormField(
                        validator: _validatePassword,
                        controller: _passwordController,
                        obscureText: true,
                        style: Theme.of(context).textTheme.subtitle1,
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
                            hintText: "Enter Password".tr()),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: TextFormField(
                        validator: _validateEmail,
                        controller: _emailController,
                        style: Theme.of(context).textTheme.subtitle1,
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
                            hintText: "Enter New Email".tr()),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Tooltip(
                      message: "UPDATE EMAIL".tr(),
                      preferBelow: false,
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: ElevatedButton(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  child: Text("UPDATE EMAIL".tr(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 22
                                                  : 18,
                                          fontWeight: FontWeight.w600))),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  print('validation successful');

                                  final result = await checkPassword();
                                  {
                                    if (result) {
                                      await updateEmail();
                                      {}
                                    }
                                  }
                                } else {
                                  print('validation failed');
                                }
                                return;
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: mRed,
                                  onPrimary: mYellow,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.7)))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _validatePassword(String value) {
    if (value.length == 0) {
      return "Enter current password.".tr();
    }
  }

  String _validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Invalid Email.".tr();
    }
    return null;
  }

  Future<bool> checkPassword() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    var firebaseUser = FirebaseAuth.instance.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: _passwordController.text);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Wrong password!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  Future<bool> updateEmail() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    firebaseUser.updateEmail(_emailController.text).then((_) {
      insertData();
      auth.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      Fluttertoast.showToast(
          msg: "Email changed".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((onError) {
      Fluttertoast.showToast(
          msg: "Email did not change, try again".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  insertData() {
    _reference.doc(auth.currentUser.uid).set({
      "email": _emailController.text,
    }, SetOptions(merge: true)).then((_) {});
  }
}
