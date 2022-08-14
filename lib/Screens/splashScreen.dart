import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 130,
                  //width: 200,
                  child: Image.asset("assets/images/practicelogo.png"),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: LinearProgressCustomBar(),
                )
              ],
            ),
          ),
        ));
  }
}
