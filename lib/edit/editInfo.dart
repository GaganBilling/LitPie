import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/common/common_swipe_widget.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/edit/socialLinks.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Theme/colors.dart';
import '../variables.dart';
import 'hobbies.dart';

class EditInfo extends StatefulWidget {
  @override
  EditInfoState createState() => EditInfoState();
}

class EditInfoState extends State<EditInfo>
    with SingleTickerProviderStateMixin {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController aboutmeController = TextEditingController();
  TextEditingController futureController = TextEditingController();
  TextEditingController hereForController = TextEditingController();
  TextEditingController talkToMeController = TextEditingController();

//  double _maxScreenWidth;
  CreateAccountData accountData;
  String bio;
  String future;
  String hereFor;
  String talkToMe;
  var showMe;

  List hobbies;

  Map<String, dynamic> editInfo = {};

  Future setUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(accountData.uid)
        .set({'editInfo': editInfo}, SetOptions(merge: true));
  }

  void initState() {
    super.initState();
    getAllData();
  }

  Future<CreateAccountData> getUser() async {
    final User user = auth.currentUser;
    return _reference
        .doc(user.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.data()));
  }

  @override
  void dispose() {
    super.dispose();
    if (editInfo.length > 0) {}
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
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
            leading: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
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
                    if (editInfo.length > 0) {
                      setUserData();
                    }
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => BottomNav(
                                  tabRedirectIndex: 1,
                                )));
                    // Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: "Updated".tr(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white,
                        fontSize: 16.0);
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Bio".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: TextFormField(
                      controller: aboutmeController,
                      maxLength: 501,
                      maxLines: null,
                      style: Theme.of(context).textTheme.subtitle1,
                      //  style: TextStyle(color: Colors.blueGrey,fontSize: 16,),
                      onChanged: (text) {
                        editInfo.addAll({'bio': text});
                      },
                      decoration: InputDecoration(
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
                        hintText: "A little bit about you.....".tr(),
                        hintStyle: TextStyle(
                            fontSize:
                                _screenWidth >= miniScreenWidth ? 17 : 15),
                      ),
                      buildCounter: (context,
                          {currentLength, isFocused, maxLength}) {
                        int utf8Length =
                            utf8.encode(aboutmeController.text).length;

                        return Container(
                          child: Text(
                            '$utf8Length/$maxLength',
                            style: Theme.of(context).textTheme.caption,
                            // style: TextStyle(color: Colors.blueGrey,fontSize: 17,fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      inputFormatters: [
                        _Utf8LengthLimitingTextInputFormatter(501),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Future plans".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: TextFormField(
                      controller: futureController,
                      maxLength: 501,
                      maxLines: null,
                      style: Theme.of(context).textTheme.subtitle1,
                      // style: TextStyle(color: Colors.blueGrey,fontSize: 16,),
                      onChanged: (text) {
                        editInfo.addAll({'future': text});
                      },
                      decoration: InputDecoration(
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
                        hintText: "Share your future plans.....".tr(),
                        hintStyle: TextStyle(
                            fontSize:
                                _screenWidth >= miniScreenWidth ? 17 : 15),
                      ),
                      buildCounter: (context,
                          {currentLength, isFocused, maxLength}) {
                        int utf8Length =
                            utf8.encode(futureController.text).length;

                        return Container(
                          child: Text(
                            '$utf8Length/$maxLength',
                            style: Theme.of(context).textTheme.caption,
                            // style: TextStyle(color: Colors.blueGrey,fontSize: 17,fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      inputFormatters: [
                        _Utf8LengthLimitingTextInputFormatter(501),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Here for".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: TextFormField(
                      controller: hereForController,
                      maxLength: 301,
                      maxLines: null,
                      style: Theme.of(context).textTheme.subtitle1,
                      // style: TextStyle(color: Colors.blueGrey,fontSize: 16,),
                      onChanged: (text) {
                        editInfo.addAll({'hereFor': text});
                      },
                      decoration: InputDecoration(
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
                        hintText: "What brings you here.....".tr(),
                        hintStyle: TextStyle(
                            fontSize:
                                _screenWidth >= miniScreenWidth ? 17 : 15),
                      ),
                      buildCounter: (context,
                          {currentLength, isFocused, maxLength}) {
                        int utf8Length =
                            utf8.encode(hereForController.text).length;

                        return Container(
                          child: Text(
                            '$utf8Length/$maxLength',
                            style: Theme.of(context).textTheme.caption,
                            // style: TextStyle(color: Colors.blueGrey,fontSize: 17,fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      inputFormatters: [
                        _Utf8LengthLimitingTextInputFormatter(301),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Talk to me only if".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: TextFormField(
                      controller: talkToMeController,
                      maxLength: 301,
                      maxLines: null,
                      style: Theme.of(context).textTheme.subtitle1,
                      // style: TextStyle(color: Colors.blueGrey,fontSize: 16,),
                      onChanged: (text) {
                        editInfo.addAll({'talkToMe': text});
                      },
                      decoration: InputDecoration(
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
                        hintText: "Share any pre-conditions.....".tr(),
                        hintStyle: TextStyle(
                            fontSize:
                                _screenWidth >= miniScreenWidth ? 17 : 15),
                      ),
                      buildCounter: (context,
                          {currentLength, isFocused, maxLength}) {
                        int utf8Length =
                            utf8.encode(talkToMeController.text).length;

                        return Container(
                          child: Text(
                            '$utf8Length/$maxLength',
                            style: Theme.of(context).textTheme.caption,
                            // style: TextStyle(color: Colors.blueGrey,fontSize: 17,fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      inputFormatters: [
                        _Utf8LengthLimitingTextInputFormatter(301),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "I am".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: lRed, width: 3.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(20.0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: lRed),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(20.0),
                            ),
                          ),
                          filled: true,
                          //hintStyle: TextStyle(),
                          //hintText: "Select Gender",
                          fillColor: Colors.transparent),
                      iconEnabledColor: mRed,
                      focusColor: mRed,
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            "Man".tr(),
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 18 : 16,
                                fontWeight: FontWeight.w400),
                          ),
                          value: "man",
                        ),
                        DropdownMenuItem(
                            child: Text(
                              "Woman".tr(),
                              style: TextStyle(
                                  fontSize:
                                      _screenWidth >= miniScreenWidth ? 18 : 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            value: "woman"),
                        DropdownMenuItem(
                            child: Text(
                              "Other".tr(),
                              style: TextStyle(
                                  fontSize:
                                      _screenWidth >= miniScreenWidth ? 18 : 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            value: "other"),
                      ],
                      onChanged: (val) {
                        editInfo.addAll({'userGender': val});
                        setState(() {
                          showMe = val;
                        });
                      },
                      value: showMe,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "My Interests".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(10.0, 5.0, 25.0, 5.0),
                        //margin: EdgeInsets.only(left: 70,right: 70),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          border: Border.all(
                            color: lRed,
                            width: 1,
                          ),
                        ),
                        child: hobbies != null && hobbies.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Hobbies(hobbies: hobbies)))
                                      .whenComplete(() {
                                    getAllData();
                                  });
                                },
                                child: Wrap(
                                  children: CommonSwipeWidget()
                                      .getWrapInterestList(hobbies),
                                ))
                            : GestureDetector(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Hobbies()))
                                .whenComplete(() {
                              getAllData();
                            });
                          },
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 12.0),
                                    child: Text(
                                      "Add what you love to do.....".tr(),
                                      style: TextStyle(
                                          fontSize: _screenWidth >= miniScreenWidth
                                              ? 17
                                              : 15),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                            )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Social links".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 25.0, 10.0),
                      //margin: EdgeInsets.only(left: 70,right: 70),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: lRed,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SocialLinks()));
                        },
                        child: Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Text(
                            "Add to promote your social links.....".tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 17 : 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getAllData() {
    getUser().then((value) {
      if (!mounted) return;
      setState(() {
        aboutmeController.text = value.editInfo['bio'];
        futureController.text = value.editInfo['future'];
        hereForController.text = value.editInfo['hereFor'];
        talkToMeController.text = value.editInfo['talkToMe'];

        bio = value.editInfo['bio'];
        future = value.editInfo['future'];
        hereFor = value.editInfo['hereFor'];
        talkToMe = value.editInfo['talkToMe'];

        accountData = value;
        showMe = value.editInfo['userGender'];
        hobbies = value.hobbies;
        print("hobbies " + hobbies.toString());
      });
    });
  }
}

class _Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  _Utf8LengthLimitingTextInputFormatter(this.maxLength)
      : assert(maxLength == null || maxLength == -1 || maxLength > 0);

  final int maxLength;

  static int bytesLength(String value) {
    return utf8.encode(value).length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength > 0 &&
        bytesLength(newValue.text) > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old value.
      if (bytesLength(oldValue.text) == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }

  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    var newValue = '';
    if (bytesLength(value.text) > maxLength) {
      var length = 0;

      value.text.characters.takeWhile((char) {
        var nbBytes = bytesLength(char);
        if (length + nbBytes <= maxLength) {
          newValue += char;
          length += nbBytes;
          return true;
        }
        return false;
      });
    }
    return TextEditingValue(
      text: newValue,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, newValue.length),
        extentOffset: min(value.selection.end, newValue.length),
      ),
      composing: TextRange.empty,
    );
  }
}
