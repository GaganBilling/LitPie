import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/variables.dart';

class EmptyGlobalPost extends StatelessWidget {
  double screenWidth;

  EmptyGlobalPost(this.screenWidth);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: lRed,
                  radius: 60,
                  child: Icon(
                    Icons.poll_rounded,
                    size: 100,
                    color: white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "There's no new POST,\n it's time to plan or explore a DATE \n or WAVE to the people near by or \n create your own POST and \n have public opinion on it."
                    .tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Handlee',
                    fontWeight: FontWeight.w700,
                    color: lRed,
                    decoration: TextDecoration.none,
                    fontSize: screenWidth >= miniScreenWidth ? 25 : 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
