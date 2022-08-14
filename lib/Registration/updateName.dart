import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class UpdateName extends StatefulWidget {
  @override
  _UpdateName createState() => _UpdateName();
}

class _UpdateName extends State<UpdateName> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  TextEditingController _nameController = TextEditingController();
  final auth = FirebaseAuth.instance;
  CreateAccountData accountData;
  Timestamp nameTimestamp;

  @override
  void initState() {
    super.initState();

    getUser().then((value) {
      if (!mounted) return;
      setState(() {
        accountData = value;
        nameTimestamp = value.nametimestamp;
      });
    });
  }

  Future<CreateAccountData> getUser() async {
    if (auth.currentUser != null) {
      final User user = auth.currentUser;
      return _reference
          .doc(user.uid)
          .get()
          .then((m) => CreateAccountData.fromDocument(m.data()));
    }
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;

    DateTime myDateTime = DateTime.parse(nameTimestamp != null
        ? nameTimestamp.toDate().toString()
        : DateTime(2021 - 1 - 1).toString());
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(myDateTime);
    final nameChangeDate = DateTime.parse(formattedDateTime);
    final todayDate = DateTime.now();
    final difference = todayDate.difference(nameChangeDate).inDays;

    bool validate = difference <= 30;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: mRed,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Update Name".tr(),
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: AbsorbPointer(
          absorbing: validate,
          child: Container(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                            child: TextFormField(
                              validator: _validateName,
                              controller: _nameController,
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
                                  hintText: "Enter New Name".tr()),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Tooltip(
                            message: "UPDATE NAME".tr(),
                            preferBelow: false,
                            child: SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                                child: ElevatedButton(
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: BouncingScrollPhysics(),
                                        child: Text("UPDATE NAME".tr(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 22
                                                    : 18,
                                                fontWeight: FontWeight.w600))),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        insertData();
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg: "Name updated!!".tr(),
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
                validate
                    ? Align(
                        alignment: Alignment.center,
                        child: InkWell(
                            child: Container(
                              color: Colors.blueGrey.withOpacity(0.5),
                              child: Dialog(
                                insetAnimationCurve: Curves.bounceInOut,
                                insetAnimationDuration: Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor:
                                    themeProvider.isDarkMode ? dRed : white,
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        .55,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: lRed,
                                                  radius: 30,
                                                ),
                                                Icon(
                                                  Icons.error_outline,
                                                  size: 60,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? dRed
                                                          : white,
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "You have updated your NAME recently,\n try after few days."
                                                  .tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.w700,
                                                  color: lRed,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 18
                                                      : 15),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ),
                            //chnage it
                            onTap: () {
                              // Navigator.pop(context);
                            }))
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _validateName(String value) {
    String pattern = r"^\s*[A-Za-z]{2,21}[^\n\d]+$";
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Name must be [a-zA-Z] only and minimum 3 letters".tr();
    }
    return null;
  }

  insertData() {
    _reference.doc(auth.currentUser.uid).set(
        {"name": _nameController.text, "Nametimestamp": DateTime.now()},
        SetOptions(merge: true)).then((_) {});
  }
}
