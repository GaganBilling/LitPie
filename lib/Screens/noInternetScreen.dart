import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: lRed,
                radius: 80,
                child: Icon(
                  (CupertinoIcons.wifi_slash),
                  size: 120,
                  color: white,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "No Internet".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Handlee',
                fontWeight: FontWeight.w700,
                color: lRed,
                decoration: TextDecoration.none,
                fontSize: 35),
          ),
        ],
      ),
    ));
  }
}
