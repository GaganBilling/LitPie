import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';

class LinearProgressCustomBar extends StatefulWidget {
  @override
  _ProgressbarState createState() => new _ProgressbarState();
}

class _ProgressbarState extends State<LinearProgressCustomBar>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Color> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(seconds: 1),
        reverseDuration: Duration(seconds: 1),
        vsync: this,
        value: 1.0);
    animation = controller.drive(ColorTween(begin: mYellow, end: mRed));
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 5,
      child: LinearProgressIndicator(
        valueColor: animation,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
