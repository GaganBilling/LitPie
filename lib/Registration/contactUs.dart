import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/common/assets.dart';
import 'package:litpie/constants.dart';
import '../Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class ContactUs extends StatelessWidget {
  TextEditingController _utf8TextController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  // double _maxScreenWidth;
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
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
            "Contact us".tr(),
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height, //how to set it to max
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: TextFormField(
                            validator: _validateEmail,
                            controller: _emailController,
                            style: Theme.of(context).textTheme.subtitle1,
                            decoration: InputDecoration(
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
                                hintText: "Enter your Email".tr()),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: TextFormField(
                            validator: _validateMessage,
                            controller: _utf8TextController,
                            maxLength: 1001,
                            maxLines: null,
                            style: Theme.of(context).textTheme.subtitle1,
                            decoration: InputDecoration(
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
                                hintText: "Message".tr()),
                            buildCounter: (context,
                                {currentLength, isFocused, maxLength}) {
                              int utf8Length =
                                  utf8.encode(_utf8TextController.text).length;

                              return Container(
                                child: Text(
                                  '$utf8Length/$maxLength',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              );
                            },
                            inputFormatters: [
                              Utf8LengthLimitingTextInputFormatter(1001),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Tooltip(
                          message: "SUBMIT".tr(),
                          preferBelow: false,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: ElevatedButton(
                                  child: Text("SUBMIT".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 22
                                                  : 18,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      insertData();
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(
                                          msg: "Message sent!!".tr(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.blueGrey,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
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

  String _validateMessage(String value) {
    {
      if (value == null || value.isEmpty || value.length < 10) {
        return "Must be [a-z] only and minimum 10 letters".tr();
      }
      return null;
    }
  }

  insertData() {
    String id = FirebaseFirestore.instance.collection("ContactUs").doc().id;
    try {
      FirebaseFirestore.instance.collection("ContactUs").doc(id).set({
        'contacted_by': _emailController.text,
        'message': _utf8TextController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': FirebaseAuth.instance.currentUser.uid,
        'isRead': false,
        'docID': id,
      }).then((value) {
        FirebaseFirestore.instance.collection("ContactUs").doc("count").update({
          "isRead": false,
          "new": FieldValue.increment(1),
          "total": FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('error in contacting $e');
    }
  }
}
