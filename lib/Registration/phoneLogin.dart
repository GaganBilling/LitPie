import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/common/appConfig.dart';
import 'package:litpie/common/appTextFormField.dart';
import 'package:litpie/common/assets.dart';
import 'package:provider/provider.dart';

import '../Theme/colors.dart';
import '../variables.dart';
import 'dateofBirth.dart';
import 'package:easy_localization/easy_localization.dart';

class PhoneLogin extends StatefulWidget {
  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _phoneController = new TextEditingController();

  String phonecode = '';

  void _onCountryChange(CountryCode countryCode) {
    this.phonecode = countryCode.toString();
  }

  double _screenWidth;

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
              height: MediaQuery.of(context).size.height, //how to set it to max
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: GestureDetector(
                      //     behavior: HitTestBehavior.translucent,
                      //     onTap: () {
                      //       Navigator.of(context).pop();
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 12.0, vertical: 12.0),
                      //       child: Icon(Icons.arrow_back),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          child: Image.asset(
                        AppAssets.LITPIELOGO.name,
                        height: 100,
                      )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 45.0, 25.0, 0.0),
                        child: CountryCodePicker(
                          // onInit: _onCountryChange,
                          padding: EdgeInsets.zero,
                          onChanged: _onCountryChange,
                          showCountryOnly: true,

                          favorite: ['+91', 'US'],
                          textStyle: TextStyle(
                              color: themeProvider.isDarkMode ? white : mRed),
                          dialogBackgroundColor: Colors.blueGrey,
                          dialogTextStyle: TextStyle(color: white),

                          searchStyle: TextStyle(
                            color: white,
                            fontSize: 16.0,
                            decorationColor: white,
                            decoration: TextDecoration.none,
                          ),
                          searchDecoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: AppConfig.search.tr(),
                              fillColor: white),

                          flagDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                              child: AppTextFormField(
                                hintText: "Phone Number",
                                textEditingController: _phoneController,
                                obscureValue: false,
                                textInputType: TextInputType.phone,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(height: 5),
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
                                              fontSize: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 22
                                                  : 18,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        getOTP(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: mRed,
                                          onPrimary: mYellow,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.7)))),
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
                                      padding: EdgeInsets.fromLTRB(
                                          25.0, 15.0, 25.0, 10.0)),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DateofBirth()));
                                  },
                                  child: Text(
                                    AppConfig.createAccountNewUser.tr(),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 17
                                                : 15),
                                  )),
                            ),
                          ],
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

  Future getOTP(BuildContext context) async {
    if (_phoneController.text.isEmpty) {
      Utils().showToast("Please enter phone number");
    } else if (!Utils().validatePhone(_phoneController.text)) {
      Utils().showToast("Please enter valid phone number");
    } else {
      Map<String, dynamic> userinfo = {
        'countryCode': phonecode,
        'phone': _phoneController.text,
      };
      Navigator.pushNamed(context, '/OTPphoneLogin', arguments: userinfo);
    }
  }
}
