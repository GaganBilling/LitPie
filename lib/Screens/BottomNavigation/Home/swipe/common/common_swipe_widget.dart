import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonSwipeWidget {
  Widget swipeHeaders(String headerText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Text(
          headerText.tr(),
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  List<Widget> getWrapInterestList(List hobbies) {
    List<Widget> widgetsList = [];
    if (hobbies.length > 0) {
      for (int i = 0; i < hobbies.length; i++) {
        widgetsList.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Text(
              hobbies[i].toString().tr(),
              style: TextStyle(
                color: white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                // color: man ? mRed : Colors.blueGrey
              ),
            ),
            decoration: BoxDecoration(
              color: mRed,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ));
      }
    } else {
      widgetsList.add(Container(
        child: Text("No hobbies".tr()),
      ));
    }
    return widgetsList;
  }

  getSocialLinkWidget(String asset, GestureTapCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Container(
            height: 50,
            width: 50,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  25,
                ),
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                )),
          ),
        ));
  }


  launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
        );
      } else {
        Fluttertoast.showToast(
            msg: "URL: $url",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("url error:- $e");
    }
  }
}
