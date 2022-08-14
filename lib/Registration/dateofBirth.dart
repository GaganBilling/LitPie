import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/appConfig.dart';
import 'package:litpie/common/assets.dart';
import 'package:provider/provider.dart';
import '../Theme/colors.dart';
import '../variables.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart';

class DateofBirth extends StatefulWidget {
  @override
  _BirthdateSate createState() => _BirthdateSate();
}

class _BirthdateSate extends State<DateofBirth> {
  TextEditingController _ageController = TextEditingController();

  int d, m, y;
  String days1 = "", month1 = "", year1 = "";
  int _age;
  String _message = "";
  double _screenWidth;

  void enterClub() {
    _age = int.parse(_ageController.text);

    setState(() {
      if (_age >= 18) {
        _message = "Welcome".tr();
        Map<String, dynamic> userinfo = {
          'age': _age.toString(),
          'DOB': d.toString() + "/" + m.toString() + "/" + y.toString(),
        };
        Navigator.pushNamed(context, '/CreateAccount', arguments: userinfo);
      } else {
        _message = "Ohh.. ho!! Your age is ".tr() +
            _ageController.text +
            ","
                    "\n"
                    "\n"
                    "must be 18 or above to use an app."
                .tr();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    _screenWidth = MediaQuery.of(context).size.width;

    String _pickedDate = (d != null) ? d.toString() : '';
    _pickedDate = (m != null) ? _pickedDate + "/" + m.toString() : _pickedDate;
    _pickedDate = (y != null) ? _pickedDate + "/" + y.toString() : _pickedDate;
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height, //how to set it to max
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
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
                      height: 30.0,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 80,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.calendar_today_rounded,
                              color: white,
                              size: 24,
                            ),
                            label: Text("Select your BirthDate".tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 20
                                        : 15,
                                    fontWeight: FontWeight.w400)),
                            onPressed: () {
                              f1();
                            },
                            style: ElevatedButton.styleFrom(
                                primary: mRed,
                                onPrimary: white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.7))),
                          ),
                        ),
                      ),
                    ),
                    (d == null && m == null && y == null)
                        ? Container()
                        : Text(
                            AppConfig.birthdayOn.tr() + _pickedDate,
                            style: TextStyle(
                                fontSize:
                                    _screenWidth >= miniScreenWidth ? 25 : 18,
                                color: mRed,
                                fontWeight: FontWeight.w500),
                          ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      _message,
                      style: TextStyle(
                          fontSize: _screenWidth >= miniScreenWidth ? 22 : 18,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    (d == null)
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 50),
                              child: Text(
                                AppConfig.alreadyHaveAccount.tr(),
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 17
                                        : 15,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 10.0,
                    ),
                    (d == null && m == null && y == null)
                        ? Container()
                        : SizedBox(
                            height: 50,
                          ),
                    (d == null && m == null && y == null)
                        ? Container()
                        : Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Tooltip(
                              message: AppConfig.confirm.tr(),
                              preferBelow: false,
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      30.0, 15.0, 30.0, 10.0),
                                  child: ElevatedButton(
                                      child: Text(AppConfig.confirm.tr(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 22
                                                  : 18,
                                              fontWeight: FontWeight.w600)),
                                      onPressed: () {
                                        enterClub();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: mRed,
                                          onPrimary: white,
                                          elevation: 5,
                                          side:
                                              BorderSide(color: mRed, width: 2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.7)))),
                                ),
                              ),
                            ),
                          ),
                    (d == null && m == null && y == null)
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              AppConfig.publicAgeMsg.tr(),
                              style: TextStyle(
                                  fontSize:
                                      _screenWidth >= miniScreenWidth ? 15 : 14,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
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

  Future f1() async {
    DateTime date1 = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1931),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    surface: lRed,
                    primary: white,
                  ),
                  dialogBackgroundColor: lRed,
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(primary: white))),
              child: child);
        });
    setState(() {
      if (date1 != null) {
        String dy = DateFormat('EEEE').format(date1);
        d = int.parse(DateFormat("dd").format(date1));
        m = int.parse(DateFormat("MM").format(date1));
        y = int.parse(DateFormat("yyyy").format(date1));
        int d1 = int.parse(DateFormat("dd").format(DateTime.now()));
        int m1 = int.parse(DateFormat("MM").format(DateTime.now()));
        int y1 = int.parse(DateFormat("yyyy").format(DateTime.now()));

        int day = finddays(m1, y1);
        if (d1 - d >= 0)
          days1 = (d1 - d).toString() + " days";
        else {
          days1 = (d1 + day - d).toString() + " days";
          m1 = m1 - 1;
        }
        if (m1 - m >= 0)
          month1 = (m1 - m).toString() + " months";
        else {
          month1 = (m1 + 12 - m).toString() + " months";
          y1 = y1 - 1;
        }
        year1 = (y1 - y).toString() + " years";

        _ageController.text = (y1 - y).toString();
      }
    });
  }

  int finddays(int m2, int y2) {
    int day2;
    if (m2 == 2 ||
        m2 == 3 ||
        m2 == 5 ||
        m2 == 7 ||
        m2 == 8 ||
        m2 == 10 ||
        m2 == 12)
      day2 = 31;
    else if (m2 == 4 || m2 == 6 || m2 == 9 || m2 == 11)
      day2 = 30;
    else {
      if (y2 % 4 == 0)
        day2 = 29;
      else
        day2 = 28;
    }
    return day2;
  }
}
