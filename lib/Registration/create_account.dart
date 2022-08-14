import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/assets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Theme/colors.dart';
import '../variables.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  TextEditingController _nameController = new TextEditingController();

  TextEditingController _emailController = new TextEditingController();

  TextEditingController _phoneController = new TextEditingController();

  TextEditingController _passwordController = new TextEditingController();

  TextEditingController _confirmpasswordController =
      new TextEditingController();

  bool terms = false;

  String _age = '';

  String DOB = '';

  String phonecode = '';

  void _onCountryChange(CountryCode countryCode) {
    this.phonecode = countryCode.toString();
  }

  // double _maxScreenWidth;
  double _screenWidth;

  final auth = FirebaseAuth.instance;

  final _fs = FirebaseFirestore.instance;

  //double _screenSizeWidth ;

  @override
  Widget build(BuildContext context) {
    final dynamic _args = ModalRoute.of(context).settings.arguments;
    _age = _args['age'];
    DOB = _args['DOB'];

    final themeProvider = Provider.of<ThemeProvider>(context);

    _screenWidth = MediaQuery.of(context).size.width;
    return new GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: new Scaffold(
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
        key: _key,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width, //how to set it to max
            height: MediaQuery.of(context).size.height, //how to set it to max
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
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
                              child: TextFormField(
                                //inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))],
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
                                    hintText: "Name".tr()),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: TextFormField(
                                validator: _validateEmail,
                                controller: _emailController,
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
                                    hintText: "Email".tr()),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 15.0, 25.0, 10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: CountryCodePicker(
                                      // onInit: _onCountryChange,
                                      padding: EdgeInsets.zero,
                                      onChanged: _onCountryChange,
                                      alignLeft: true,
                                      showCountryOnly: true,
                                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                      // initialSelection: 'IT',
                                      favorite: ['+91', 'US'],
                                      textStyle: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? white
                                              : mRed),
                                      dialogBackgroundColor: Colors.blueGrey,
                                      dialogTextStyle: TextStyle(color: white),

                                      searchStyle: TextStyle(
                                        color: white,
                                        fontSize: 20,
                                        decorationColor: white,
                                        decoration: TextDecoration.underline,
                                      ),
                                      searchDecoration: InputDecoration(
                                          labelText: "Search".tr(),
                                          fillColor: white),

                                      //countryFilter: ['IT', 'FR'],
                                      // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                                      flagDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: TextFormField(
                                      validator: _validatePhone,
                                      controller: _phoneController,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                          errorStyle: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? white
                                                : black,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                              borderSide:
                                                  BorderSide(color: lRed)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                              borderSide: BorderSide(
                                                  color: mRed, width: 3)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                              borderSide:
                                                  BorderSide(color: mRed)),
                                          focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                              borderSide: BorderSide(
                                                  color: mRed, width: 3)),
                                          hintText: "Phone".tr()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: TextFormField(
                                obscureText: true,
                                validator: _validatePassword,
                                controller: _passwordController,
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
                                    hintText: "Password".tr()),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: TextFormField(
                                //obscureText: true,
                                validator: _validateConfirmPassword,
                                controller: _confirmpasswordController,
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
                                    hintText: "Confirm Password".tr()),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ListTile(
                                leading: Checkbox(
                                  activeColor: mRed,
                                  value: terms,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      terms = newValue;
                                    });
                                  },
                                ),
                                title: Row(
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: mRed,
                                        // padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 10.0)
                                      ),
                                      onPressed: () => _launchURL(
                                          "https://litpie.com/privacy-policy/"),
                                      child: Text(
                                        "Privacy Policy".tr(),
                                        // "Privacy Policy".tr(),
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: mRed,
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 16
                                                    : 14),
                                      ),
                                    ),
                                    Text(
                                      "&",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 16
                                                  : 14),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: mRed,
                                        //padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 10.0)
                                      ),
                                      onPressed: () => _launchURL(
                                          "https://litpie.com/terms-conditions/"),
                                      child: Text(
                                        "Terms of Use.".tr(),
                                        // "Privacy Policy".tr(),
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: mRed,
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 16
                                                    : 14),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: !terms
                                    ? Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                                        child: Text(
                                          "Accept".tr(),
                                          style: TextStyle(
                                              color: mRed, fontSize: 12),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
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
                                          builder: (context) => Login()));
                                },
                                child: Text(
                                  "Already have an Account? Log in.".tr(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 17
                                          : 15),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Tooltip(
                              message: "GET OTP".tr(),
                              preferBelow: false,
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      25.0, 15.0, 25.0, 10.0),
                                  child: ElevatedButton(
                                    child: Text("GET OTP".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 24
                                                    : 18,
                                            fontWeight: FontWeight.w700)),
                                    onPressed: () async {
                                      if (terms != false && terms != null) {
                                        if (_formKey.currentState.validate()) {
                                          //print('validation successful');
                                          final result = await createAccount();
                                          {
                                            if (result) {
                                              Map<String, dynamic> userinfo = {
                                                'name': _nameController.text,
                                                'email': _emailController.text,
                                                //'uid': FirebaseAuth.instance.currentUser.uid,
                                                'countryCode':
                                                    phonecode.toString(),
                                                'phone': _phoneController.text,
                                                'password':
                                                    _passwordController.text,
                                                'age': _age.toString(),
                                                'DOB': DOB,
                                              };

                                              Navigator.pushNamed(
                                                  context, '/OTPcreateaccount',
                                                  arguments: userinfo);
                                            }
                                          }
                                        }
                                      } else {
                                        // if(terms == false || terms == null){
                                        Fluttertoast.showToast(
                                            msg:
                                                "Accept the Privacy Policy & Terms of Use to continue"
                                                    .tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.blueGrey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        print('validation failed');
                                        FocusScope.of(context).unfocus();
                                      }
                                      // }
                                      return;
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: mRed,
                                      onPrimary: mYellow,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.7)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.blueGrey,
                                    padding: EdgeInsets.fromLTRB(
                                        25.0, 15.0, 25.0, 10.0)),
                                onPressed: () => _launchURL(
                                    "https://litpie.com/contact-us/"),
                                child: Text(
                                  "Contact us.".tr(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 17
                                          : 15),
                                ),
                              ),
                            ),
                          ],
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: "Something went wrong, Try again or visit LitPie website".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String _validateName(String value) {
    String pattern = r"^\s*[A-Za-z]{2,21}[^\n\d]+$";
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Name must be [a-zA-Z] only and minimum 3 letters".tr();
    }

    return null;
  }

  String _validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Invalid Email.".tr();
    }
    return null;
  }

  String _validatePhone(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{9,12}$)';
    RegExp regExp = new RegExp(pattern);

    if (value.length == 0) {
      return "Enter mobile number.".tr();
    } else if (!regExp.hasMatch(value)) {
      return "Enter valid mobile number.".tr();
    }
    return null;
  }

  String _validatePassword(String value) {
    String pattern = r'^(?=.*?[a-z]).{8,20}$';
    RegExp regExp = new RegExp(pattern);
    Pattern pattern2 = r'^[0-9a-zA-Z]';
    RegExp regExp2 = new RegExp(pattern2);
    Pattern pattern3 = r'^[a-zA-Z0-9]';
    RegExp regExp3 = new RegExp(pattern3);
    if (!regExp.hasMatch(value)) {
      return "Password is weak.".tr();
    }
    if (!regExp2.hasMatch(value)) {
      return "Password is weak, Must contain at least one Capital letter".tr();
    }
    if (!regExp3.hasMatch(value)) {
      return "Password is weak, Must contain at least one number(0-9)".tr();
    }

    return null;
  }

  String _validateConfirmPassword(String value) {
    if (value.isEmpty) return "Please enter a confirm password".tr();
    if (value != _passwordController.text) return "Password do not match.".tr();
    return null;
  }

  Future<bool> createAccount() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    var methods = await auth.fetchSignInMethodsForEmail(_emailController.text);
    if (methods.length > 0) {
      Fluttertoast.showToast(
          msg: "Email already exists!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }

    if (await phoneCheck(phonecode.toString() + _phoneController.text)) {
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
