import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class OTPphoneupdate extends StatefulWidget {
  String phone;
  String ext;

  OTPphoneupdate({this.phone, this.ext});

  @override
  _OTPphoneupdate createState() => _OTPphoneupdate();
}

class _OTPphoneupdate extends State<OTPphoneupdate> {
  TextEditingController _pincontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final auth = FirebaseAuth.instance;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  static const _timerDuration = 60;
  StreamController _timerStream = new StreamController<int>();
  Timer _resendCodeTimer;

  // double _maxScreenWidth;

  String _countryCode = '';
  String _phone = '';
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

    final dynamic _args = ModalRoute.of(context).settings.arguments;
    _screenWidth = MediaQuery.of(context).size.width;
    _phone = _args['phone'];
    _countryCode = _args['countryCode'];

    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height:
                    MediaQuery.of(context).size.height, //how to set it to max
                child: SafeArea(
                  child: Form(
                    key: _formKey,
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
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(25.0, 45.0, 25.0, 10.0),
                            child: Text(
                              "OTP sent on:- ".tr() +
                                  "\n" +
                                  widget.ext.toString() +
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
                            padding:
                                EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: _validateCode,
                              controller: _pincontroller,
                              style: Theme.of(context).textTheme.subtitle1,
                              decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? white
                                        : black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(color: lRed)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide:
                                          BorderSide(color: mRed, width: 3)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(color: mRed)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide:
                                          BorderSide(color: mRed, width: 3)),
                                  hintText: "Enter OTP".tr()),
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
                            builder:
                                (BuildContext ctx, AsyncSnapshot snapshot) {
                              return SizedBox(
                                width: 300,
                                height: 80,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 10.0),
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
                                                      fontSize: 14,
                                                      color: mRed),
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
                  ),
                )),
          ),
        ),
      ),
    );
  }

  String _validateCode(String value) {
    if (value.length == 0) {
      return "Enter OTP.".tr();
    }
    return null;
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This code will expired in ".tr()),
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

  Future<void> verifyNumber(String mobile) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.ext + mobile,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await auth.currentUser
              .updatePhoneNumber(credential)
              .catchError((err) {
            if (err.code == "invalid-verification-code") {
              Fluttertoast.showToast(
                  msg: "Invalid OTP, Try Again".tr(),
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

          insertData();

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BottomNav()));
        } on FirebaseAuthException catch (e) {
          print(e);
          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
          Fluttertoast.showToast(
              msg: "Error, try again".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        Fluttertoast.showToast(
            msg: "Verification failed".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      },
      codeSent: (String verificationId, int resendToken) {
        vid = verificationId;
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Code Sent"+verificationId)));
        Fluttertoast.showToast(
            msg: "OTP sent".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Timeout"+verificationId)));
        Fluttertoast.showToast(
            msg: "Timeout".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      },
    );
  }

  Future<void> verifyPhone(String code) async {
    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: vid, smsCode: code);
    try {
      await auth.currentUser.updatePhoneNumber(phoneAuthCredential);

      insertData();

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: "Error, try again".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  insertData() {
    _reference.doc(auth.currentUser.uid).set({
      "phone": widget.ext + widget.phone,
    }, SetOptions(merge: true)).then((_) {});
  }
}
