import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class Updatephone extends StatefulWidget {
  @override
  _Updatephone createState() => _Updatephone();
}

class _Updatephone extends State<Updatephone> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  TextEditingController _phoneController = TextEditingController();
  String phonecode = '';

  void _onCountryChange(CountryCode countryCode) {
    this.phonecode = countryCode.toString();
  }

  final _fs = FirebaseFirestore.instance;

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // _maxScreenWidth = (MediaQuery.of(context).size.width <= 500) ? MediaQuery.of(context).size.width : 500;
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mRed,
          centerTitle: true,
          title: Text(
            "Update Phone".tr(),
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
                        child: CountryCodePicker(
                          // onInit: _onCountryChange,
                          padding: EdgeInsets.zero,
                          onChanged: _onCountryChange,
                          // alignLeft: true,
                          showCountryOnly: true,
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          // initialSelection: 'IT',
                          favorite: ['+91', 'US'],
                          textStyle: TextStyle(
                              color: themeProvider.isDarkMode ? white : mRed),
                          dialogBackgroundColor: Colors.blueGrey,
                          dialogTextStyle: TextStyle(color: white),

                          searchStyle: TextStyle(
                            color: white,
                            fontSize: 20,
                            decorationColor: white,
                            decoration: TextDecoration.underline,
                          ),
                          searchDecoration: InputDecoration(
                              labelText: "Search".tr(), fillColor: white),

                          //countryFilter: ['IT', 'FR'],
                          // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                          flagDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: TextFormField(
                        validator: _validatePhone,
                        controller: _phoneController,
                        style: Theme.of(context).textTheme.subtitle1,
                        keyboardType: TextInputType.phone,
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
                            hintText: "Phone Number".tr()),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Tooltip(
                      message: "GET OTP".tr(),
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
                                  child: Text("GET OTP".tr(),
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
                                  final result = await createAccount();
                                  {
                                    if (result) {
                                      Map<String, dynamic> userinfo = {
                                        'countryCode': phonecode,
                                        'phone': _phoneController.text,
                                      };
                                      Navigator.pushNamed(
                                          context, '/OTPupdatephone',
                                          arguments: userinfo);
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
        ),
      ),
    );
  }

  String _validatePhone(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{9,12}$)';
    RegExp regExp = new RegExp(pattern);

    if (value.length == 0) {
      return "Enter phone number.".tr();
    } else if (!regExp.hasMatch(value)) {
      return "Enter a valid phone number.".tr();
    }
    return null;
  }

  Future<bool> createAccount() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    if (await phoneCheck(phonecode + _phoneController.text)) {
      //"Mobile already exists";
      Fluttertoast.showToast(
          msg: "Phone Number already linked!!".tr(),
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

  Future<bool> phoneCheck(String mobile) async {
    final snapshot =
        await _fs.collection('users').where('phone', isEqualTo: mobile).get();
    if (snapshot.size == 0) {
      return false;
    }
    return true;
  }
}
