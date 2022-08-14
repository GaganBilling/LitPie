import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

import '../Theme/colors.dart';
import '../variables.dart';
import 'dateofBirth.dart';
import 'emailLogin.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPassword extends StatelessWidget {
  TextEditingController _emailController = new TextEditingController();

  //double _maxScreenWidth;
  final auth = FirebaseAuth.instance;
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height, //how to set it to max
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          child: Image.asset(
                        "assets/images/practicelogo.png",
                        height: 100,
                      )),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: Text(
                            "Forgot Password?".tr(),
                            style: TextStyle(
                                color: mRed,
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 25 : 20,
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: 15),
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
                              hintText: "Email"),
                        ),
                      ),
                      SizedBox(height: 10),
                      Tooltip(
                        message: "RESET PASSWORD".tr(),
                        preferBelow: false,
                        child: SizedBox(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                            child: ElevatedButton(
                                child: Text("RESET PASSWORD".tr(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 22
                                                : 18,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await auth
                                      .sendPasswordResetEmail(
                                          email: _emailController.text)
                                      .whenComplete(() {
                                    Fluttertoast.showToast(
                                        msg: "Check your Email.".tr(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.blueGrey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EmailLogin()));
                                  });
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
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.blueGrey,
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DateofBirth()));
                          },
                          child: Text(
                            "New User? Create Account.".tr(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 17 : 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  String _validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Invalid Email.".tr();
    }
    return null;
  }
}
