import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Registration/emailLogin.dart';
import 'package:litpie/Registration/phoneLogin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/common/appConfig.dart';
import 'package:litpie/common/assets.dart';
import 'package:litpie/variables.dart';

import '../Theme/colors.dart';
import 'dateofBirth.dart';

class Login extends StatelessWidget {
  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width, //how to set it to max
          height: MediaQuery.of(context).size.height, //how to set it to max
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        child: Image.asset(
                      AppAssets.LITPIELOGO.name,
                      height: 100,
                    )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Tooltip(
                          message: AppConfig.loginEmail.tr(),
                          preferBelow: false,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 10.0),
                              child: OutlinedButton.icon(
                                  icon: Icon(Icons.mail_outline),
                                  label: Text(AppConfig.loginEmail.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 18
                                                  : 15)),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EmailLogin()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
                                      shadowColor: mRed,
                                      onPrimary: white,
                                      elevation: 0,
                                      side: BorderSide(
                                          color: Colors.blueGrey, width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.7)))),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Tooltip(
                          message: AppConfig.loginPhone.tr(),
                          preferBelow: false,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 10.0),
                              child: OutlinedButton.icon(
                                  icon: Icon(
                                    Icons.phone_outlined,
                                  ),
                                  label: Text(AppConfig.loginPhone.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 18
                                                  : 15)),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PhoneLogin()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
                                      shadowColor: Colors.transparent,
                                      onPrimary: white,
                                      elevation: 0,
                                      side: BorderSide(
                                          color: Colors.blueGrey, width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.7)))),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Tooltip(
                          message: AppConfig.createAccountNewUser.tr(),
                          preferBelow: false,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 10.0),
                              child: ElevatedButton(
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Text(
                                        AppConfig.createAccountNewUser.tr(),
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 18
                                                    : 15),
                                        textAlign: TextAlign.center,
                                      )),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DateofBirth()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
                                      shadowColor: Colors.transparent,
                                      onPrimary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                          color: Colors.blueGrey, width: 2),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.7)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.blueGrey,
                            padding:
                                EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0)),
                        onPressed: () {},
                        child: Column(
                          children: [
                            Text(
                              AppConfig.byLogging.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: _screenWidth >= miniScreenWidth
                                      ? 16
                                      : 14),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: mRed,
                                  ),
                                  onPressed: () => Utils()
                                      .launchURL(AppConfig.privacyPolicyUrl),
                                  child: Text(
                                    AppConfig.privacyPolicy.tr(),
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
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 16
                                          : 14),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: mRed,
                                    //padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 10.0)
                                  ),
                                  onPressed: () => Utils()
                                      .launchURL(AppConfig.termsConditionsUrl),
                                  child: Text(
                                    AppConfig.termsOfUse.tr(),
                                    style: TextStyle(
                                        color: mRed,
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 16
                                                : 14),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.blueGrey,
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0)),
                          onPressed: () =>
                              Utils().launchURL(AppConfig.contactUsUrl),
                          child: Text(
                            AppConfig.contactUs.tr() + ".",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 17 : 14),
                          )),
                    ),
                    SizedBox(
                      height: 25,
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
}
