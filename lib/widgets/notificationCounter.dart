import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';

class NotificationCounter extends StatelessWidget {
  final Widget icon;
  final int counter;

  NotificationCounter({this.icon, this.counter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        icon,
        new Positioned(
          right: 0,
          top: 0,
          child: new Container(
            padding: EdgeInsets.all(5),
            decoration: new BoxDecoration(
              color: mRed,
              shape: BoxShape.circle,
            ),
            child: new Text(
              counter > 99 ? "99+": "$counter",
              style: new TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
              //
            ),
          ),
        )
      ],
    );
  }
}
