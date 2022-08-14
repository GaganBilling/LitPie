import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeLanguage extends StatefulWidget {
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  //double _maxScreenWidth;

  bool english = false;
  bool french = false;
  bool spanish = false;
  bool german = false;
  bool rusian = false;
  bool italian = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    setLanguage();
  }

  void setLanguage({String languageCode}) async {
    prefs = await SharedPreferences.getInstance();
    String langCode = languageCode;
    if (langCode == null) {
      langCode = prefs.getString("languageCode");
    } else {
      prefs.setString("languageCode", languageCode);
    }

    switch (langCode) {
      case 'en':
        {
          if (EasyLocalization.of(context).locale != Locale('en', 'US'))
            EasyLocalization.of(context).setLocale(Locale('en', 'US'));

          setState(() {
            english = true;
            french = false;
            spanish = false;
            german = false;
            italian = false;
            rusian = false;
          });
        }
        break;
      case 'fr':
        {
          if (EasyLocalization.of(context).locale != Locale('fr', 'CA'))
            EasyLocalization.of(context).setLocale(Locale('fr', 'CA'));

          setState(() {
            english = false;
            french = true;
            spanish = false;
            german = false;
            italian = false;
            rusian = false;
          });
        }
        break;
      case 'de':
        {
          if (EasyLocalization.of(context).locale != Locale('de', 'DE'))
            EasyLocalization.of(context).setLocale(Locale('de', 'DE'));

          setState(() {
            english = false;
            french = false;
            spanish = false;
            german = true;
            italian = false;
            rusian = false;
          });
        }
        break;
      case 'es':
        {
          if (EasyLocalization.of(context).locale != Locale('es', 'ES'))
            EasyLocalization.of(context).setLocale(Locale('es', 'ES'));

          setState(() {
            english = false;
            french = false;
            spanish = true;
            german = false;
            italian = false;
            rusian = false;
          });
        }
        break;
      case 'it':
        {
          if (EasyLocalization.of(context).locale != Locale('it', 'IT'))
            EasyLocalization.of(context).setLocale(Locale('it', 'IT'));

          setState(() {
            english = false;
            french = false;
            spanish = false;
            german = false;
            italian = true;
            rusian = false;
          });
        }
        break;
      case 'ru':
        {
          if (EasyLocalization.of(context).locale != Locale('ru', 'RU'))
            EasyLocalization.of(context).setLocale(Locale('ru', 'RU'));

          setState(() {
            english = false;
            french = false;
            spanish = false;
            german = false;
            italian = false;
            rusian = true;
          });
        }
        break;
      default:
        {
          if (EasyLocalization.of(context).locale != Locale('en', 'US'))
            EasyLocalization.of(context).setLocale(Locale('en', 'US'));
          setState(() {
            english = true;
            french = false;
            spanish = false;
            german = false;
            italian = false;
            rusian = false;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: mRed,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Change Language".tr(),
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    "Translation here may not be 100% accurate, suggestions are welcome."
                        .tr(),
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "English",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ),
                          Spacer(),
                          if (english)
                            buildAcceptButton(title: "English", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = true;
                          french = false;
                          spanish = false;
                          german = false;
                          italian = false;
                          rusian = false;
                          setLanguage(languageCode: 'en');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: english ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "Français",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ).tr(),
                          Spacer(),
                          if (french)
                            buildAcceptButton(title: "French", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = false;
                          french = true;
                          spanish = false;
                          german = false;
                          italian = false;
                          rusian = false;
                          setLanguage(languageCode: 'fr');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: french ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "Deutsch",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ).tr(),
                          Spacer(),
                          if (german)
                            buildAcceptButton(title: "German", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = false;
                          french = false;
                          spanish = false;
                          german = true;
                          italian = false;
                          rusian = false;
                          setLanguage(languageCode: 'de');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: german ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "Italiano",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ).tr(),
                          Spacer(),
                          if (italian)
                            buildAcceptButton(title: "Italian", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = false;
                          french = false;
                          spanish = false;
                          german = false;
                          italian = true;
                          rusian = false;
                          setLanguage(languageCode: 'it');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: italian ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "русский",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ).tr(),
                          Spacer(),
                          if (rusian)
                            buildAcceptButton(title: "Russian", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = false;
                          french = false;
                          spanish = false;
                          german = false;
                          italian = false;
                          rusian = true;
                          setLanguage(languageCode: 'ru');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: rusian ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Text(
                            "Española",
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500,
                              // color: man ? mRed : Colors.blueGrey
                            ),
                          ).tr(),
                          Spacer(),
                          if (spanish)
                            buildAcceptButton(title: "Spanish", onTap: null),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          english = false;
                          french = false;
                          spanish = true;
                          german = false;
                          italian = false;
                          rusian = false;
                          setLanguage(languageCode: 'es');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: spanish ? mRed : Colors.blueGrey,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
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

Widget buildAcceptButton(
    {@required String title, @required VoidCallback onTap}) {
  return Container(
    constraints: BoxConstraints(),
    child: Wrap(
      children: [
        InkWell(
          onTap: onTap,
          child: Column(
            children: [
              // SizedBox(height: 10,),
              SizedBox(
                  height: 30,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  )
                  //     themeProvider.isDarkMode?Image.asset("assets/images/handShakeDark.png")
                  //         :Image.asset("assets/images/handShakeLight.png")
                  ),
              Text(title),
            ],
          ),
        ),
      ],
    ),
  );
}
