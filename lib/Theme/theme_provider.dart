import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

class ThemeProvider extends ChangeNotifier {
  SharedPreferences prefs;

  ThemeMode thememode = ThemeMode.system;

  //Constructor
  ThemeProvider() {
    setTheme();
  }

  bool get isDarkMode {
    if (thememode == ThemeMode.dark) {
      return true;
    } else {
      return false;
    }
  }

  void setTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('DarkMode') == true) {
      thememode = ThemeMode.dark;
    } else {
      thememode = ThemeMode.light;
    }
  }

  Future<void> swapTheme() async {
    prefs = await SharedPreferences.getInstance();

    if (thememode == ThemeMode.dark) {
      thememode = ThemeMode.light;
      prefs.setBool('DarkMode', false);
    } else {
      thememode = ThemeMode.dark;
      prefs.setBool('DarkMode', true);
    }
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.black12,
      selectionHandleColor: white,
    ),
    scaffoldBackgroundColor: dRed,
    primaryColor: dRed,
    colorScheme: ColorScheme.dark(),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: Colors.green,
    ),
    textTheme:
        TextTheme(subtitle1: TextStyle(backgroundColor: Colors.transparent)),
  );

  static final lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Colors.black12,
      selectionHandleColor: black,
    ),
    scaffoldBackgroundColor: white,
    primaryColor: white,
    colorScheme: ColorScheme.light(),
    brightness: Brightness.light,
    textTheme:
        TextTheme(subtitle1: TextStyle(backgroundColor: Colors.transparent)),
  );
}
