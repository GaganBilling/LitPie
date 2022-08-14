import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Registration/contactUs.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class BlockUser extends StatelessWidget {
  double _screenWidth;
  // double _maxScreenWidth;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: lRed.withOpacity(.5),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                SizedBox(
                    child: Image.asset(
                  "assets/images/practicelogo.png",
                  height: 100,
                )),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Sorry, you can't access the application!!!!!".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Handlee',
                        fontWeight: FontWeight.w700,
                        //  color: lRed,
                        decoration: TextDecoration.none,
                        fontSize: _screenWidth >= miniScreenWidth ? 22 : 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "You're blocked by the LitPie Team and your profile will also not appear for other users."
                        .tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Handlee',
                        fontWeight: FontWeight.w700,
                        //color: lRed,
                        decoration: TextDecoration.none,
                        fontSize: _screenWidth >= miniScreenWidth ? 24 : 20),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        primary: themeProvider.isDarkMode ? white : black,
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0)),
                    onPressed: () {
//todo change contact us make it web contact link
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ContactUs()));
                    },
                    child: Text(
                      "Contact us for more info.".tr(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: _screenWidth >= miniScreenWidth ? 18 : 16,
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
}
