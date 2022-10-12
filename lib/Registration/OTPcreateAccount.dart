import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/assets.dart';
import 'package:litpie/edit/Gender.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class OTPCreateAccount extends StatefulWidget {
  String phone;
  String ext;

  OTPCreateAccount({this.phone, this.ext});

  @override
  _OTPCreateAccountState createState() => _OTPCreateAccountState();
}

class _OTPCreateAccountState extends State<OTPCreateAccount> {
  TextEditingController _pincontroller = TextEditingController();
  final auth = FirebaseAuth.instance;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _name = '';
  String _age = '';
  String _email = '';
  String _username = '';
  String DOB = '';

  //String _uid='';
  String _password = '';
  String _profilepic = '';
  String vid;
  static const _timerDuration = 60;
  StreamController _timerStream = new StreamController<int>();
  Timer _resendCodeTimer;

  // double _maxScreenWidth;
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
    final dynamic _args = ModalRoute.of(context).settings.arguments;
    _name = _args['name'];
    _email = _args['email'];
    DOB = _args['DOB'];
    _age = _args['age'];
    _password = _args['password'];

    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mRed,
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
                                AppAssets.LITPIELOGO.name,
                            height: 100,
                          )),
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(25.0, 45.0, 25.0, 10.0),
                            child: Text(
                              "OTP sent on:- ".tr() +
                                  "\n" +
                                  widget.ext +
                                  widget.phone,
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

  verifyNumber(String mobile) {
    FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: widget.ext + mobile,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        try {
          FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password)
              .then((value) {
            auth.currentUser.linkWithCredential(credential);
            insertData();

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Gender()));
          });
        } on FirebaseAuthException catch (e) {
          Fluttertoast.showToast(
              msg: "Error, try again".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
          //return false;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        Fluttertoast.showToast(
            msg: "Verification failed".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        //return false;
      },
      codeSent: (String verificationId, int resendToken) {
        vid = verificationId;
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Code Sent"+verificationId)));
        Fluttertoast.showToast(
            msg: "OTP sent".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        //return false;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Timeout"+verificationId)));
        Fluttertoast.showToast(
            msg: "Timeout".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        // return false;
      },
    )
        .catchError((e) {
      print("phone auth error: $e");
      print("phone auth error code: ${e.code}");
      if (e.code == "invalid-verification-code") {
        Fluttertoast.showToast(
            msg: "Invalid OTP, Try Again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Something Went Wrong, Try Again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  Future<void> verifyPhone(String code) async {
    try {
      PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(verificationId: vid, smsCode: code);
      await auth.signInWithCredential(phoneAuthCredential).then((value) async {
        final credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser
            .linkWithCredential(credential)
            .catchError((e) {});
        insertData();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Gender()));
      }).catchError((err) {
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
    } catch (e) {
      print("Phone Auth Credential $e");
    }
  }

  insertData() {
    CreateAccountData _user = CreateAccountData(
      name: _name,
      email: _email,
      age: _age,
      username: _username,
      uid: auth.currentUser.uid,
      dOB: DOB,
      // countryCode: _countryCode,
      phone: widget.ext + widget.phone,
      profilepic: _profilepic,
    );

    /// _reference.add(_user.toMap());
    print('uid: ${auth.currentUser.uid}');
    _reference.doc(auth.currentUser.uid).set(_user.toMap());
  }
}
