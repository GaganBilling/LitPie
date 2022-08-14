import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/assets.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class VaccinatedTagScreen extends StatefulWidget {
  @override
  _VaccinatedTagScreenState createState() => _VaccinatedTagScreenState();
}

class _VaccinatedTagScreenState extends State<VaccinatedTagScreen> {
  // double _maxScreenWidth;

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool _isVaccinated;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    getUser().then((value) async {
      prefs = await SharedPreferences.getInstance();
      _isVaccinated =
          prefs.getBool("isVaccinated") ?? value.isVaccinated ?? false;
      setState(() {
        //working..
      });
    });
  }

  Future<CreateAccountData> getUser() async {
    if (auth.currentUser != null) {
      final User user = auth.currentUser;
      return _reference
          .doc(user.uid)
          .get()
          .then((m) => CreateAccountData.fromDocument(m.data()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mRed,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              SizedBox(
                  child: Image.asset(
                AppAssets.LITPIELOGO.name,
                height: 100,
              )),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Display { I'am Vaccinated } tag on your profile now to let other users know your status. It is self-reported and not independently verified or guaranteed by LITPIE."
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontWeight: FontWeight.w700,
                      color: lRed,
                      decoration: TextDecoration.none,
                      fontSize: 24),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              if (_isVaccinated != null)
                ListTile(
                  title: Card(
                    color: themeProvider.isDarkMode ? mBlack : white,
                    child: Padding(
                      padding: EdgeInsets.only(left: 0, right: 0),
                      child: SwitchListTile(
                          title: _isVaccinated
                              ? Tooltip(
                                  message: "Tag displayed on my profile".tr(),
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Text(
                                        "Tag displayed on my profile".tr(),
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 18),
                                      )))
                              : Tooltip(
                                  message: "Display tag on your profile".tr(),
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Text(
                                          "Display tag on your profile".tr(),
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 18)))),
                          //secondary: _isVaccinated?
                          //Icon(Icons.visibility_off_outlined,color:lRed ):
                          //Icon(Icons.visibility_outlined,color: Colors.green ),
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.orange,
                          inactiveTrackColor: black,
                          value: _isVaccinated,
                          onChanged: (value) {
                            prefs.setBool('isVaccinated', value);
                            setState(() {
                              _isVaccinated = value;
                            });
                            bool userStatus = false;
                            if (value) {
                              userStatus = true;
                            }

                            _reference.doc(auth.currentUser.uid).update({
                              "isVaccinated": userStatus,
                            }).then((_) {
                              print('User Vaccinated: $value');
                            });
                          }),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
