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

class UpdatePassword extends StatefulWidget {
  @override
  _UpdatePassword createState() => _UpdatePassword();
}

class _UpdatePassword extends State<UpdatePassword> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  // double _maxScreenWidth;

  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newpasswordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();

  final auth = FirebaseAuth.instance;

  double _screenWidth;

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
            "Change Password".tr(),
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
                        validator: _validateOldPassword,
                        controller: _oldPasswordController,
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
                            hintText: "Enter current Password".tr()),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: TextFormField(
                        validator: _validatePassword,
                        controller: _newpasswordController,
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
                            hintText: "Enter New Password".tr()),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: TextFormField(
                        validator: _validateConfirmPassword,
                        controller: _confirmpasswordController,
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
                            hintText: "Enter New Password again".tr()),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Tooltip(
                      message: "CHANGE PASSWORD".tr(),
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
                                  child: Text("CHANGE PASSWORD".tr(),
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
                                  final result = await checkOldPassword();
                                  {
                                    if (result) {
                                      final resultPassword =
                                          await updatePassword();
                                      {
                                        if (resultPassword) {
                                          //auth.signOut();
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  print('validation failed');
                                  FocusScope.of(context).unfocus();
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

  String _validateOldPassword(String value) {
    if (value.length == 0) {
      return "Enter current password.".tr();
    }
  }

  String _validatePassword(String value) {
    String pattern = r'^(?=.*?[a-z]).{8,20}$';
    RegExp regExp = new RegExp(pattern);
    Pattern pattern2 = r'^[0-9a-zA-Z]';
    RegExp regExp2 = new RegExp(pattern2);
    Pattern pattern3 = r'^[a-zA-Z0-9]';
    RegExp regExp3 = new RegExp(pattern3);
    if (!regExp.hasMatch(value)) {
      return "Password is weak.".tr();
    }
    if (!regExp2.hasMatch(value)) {
      return "Password is weak, Must contain at least one Capital letter".tr();
    }
    if (!regExp3.hasMatch(value)) {
      return "Password is weak, Must contain at least one number(0-9)".tr();
    }

    return null;
  }

  String _validateConfirmPassword(String value) {
    if (value.isEmpty) return "Please enter a confirm password".tr();
    if (value != _newpasswordController.text)
      return "Password do not match.".tr();
    return null;
  }

  Future<bool> updatePassword() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    firebaseUser.updatePassword(_newpasswordController.text).then((_) {
      auth.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      Fluttertoast.showToast(
          msg: "Password changed".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((onError) {
      Fluttertoast.showToast(
          msg: "Password did not change, try again".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      print(onError);
    });
  }

  Future<bool> checkOldPassword() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    var firebaseUser = FirebaseAuth.instance.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: _oldPasswordController.text);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Current password is wrong!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }
}
