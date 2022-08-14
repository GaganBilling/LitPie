import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class UpdateUserName extends StatefulWidget {
  @override
  _UpdateUserName createState() => _UpdateUserName();
}

class _UpdateUserName extends State<UpdateUserName> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  TextEditingController _nameController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final _fs = FirebaseFirestore.instance;
  CreateAccountData accountData;

  @override
  void initState() {
    super.initState();

    getUser().then((value) {
      if (!mounted) return;
      setState(() {
        accountData = value;
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: mRed,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Update UserName".tr(),
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
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
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-z0-9_.]"))
                              ],
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
                                  hintText: "Enter UserName".tr()),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Tooltip(
                            message: "UPDATE USERNAME".tr(),
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
                                      child: Text("UPDATE USERNAME".tr(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 22
                                                  : 18,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        print('validation successful');
                                        final result = await createAccount();
                                        {
                                          if (result) {
                                            insertData();
                                            Fluttertoast.showToast(
                                                msg: "UserName updated!!".tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            Navigator.pop(context);
                                          }
                                        }
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _validateName(String value) {
    String pattern = r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{4,29}$';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "UserName must be [a-z/0-9/_] only and min. 4(a-z) letters".tr();
    }
    return null;
  }

  insertData() {
    _reference.doc(auth.currentUser.uid).set({
      "username": _nameController.text,
    }, SetOptions(merge: true)).then((_) {});
  }

  Future<bool> createAccount() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    if (await usernameCheck(_nameController.text)) {
      Fluttertoast.showToast(
          msg: "Oops!! UserName taken.".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }

    return true;
  }

  Future<bool> usernameCheck(String username) async {
    final snapshot = await _fs
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (snapshot.size == 0) {
      return false;
    }

    return true;
  }
}
