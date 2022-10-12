import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Registration/forgotpassword.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/common/appConfig.dart';
import 'package:litpie/common/appTextFormField.dart';
import 'package:litpie/common/assets.dart';
import 'package:provider/provider.dart';

import '../Theme/colors.dart';
import '../main.dart';
import '../variables.dart';
import 'dateofBirth.dart';
import 'package:easy_localization/easy_localization.dart';

class EmailLogin extends StatefulWidget {
  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  TextEditingController _emailController = new TextEditingController();

  TextEditingController _passwordController = new TextEditingController();

  final auth = FirebaseAuth.instance;

  bool isLoading = false;

  ///  double _maxScreenWidth;
  double _screenWidth;


@override
  void initState() {
    // TODO: implement initState
  if(kDebugMode){
    // _emailController.text="dhillon@yopmail.com";
    // _passwordController.text="Qwerty1!";
     _emailController.text="ss13@gmail.com";
     _passwordController.text="Abc12345";
  }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeProvider.isDarkMode ? white : dRed,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              //how to set it to max
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          child: Image.asset(
                        AppAssets.LITPIELOGO.name,
                        height: 100,
                      )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 45.0, 25.0, 10.0),
                          child: AppTextFormField(
                            obscureValue: false,
                            textEditingController: _emailController,
                            hintText: "Email",
                            textInputType: TextInputType.emailAddress,
                          )),
                      SizedBox(height: 10),
                      Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: AppTextFormField(
                            obscureValue: true,
                            textEditingController: _passwordController,
                            hintText: "Password",
                            textInputType: TextInputType.text,
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                primary: Colors.blueGrey,
                                padding: EdgeInsets.fromLTRB(
                                    25.0, 15.0, 25.0, 10.0)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword()));
                            },
                            child: Text(
                              AppConfig.forgotPassword.tr(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: _screenWidth >= miniScreenWidth
                                      ? 17
                                      : 15),
                            )),
                      ),
                      SizedBox(height: 5),
                      Tooltip(
                        message: AppConfig.logIn.tr(),
                        preferBelow: false,
                        child: SizedBox(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                            child: ElevatedButton(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: mYellow,
                                      )
                                    : Text(AppConfig.logIn.tr(),
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 22
                                                    : 18,
                                            fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  userLogin();
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
                            AppConfig.createAccountNewUser.tr(),
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

  userLogin() {
    if (_emailController.text.isEmpty) {
      Utils().showToast("Please enter email");
    } else if (!Utils().validateEmail(_emailController.text)) {
      Utils().showToast("Please enter valid email");
    } else if (_passwordController.text.isEmpty) {
      Utils().showToast("Please enter password");
    } else if (_passwordController.text.length < 7) {
      Utils().showToast("Password should be greater than 7 characters");
    } else {
      isLoading = true;
      setState(() {});
      userAuthLogin();
    }
  }

  Future userAuthLogin() async {
    try {
      await auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      if (mounted) isLoading = false;
      setState(() {});
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      setState(() {});
      FocusScope.of(context).unfocus();
      Utils().showToast("Email and Password do not match!!");
    }
  }
}
