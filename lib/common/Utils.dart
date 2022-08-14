import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  String convertToAgo(int timeStamp) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timeStamp);
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "Year ago".tr() : "Years ago".tr()}";
    if (diff.inDays > 30)
      "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "Month ago".tr() : "Months ago".tr()}";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "Week ago".tr() : "Weeks ago".tr()}";
    if (diff.inDays == 1) return "Yesterday".tr();
    if (diff.inDays > 1)
      return "${diff.inDays} ${diff.inDays == 1 ? "Day ago".tr() : "Days ago".tr()}";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "Hour ago".tr() : "Hours ago".tr()}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "Minute ago".tr() : "Minutes ago".tr()}";
    return "Just now".tr();
  }

  String convertToAgoAndDate(int timeStamp) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timeStamp);
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 15) return "${date.day}/${date.month}/${date.year}";
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "Year ago".tr() : "Years ago".tr()}";
    if (diff.inDays > 7 && diff.inDays < 15)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "Week ago".tr() : "Weeks ago".tr()}";
    if (diff.inDays == 1) return "Yesterday".tr();
    if (diff.inDays > 1 && diff.inDays < 15)
      return "${diff.inDays} ${diff.inDays == 1 ? "Day ago".tr() : "Days ago".tr()}";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "Hour ago".tr() : "Hours ago".tr()}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "Minute ago".tr() : "Minutes ago".tr()}";
    return "Just now".tr();
  }

  int findDays(int m2, int y2) {
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

  String dateOfBirthToAge({@required DateTime dobDate}) {
    int d, m, y;
    String days1 = "", month1 = "", year1 = "";
    String dy = DateFormat('EEEE').format(dobDate);
    print('day $dy');
    d = int.parse(DateFormat("dd").format(dobDate));
    m = int.parse(DateFormat("MM").format(dobDate));
    y = int.parse(DateFormat("yyyy").format(dobDate));
    int d1 = int.parse(DateFormat("dd").format(DateTime.now()));
    int m1 = int.parse(DateFormat("MM").format(DateTime.now()));
    int y1 = int.parse(DateFormat("yyyy").format(DateTime.now()));

    int day = Utils().findDays(m1, y1);
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

    String age = (y1 - y).toString();
    return age;
  }

  showToast(String msg) {
    return Fluttertoast.showToast(
        msg: msg.tr(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
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

  bool validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return true;
    }

    return false;
  }

  bool validatePhone(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return true;
    }
    return false;
  }
}
