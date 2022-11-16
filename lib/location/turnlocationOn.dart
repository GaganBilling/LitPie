import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/location/LocationProvider.dart';
import 'package:litpie/location/allowLocation.dart';
import 'package:litpie/main.dart';
import 'package:location/location.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as pHandler;
import 'package:provider/provider.dart';

import '../variables.dart';

class TurnLocationOn extends StatefulWidget {
  @override
  _TurnLocationOn createState() => new _TurnLocationOn();
}

class _TurnLocationOn extends State<TurnLocationOn> {
  Location location = Location();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  LocationProvider locationprovider;
  Map<String, dynamic> userData = {};
  bool _isLoading = false;
  Future setUserData(Map<String, dynamic> userData) async {
    final auth = FirebaseAuth.instance;
    await FirebaseFirestore.instance.collection("users").doc(auth.currentUser.uid).set(userData, SetOptions(merge: true));
  }

  _updateLocation() async {
    bool _serviceEnabled;
    pHandler.PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    _permissionGranted = await pHandler.Permission.location.status;
    print(_permissionGranted.isGranted);
    if (!_serviceEnabled || !_permissionGranted.isGranted) {
      _serviceEnabled = await location.requestService();
      _permissionGranted = await pHandler.Permission.location.request();

      if (!_serviceEnabled || !_permissionGranted.isGranted) {
        print("Please Turn On Location");

        Fluttertoast.showToast(
            msg: "Enable Location First!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        print("turn on 1");
        await pHandler.openAppSettings().then((v) {
          print("App Setting Closed");
          Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
        });
        print("turn on 12");
      } else {
        print("turn on lacation13");
        await _updateLocationData();
      }
    } else {
      print("turn on lacation2");
      await _updateLocationData();
    }
    print("turn on 11");
  }

  _updateLocationData() async {
    print("turn on lacation5");

    var currentLocation = await getLocationCoordinates();
    print("turn on lacation6");
   // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
    if (currentLocation == null) {
      //await getLocationCoordinates();
      print("turn on lacation32");

    } else {
      print("turn on lacation3");
      userData.addAll(
        {
          'location': {
            'latitude': currentLocation['latitude'],
            'longitude': currentLocation['longitude'],
            'address': currentLocation['PlaceName'],
          },
        },
      );
      print("turn on lacation4 ");
      setUserData(userData);
      Navigator.of(context).pushReplacementNamed('/Home');
    }
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    locationprovider = Provider.of<LocationProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                      child: Image.asset(
                    "assets/images/practicelogo.png",
                    height: 100,
                  )),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey.withOpacity(.2),
                        radius: _screenWidth >= miniScreenWidth ? 110 : 80,
                        child: Icon(Icons.location_on, color: Colors.white, size: _screenWidth >= miniScreenWidth ? 90 : 70),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: RichText(
                        text: TextSpan(
                          text: "Enable Location2".tr(),
                          style: TextStyle(
                            color: mRed,
                            fontSize: _screenWidth >= miniScreenWidth ? 40 : 30,
                          ),
                          children: [
                            TextSpan(
                                text: "\nYou'll need to provide a \nlocation\nin order to search users around you.".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blueGrey,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize: _screenWidth >= miniScreenWidth ? 18 : 16,
                                )),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )),
                  _isLoading
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: const CircularProgressIndicator(),
                  ) : SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
                      child: ElevatedButton(
                          child: Text("Allow Location2".tr(), style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 22 : 18, fontWeight: FontWeight.w600)),
                          onPressed: () async {
                            setState(()  {
                              _isLoading = true;
                            });
                            print("sdfks ");
                            await _updateLocation();
                            setState(()  {
                              _isLoading = false;
                            });
                           // Navigator.of(context).pushReplacementNamed('/Home');
                          },
                          style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              elevation: 5,
                              side: BorderSide(color: mRed, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
