import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/common/appConfig.dart';
import 'package:litpie/common/assets.dart';
import 'package:litpie/main.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class OTPphoneLogin extends StatefulWidget {
  String phone;
  String countryCode;

  OTPphoneLogin({this.phone, this.countryCode});

  @override
  _OTPphoneLogin createState() => _OTPphoneLogin();
}

class _OTPphoneLogin extends State<OTPphoneLogin> {
  TextEditingController _pincontroller = TextEditingController();
  static const _timerDuration = 60;
  StreamController _timerStream = new StreamController<int>();
  Timer _resendCodeTimer;
  String hintText="Enter OTP";

  String vid;

  @override
  void initState() {
    super.initState();
    verifyNumber(widget.phone);
    activeCounter();
  }

  activeCounter() {
    _resendCodeTimer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0)
        _timerStream.sink.add(_timerDuration - timer.tick);
      else {
        _timerStream.sink.add(0);
        _resendCodeTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerStream.close();
    _resendCodeTimer.cancel();
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height:
                    MediaQuery.of(context).size.height, //how to set it to max
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                        ),
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
                          child: Text(
                            AppConfig.otpSent.tr() +
                                "\n" +
                                widget.countryCode.toString() +
                                widget.phone.toString(),
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 24 : 18,
                                color: mRed,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        buildTimer(),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            validator: _validateCode,
                            controller: _pincontroller,
                            style: Theme.of(context).textTheme.subtitle1,
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                  color:
                                      themeProvider.isDarkMode ? white : black,
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
                                hintText:hintText.tr()),
                          ),
                        ),
                        Tooltip(
                          message: "Verify".tr(),
                          preferBelow: false,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: ElevatedButton(
                                  child: Text("Verify".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 22
                                                  : 18,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () =>
                                      verifyPhone(_pincontroller.text.trim()),
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
                        StreamBuilder(
                          stream: _timerStream.stream,
                          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                            return SizedBox(
                              width: 300,
                              height: 80,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                                child: TextButton(
                                    onPressed: snapshot.data == 0
                                        ? () {
                                            // your sending code method
                                            Navigator.pop(context);
                                            _timerStream.sink.add(60);
                                            activeCounter();
                                          }
                                        : null,
                                    child: Center(
                                        child: snapshot.data == 0
                                            ? Text(
                                                "Didn't receive the code? Resend."
                                                    .tr(),
                                                style: TextStyle(
                                                    fontSize: 14, color: mRed),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  // Text("Resend"),
                                                  //Text(' ${snapshot.hasData ? snapshot.data.toString() : 60} seconds '),
                                                ],
                                              ))),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppConfig.expiredMsg.tr()),
        TweenAnimationBuilder(
          tween: Tween(begin: 60.0, end: 0.0),
          duration: Duration(seconds: 60),
          builder: (_, value, child) => Text(
            "00:${value.toInt()}",
            style: TextStyle(color: mRed),
          ),
        ),
      ],
    );
  }

  String _validateCode(String value) {
    if (value.length == 0) {
      return "Enter OTP.".tr();
    }
    return null;
  }

  Future verifyNumber(String mobile)async {
   await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.countryCode + mobile,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        try {
          hintText=credential.smsCode;
          setState(() {

          });
          print(hintText);
          FirebaseAuth.instance.signInWithCredential(credential).then((value) =>
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp())));
        } on FirebaseAuthException catch (e) {
          Utils().showToast("Error, try again");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.toString());
        Utils().showToast("Verification failed");
      },
      codeSent: (String verificationId, int resendToken) {
        vid = verificationId;
        Utils().showToast("OTP sent");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        Utils().showToast("Timeout".tr());
      },
    );
  }

  Future<void> verifyPhone(String code) {
    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: vid, smsCode: code);

    FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .then((value) => Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyApp())))
        .catchError((err) {
      print("phone auth error: $err");
      print("phone auth error code: ${err.code}");
      if (err.code == "invalid-verification-code") {
        Fluttertoast.showToast(
            msg: "Invalid OTP, Try Again Or Check Your Phone Number".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Something Went Wrong, Try Again".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
