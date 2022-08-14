import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Registration/contactUs.dart';
import 'package:litpie/Registration/login.dart';
import 'package:litpie/Registration/updateEmail.dart';
import 'package:litpie/Registration/updateName.dart';
import 'package:litpie/Registration/updatePassword.dart';
import 'package:litpie/Registration/updatePhone.dart';
import 'package:litpie/Registration/updateUsername.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/Screens/freshStartScreen.dart';
import 'package:litpie/Screens/vaccinatedTag.dart';
import 'package:litpie/adminScreens/adminDrawerMenu.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/mobileAdsController.dart';
import 'package:litpie/controller/pushNotificationController.dart';
import 'package:litpie/edit/changeLanguage.dart';
import 'package:litpie/media/profilePicfullScreen.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../Theme/colors.dart';

class More extends StatefulWidget {
  final User currentUser;

  More({this.currentUser});

  @override
  _MoreState createState() => new _MoreState();
}

class _MoreState extends State<More> with SingleTickerProviderStateMixin {
  FirebaseController _firebaseController = FirebaseController();
  PushNotificationController _pushNotificationController =
      PushNotificationController();

  Map<String, dynamic> changeValues = {};

  //double _maxScreenWidth;
  var _showMe;
  RangeValues ageRange = RangeValues(18, 50);
  int distance;
  String phone, email, name, profilepic;
  int freeR;
  int paidR;
  SharedPreferences prefs;
  bool _isHidden = false;
  bool ADMIN = false;
  bool _themeMode = false;
  TextEditingController _passwordController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  CreateAccountData accountData;

