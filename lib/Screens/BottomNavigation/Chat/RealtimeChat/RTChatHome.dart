import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:litpie/Screens/BottomNavigation/Chat/RealtimeChat/RTChatRecentChats.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class RTChatHomeScreen extends StatefulWidget {
  final CreateAccountData currentUser;

  RTChatHomeScreen(this.currentUser);

  @override
  _RTChatHomeScreen createState() => _RTChatHomeScreen();
}

class _RTChatHomeScreen extends State<RTChatHomeScreen> {
  @override
  void initState() {
    super.initState();
    FlutterAppBadger.removeBadge();
  }

  //double _maxScreenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: mRed,
        title: Text(
          "Messages".tr(),
          style: TextStyle(
            // color: white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), topRight: Radius.circular(0)),
          color: themeProvider.isDarkMode ? dRed : white,
        ),
        child: RTChatRecentChats(widget.currentUser),
      ),
    );
  }
}