  @override
  void initState() {
    super.initState();
    freeR = 15000;
    paidR = 15000;
    getUser().then((value) async {
      accountData = value;
      prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        if (value?.maxDistance != null) {
          if (value.maxDistance > freeR) {
            value.maxDistance = freeR.round();
            changeValues.addAll({'maximum_distance': freeR.round()});
          } else if (value.maxDistance >= paidR) {
            value.maxDistance = paidR.round();
            changeValues.addAll({'maximum_distance': paidR.round()});
          }
          if (_themeMode = value.themeMode == 'lightMode') {
            _themeMode = true;
          }
          if (_isHidden = value.isHidden == true) {
            _isHidden = true;
          }
          if (ADMIN = value.ADMIN == true) {
            ADMIN = true;
          }
          distance = value.maxDistance.round();
          setState(() {
            phone = value.phone;
            email = value.email;
            name = value.name;
          });
          profilepic = value.profilepic;
          accountData = value;
          _showMe = value.showGender;
          ageRange = RangeValues(double.parse(value.ageRange['min']),
              (double.parse(value.ageRange['max'])));
        } else {
        }
      });
    });
  }

  Future<CreateAccountData> getUser() async {
    CreateAccountData cUserData = await _firebaseController.currentUserData;
    return cUserData;
  }

  @override
  void dispose() {
    super.dispose();
    if (changeValues.length > 0) {
      updateData();
    }
  }

  Future updateData() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(accountData.uid)
        .set(changeValues, SetOptions(merge: true));
  }

  Future<String> deleteAccount() async {
    QuerySnapshot usersAllPlansQuery = await _firebaseController
        .userColReference
        .doc(accountData.uid)
        .collection(plansCollectionName)
        .get();
    try {
      String deleteUserResponse = await _firebaseController.deleteUser(
          email: FirebaseAuth.instance.currentUser.email,
          password: _passwordController.text);
      print(deleteUserResponse);
      if (deleteUserResponse == "success") {
        //Add Deleted Users Data to DeletedUser Collection
        await FirebaseFirestore.instance
            .collection(deletedUsersCollectionName)
            .doc(accountData.uid)
            .set({
          "uid": accountData.uid,
          "email": accountData.email,
          "phone": accountData.phone,
          "profilepic": accountData.profilepic,
          "deletedOn": Timestamp.now(),
        }).catchError((e) {
          print(e);
        }).then((newDeleted) async {
          await _firebaseController.userColReference
              .doc(accountData.uid)
              .update({
            "isDeleted": true,
            "isOnline": false,
            "email": "",
            "phone": "",
            "profilepic": "",
            "name": "User Deleted",
            "username": "",
          }).catchError((e) {
            print(e);
          }).then((value) async {
            //Account Deleted Successfully
            //
            //
            for (int i = 0; i < usersAllPlansQuery.docs.length; i++) {
              await usersAllPlansQuery.docs[i].reference.delete();
            }
          }).catchError((e) {
            print(e);
          });
        });
      }

      _passwordController.clear();

      return deleteUserResponse;
    } catch (e) {
      _passwordController.clear();
      return "failed";
    }
  }

  double _screenWidth;
  final _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldState,
        drawer: AdminDrawerSideMenu(),
        body: accountData != null
            ? Builder(builder: (context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: SafeArea(
                    child: ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          accountData?.ADMIN == true
                              ? ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Card(
                                      color: themeProvider.isDarkMode
                                          ? black
                                          : white,
                                      child: Padding(
                                          padding: EdgeInsets.all(15),
                                          // padding: EdgeInsets.only(left:20,right: 20),
                                          child: GestureDetector(
                                            onTap: () {
                                              Scaffold.of(context).openDrawer();
                                            },
                                            child: Center(
                                              child: Text(
                                                "ADMIN".toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: mRed,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(),
                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Card(
                                color: themeProvider.isDarkMode ? black : white,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  // padding: EdgeInsets.only(left:20,right: 20),
                                  child: (Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePicScreen()));
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.blueGrey,
                                                      offset: Offset(1, 2),
                                                      spreadRadius: 0,
                                                      blurRadius: 0)
                                                ],
                                                color: Colors.blueGrey,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  80,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  80,
                                                ),
                                                child: accountData != null
                                                    ? accountData.profilepic
                                                            .isNotEmpty
                                                        ? CachedNetworkImage(
                                                            height: 40,
                                                            width: 40,
                                                            fit: BoxFit.fill,
                                                            imageUrl:
                                                                accountData
                                                                    .profilepic,
                                                            useOldImageOnUrlChange:
                                                                true,
                                                            placeholder: (context,
                                                                    url) =>
                                                                CupertinoActivityIndicator(
                                                              radius: 1,
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .blueGrey,
                                                                  size: 1,
                                                                ),
                                                                Text(
                                                                  "Error".tr(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      fontSize:
                                                                          5),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              80,
                                                            ),
                                                            child: Container(
                                                              height: 35,
                                                              width: 35,
                                                              child: Center(
                                                                child: Image.asset(
                                                                    placeholderImage,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                          )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          80,
                                                        ),
                                                        child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          child: Center(
                                                            child: Image.asset(
                                                                placeholderImage,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        ),
                                                      ),
                                              )),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateName()));
                                        },
                                        child: Tooltip(
                                          message: accountData?.name != null
                                              ? "${accountData.name}"
                                              : "",
                                          preferBelow: false,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: _firebaseController
                                                    .userColReference
                                                    .where('uid',
                                                        isEqualTo:
                                                            accountData.uid)
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    // var userData = _firebaseController.userColReference.doc(accountData.uid).get();
                                                    var userName = snapshot
                                                        .data.docs[0]
                                                        .get('name');
                                                    return ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: _screenWidth >=
                                                                  miniScreenWidth
                                                              ? 220
                                                              : 180,
                                                        ),
                                                        child: Text(
                                                          "$userName"
                                                              .toUpperCase(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey,
                                                              fontSize:
                                                                  _screenWidth >=
                                                                          miniScreenWidth
                                                                      ? 17
                                                                      : 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ));
                                                  } else {
                                                    return Text("...");
                                                  }
                                                }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: accountData?.email != null
                                ? "${accountData.email}"
                                : "",
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Icon(
                                              Icons.email_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 220
                                                    : 180,
                                              ),
                                              child: Text(
                                                accountData?.email != null
                                                    ? "${accountData.email}"
                                                    : "",
                                                //style: TextStyle(fontSize: 18),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateEmail()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: accountData?.phone != null
                                ? "${accountData.phone}"
                                : "",
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Icon(
                                              Icons.phone_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                accountData?.phone != null
                                                    ? "${accountData.phone}"
                                                    : "",
                                                //style: TextStyle(fontSize: 18),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Updatephone()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          distance != null? Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color: themeProvider.isDarkMode ? black : white,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: ListTile(
                                  title: Text(
                                    "Maximum Distance".tr(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 16
                                                : 14,
                                        //color: mRed,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Text(
                                    distance >= 10000
                                        ? "World Wide".tr()
                                        : "$distance " + "Km.".tr(),
                                    style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 15
                                                : 13),
                                  ),
                                  subtitle: Slider(
                                      value: distance != null
                                          ? distance.toDouble()
                                          : 1.0,
                                      inactiveColor: Colors.blueGrey,
                                      min: 1.0,
                                      max: 15001,
                                      // divisions: 25,
                                      activeColor: mRed,
                                      onChanged: (val) {
                                        changeValues.addAll(
                                            {'maximum_distance': val.round()});
                                        setState(() {
                                          distance = val.round();
                                        });
                                      }),
                                ),
                              ),
                            ),
                          ):SizedBox.shrink(),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color: themeProvider.isDarkMode ? black : white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20.0, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Show me".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              _screenWidth >= miniScreenWidth
                                                  ? 16
                                                  : 14,
                                          // color: mRed,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    ListTile(
                                      title: DropdownButton(
                                        iconEnabledColor: mRed,
                                        iconDisabledColor: Colors.blueGrey,
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem(
                                            child: Text(
                                              "Men".tr(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 17
                                                      : 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            value: "man",
                                          ),
                                          DropdownMenuItem(
                                              child: Text(
                                                "Women".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              value: "woman"),
                                          DropdownMenuItem(
                                              child: Text(
                                                "Everyone".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              value: "everyone"),
                                        ],
                                        onChanged: (val) {
                                          changeValues.addAll({
                                            'showGender': val,
                                          });
                                          setState(() {
                                            _showMe = val;
                                          });
                                        },
                                        value: _showMe,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color: themeProvider.isDarkMode ? black : white,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: ListTile(
                                  title: Text(
                                    "Age Range".tr(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 16
                                                : 14,
                                        // color: mRed,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Text(
                                    ageRange != null
                                        ? "${ageRange.start.round()} - ${ageRange.end.round()}"
                                        : "invalid",
                                    style: TextStyle(
                                      fontSize: _screenWidth >= miniScreenWidth
                                          ? 15
                                          : 14,
                                    ),
                                  ),
                                  subtitle: RangeSlider(
                                      inactiveColor: Colors.blueGrey,
                                      values: ageRange,
                                      min: 18,
                                      max: 99,
                                      // divisions: 25,
                                      activeColor: mRed,
                                      labels: RangeLabels(
                                          '${ageRange != null ? ageRange.start.round() : "Invalid".tr()}',
                                          '${ageRange != null ? ageRange.end.round() : "Invalid".tr()}'),
                                      onChanged: (val) {
                                        // String minRange = val.start.truncate().toString();
                                        // String maxRange = val.end.truncate().toString();
                                        changeValues.addAll({
                                          'age_range': {
                                            'min': '${val.start.truncate()}',
                                            'max': '${val.end.truncate()}'
                                          }
                                        });
                                        setState(() {
                                          ageRange = val;
                                        });
                                      }),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: themeProvider.isDarkMode
                                ? "Dark Mode".tr()
                                : "Light Mode".tr(),
                            preferBelow: false,
                            child: Container(
                              child: ListTile(
                                title: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: SwitchListTile(
                                        title: themeProvider.isDarkMode
                                            ? Text(
                                                "Dark Mode".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 18),
                                              )
                                            : Text("Light Mode".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 18
                                                      : 15,
                                                )),
                                        secondary: themeProvider.isDarkMode
                                            ? Icon(Icons.nightlight_round,
                                                color: Colors.blueGrey)
                                            : Icon(Icons.wb_sunny,
                                                color: Colors.yellow),
                                        activeColor: Colors.blueGrey,
                                        inactiveThumbColor: mRed,
                                        inactiveTrackColor: dRed,
                                        value: themeProvider.isDarkMode,
                                        onChanged: (value) {
                                          final provider =
                                              Provider.of<ThemeProvider>(
                                                  context,
                                                  listen: false);
                                          provider.swapTheme();
                                          setState(() {
                                            _themeMode = value;
                                          });
                                          String themeMode = 'lightMode';
                                          if (value) {
                                            themeMode = 'darkMode';
                                          }
                                          // CreateAccountData(themeMode: themeMode ,);

                                          _firebaseController.userColReference
                                              .doc(_firebaseController
                                                  .currentFirebaseUser.uid)
                                              .update({
                                            "themeMode": themeMode,
                                          }).then((_) {
                                            print('Dark Mode: $value');
                                          });
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: _isHidden
                                ? "Profile Hidden".tr()
                                : " Profile Visible".tr(),
                            preferBelow: false,
                            child: Container(
                              child: ListTile(
                                title: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: SwitchListTile(
                                        title: _isHidden
                                            ? Text(
                                                "Profile Hidden".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 18),
                                              )
                                            : Text(" Profile Visible".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 18
                                                      : 15,
                                                )),
                                        secondary: _isHidden
                                            ? Icon(
                                                Icons.visibility_off_outlined,
                                                color: lRed)
                                            : Icon(Icons.visibility_outlined,
                                                color: Colors.green),
                                        activeColor: mRed,
                                        inactiveThumbColor: Colors.green,
                                        inactiveTrackColor: mBlack,
                                        value: _isHidden,
                                        onChanged: (value) {
                                          prefs.setBool('isHidden', value);
                                          setState(() {
                                            _isHidden = value;
                                          });
                                          bool userStatus = false;
                                          if (value) {
                                            userStatus = true;
                                          }

                                          // CreateAccountData(isHidden: userStatus ,);

                                          _firebaseController.userColReference
                                              .doc(_firebaseController
                                                  .currentFirebaseUser.uid)
                                              .update({
                                            "isHidden": userStatus,
                                          }).then((_) {
                                            print('Profile hidden: $value');
                                          });

                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BottomNav()));
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: accountData?.username != null
                                ? "${accountData.username}"
                                : "Pick Username".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(
                                              Icons.alternate_email_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: _firebaseController
                                                    .userColReference
                                                    .where('uid',
                                                        isEqualTo:
                                                            accountData.uid)
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    //   var userData = _firebaseController.userColReference.doc(accountData.uid).get();
                                                    var userRecord;
                                                    snapshot.data.docs
                                                        .forEach((element) {
                                                      if (element.id ==
                                                          accountData.uid)
                                                        userRecord = element
                                                            .get('username');
                                                    });
                                                    return ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 190,
                                                        ),
                                                        child: Text(
                                                          "$userRecord",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey,
                                                              fontSize:
                                                                  _screenWidth >=
                                                                          miniScreenWidth
                                                                      ? 17
                                                                      : 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ));
                                                  } else {
                                                    return ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 190,
                                                        ),
                                                        child: Text(
                                                            "Pick Username"
                                                                .tr(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis));
                                                  }
                                                }),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateUserName()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Manage Password".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(Icons.lock_rounded,
                                                color: mRed),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Manage Password".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdatePassword()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Change Language".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(Icons.language,
                                                color: mRed),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Change Language".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeLanguage()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Get Vaccinated tag".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child:
                                                Icon(Icons.label, color: mRed),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Get Vaccinated tag".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VaccinatedTagScreen()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Fresh Start".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(
                                              Icons.not_started_outlined,
                                              color: mRed,
                                              size: 28,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Fresh Start".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FreshStartScreen(
                                                      currentUserUID:
                                                          accountData.uid,
                                                    )));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Contact Us".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(
                                              Icons
                                                  .quick_contacts_mail_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Contact Us".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ContactUs()));
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Share LitPie with friends".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color:
                                      themeProvider.isDarkMode ? black : white,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    // padding: EdgeInsets.only(left:20,right: 20),
                                    child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Icon(
                                              Icons.share_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Share LitPie with friends"
                                                    .tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Share.share(
                                            'Checkout this amazing app now https://litpie.com/');
                                      },
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          SizedBox(
                            height: 10,
                          ),

                          Tooltip(
                            message: "Log Out".tr(),
                            preferBelow: false,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 90, right: 90),
                              height: 50,
                              child: ElevatedButton(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    child: Text("Log Out".tr(),
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 18
                                                    : 15,
                                            fontWeight: FontWeight.bold))),
                                onPressed: () async {
                                  _pushNotificationController.fcmUnSubscribe();
                                  await _firebaseController.userColReference
                                      .doc(_firebaseController
                                          .currentFirebaseUser.uid)
                                      .update({"isOnline": false}).whenComplete(
                                          () async {
                                    await Constants()
                                        .deleteDeviceToken()
                                        .then((value) async {
                                      await FirebaseFirestore.instance
                                          .terminate();
                                      await FirebaseDatabase.instance
                                          .setPersistenceEnabled(false);
                                      await _firebaseController.firebaseAuth
                                          .signOut()
                                          .whenComplete(() {
                                        //_firebaseMessaging.deleteInstanceID();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Login()));
                                      });
                                    }).catchError((err) {
                                      print("ERROR : $err");
                                    });

                                    // _ads.disable(_ad);; haa kro
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: mRed,
                                  onPrimary: white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.7)),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Guidelines".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  // padding: EdgeInsets.only(left:20,right: 20),
                                  child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.only(left:15),
                                          //   child: Icon(Icons.lock_rounded,color: mRed),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Guidelines".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _launchURL(
                                          "https://litpie.com/guidelines/"))),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Safety tips".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  // padding: EdgeInsets.only(left:20,right: 20),
                                  child: (GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.only(left:15),
                                          //   child: Icon(Icons.lock_rounded,color: mRed),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 190,
                                              ),
                                              child: Text(
                                                "Safety tips".tr(),
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 18),
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: _screenWidth >=
                                                            miniScreenWidth
                                                        ? 17
                                                        : 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _launchURL(
                                          "https://litpie.com/safety-tips/"))),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Privacy Policy".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  // padding: EdgeInsets.only(left:20,right: 20),
                                  child: (GestureDetector(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.only(left:15),
                                        //   child: Icon(Icons.lock_rounded,color: mRed),
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 190,
                                            ),
                                            child: Text(
                                              "Privacy Policy".tr(),
                                              overflow: TextOverflow.ellipsis,
                                              //style: TextStyle(fontSize: 18),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 17
                                                      : 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _launchURL(
                                        "https://litpie.com/privacy-policy/"),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),

                          Tooltip(
                            message: "Terms and Conditions".tr(),
                            preferBelow: false,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  // padding: EdgeInsets.only(left:20,right: 20),
                                  child: (GestureDetector(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.only(left:15),
                                        //   child: Icon(Icons.lock_rounded,color: mRed),
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 190,
                                            ),
                                            child: Text(
                                              "Terms and Conditions".tr(),
                                              overflow: TextOverflow.ellipsis,
                                              //style: TextStyle(fontSize: 18),
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 17
                                                      : 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _launchURL(
                                        "https://litpie.com/terms-conditions/"),
                                  )),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Tooltip(
                            message: "Delete Account".tr(),
                            preferBelow: false,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext buildContext) {
                                      return SimpleDialog(
                                        contentPadding: EdgeInsets.all(10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor:
                                            Colors.blueGrey.withOpacity(0.7),
                                        title: Text("Are You Sure?".tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Handlee',
                                              fontWeight: FontWeight.w700,
                                              color: white,
                                              decoration: TextDecoration.none,
                                              fontSize: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 25
                                                  : 18,
                                            )),
                                        children: [
                                          Text(
                                              "You can also Hide your Profile instead of deleting it and this action cannot be undone."
                                                  .tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Handlee',
                                                fontWeight: FontWeight.w700,
                                                color: white,
                                                decoration: TextDecoration.none,
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 18
                                                    : 15,
                                              )),
                                          SizedBox(
                                            height: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    15.0, 15.0, 15.0, 10.0),
                                                child: Form(
                                                  key: _formKey,
                                                  child: TextFormField(
                                                    obscureText: true,
                                                    validator:
                                                        _validatePassword,
                                                    controller:
                                                        _passwordController,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1,
                                                    decoration: InputDecoration(
                                                        errorStyle: TextStyle(
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? white
                                                              : black,
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20.0)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color:
                                                                        white)),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20.0)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: mRed,
                                                                    width: 3)),
                                                        errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(20.0)),
                                                            borderSide: BorderSide(color: mRed)),
                                                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0)), borderSide: BorderSide(color: mRed, width: 3)),
                                                        hintText: "Password".tr()),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                margin: EdgeInsets.only(
                                                    left: 50, right: 50),
                                                height: 50,
                                                child: ElevatedButton(
                                                  child: Text("CONFIRM".tr(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: _screenWidth >=
                                                                  miniScreenWidth
                                                              ? 18
                                                              : 15,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  onPressed: () async {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (ctx) {
                                                            return WillPopScope(
                                                              onWillPop:
                                                                  () async =>
                                                                      true,
                                                              child:
                                                                  AlertDialog(
                                                                backgroundColor: themeProvider
                                                                        .isDarkMode
                                                                    ? black
                                                                        .withOpacity(
                                                                            .5)
                                                                    : white
                                                                        .withOpacity(
                                                                            .5),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      "We will MISS YOU. Take care."
                                                                          .tr(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize: _screenWidth >= miniScreenWidth
                                                                              ? 24
                                                                              : 18,
                                                                          fontFamily:
                                                                              "Handlee"),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20.0,
                                                                    ),
                                                                    LinearProgressCustomBar(),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });

                                                      deleteAccount()
                                                          .then((value) {
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (timeStamp) {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });

                                                        print(
                                                            "Delete Acccount Value: $value");
                                                        if (value ==
                                                            "success") {
                                                          try {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Account Deleted Successfully!"
                                                                        .tr(),
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    3,
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueGrey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          } catch (e) {
                                                            print(e);
                                                          }

                                                          //Navigate try now
                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback(
                                                                  (timeStamp) {
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacement(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (ctx) =>
                                                                                Login()));
                                                          });
                                                        } else if (value ==
                                                            "wrong-password") {
                                                          try {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Wrong Password!"
                                                                        .tr(),
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    3,
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueGrey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                        } else {
                                                          try {
                                                            Fluttertoast
                                                                .showToast(
                                                                    msg: "Something Went Wrong, Try Again!"
                                                                        .tr(),
                                                                    //ye error aa jta hai
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .BOTTOM,
                                                                    timeInSecForIosWeb:
                                                                        3,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blueGrey,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0);
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                        }
                                                      });
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: mRed,
                                                    onPrimary: white,
                                                    // padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.7)),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                margin: EdgeInsets.only(
                                                    left: 50, right: 50),
                                                height: 50,
                                                child: ElevatedButton(
                                                  child: Text("Cancel".tr(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: _screenWidth >=
                                                                  miniScreenWidth
                                                              ? 18
                                                              : 15,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary:
                                                        themeProvider.isDarkMode
                                                            ? mBlack
                                                            : Colors.white,
                                                    onPrimary: Colors.blue[700],
                                                    // padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.7),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    });

                                // deleteAccount();
                                // navigator popo pehle kaha the. jaha mene coomment kiye the vo to delete account se yaha leke aye the aap
                                //ShowDialog
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(left: 90, right: 90),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                  border: Border.all(
                                    color: mRed,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Text(
                                        "Delete Account".tr(),
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 18
                                                    : 15,
                                            color: mRed,
                                            fontWeight: FontWeight.w600),
                                      )),
                                ),
                              ),
                            ),
                          ),

                          themeProvider.isDarkMode
                              ? Divider(
                                  color: Colors.grey,
                                )
                              : Container(),
                        ],
                      ).toList(),
                    ),
                  ),
                );
              })
            : Center(
                child: LinearProgressCustomBar(),
              ),
      ),
    );
  }

  _launchURL(String url) async {
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

  String _validatePassword(String value) {
    if (value.length == 0) {
      return "Enter Password.".tr();
    }
    return null;
  }
}
