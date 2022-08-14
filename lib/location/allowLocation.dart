import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geocoder2/geocoder2.dart';
//import 'package:geocoder/geocoder.dart';
import 'package:litpie/Screens/WelcomeScreen.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:location/location.dart' as loc;
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class AllowLocation extends StatefulWidget {
  @override
  AllowLocationState createState() => new AllowLocationState();
}

class AllowLocationState extends State<AllowLocation> {
  Map<String, dynamic> userData = {};

  Future setUserData(Map<String, dynamic> userData) async {
    final auth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .set(userData, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .collection('R')
        .doc('count')
        .set({
      'Rosetimestamp': DateTime(2021 - 1 - 1),
      "isRead": true,
      "new": 0,
      "roseColl": 13,
      "roseRec": 0,
    }, SetOptions(merge: true));
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: SingleChildScrollView(
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
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: _screenWidth >= miniScreenWidth ? 90 : 70,
                        ),
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
                          text: "Enable Location".tr(),
                          style: TextStyle(
                              color: mRed,
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 40 : 30),
                          children: [
                            TextSpan(
                                text:
                                    "\nYou'll need to provide a \nlocation\nin order to search users around you."
                                        .tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blueGrey,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize:
                                      _screenWidth >= miniScreenWidth ? 18 : 16,
                                )),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
                      child: ElevatedButton(
                          child: Text("Allow Location".tr(),
                              style: TextStyle(
                                  fontSize:
                                      _screenWidth >= miniScreenWidth ? 22 : 18,
                                  fontWeight: FontWeight.w600)),
                          onPressed: () async {
                            var currentLocation =
                                await getLocationCoordinates();

                            if (currentLocation != null) {
                              userData.addAll(
                                {
                                  'location': {
                                    'latitude': currentLocation['latitude'],
                                    'longitude': currentLocation['longitude'],
                                    'address': currentLocation['PlaceName'],
                                  },
                                  'maximum_distance': 500,
                                  'age_range': {
                                    'min': "18",
                                    'max': "50",
                                  },
                                  'socioInfo': {},
                                  'Nametimestamp': DateTime(2021 - 1 - 1), //
                                  'themeMode': 'lightMode',
                                  'username': 'Pick Username',
                                  'isBlocked': false,
                                  'isHidden': false,
                                  'isOnline': false,
                                  'isDeleted': false,
                                  "accountCreatedOn": Timestamp.now(), //
                                  "termsAccepted": true, //
                                  "termsAcceptedOn": Timestamp.now(), //
                                  "lastLogin": Timestamp.now(),
                                },
                              );
                              showWelcomDialog(context);
                              setUserData(userData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: mRed,
                              onPrimary: white,
                              elevation: 5,
                              side: BorderSide(color: mRed, width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7)))),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  //try to reopen emulator..
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future showWelcomDialog(context) async {
  showDialog(
      context: context,
      builder: (_) {
        Future.delayed(Duration(seconds: 1), () async {
          Navigator.pop(context);
          await Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Welcome()));
        });
        return Center(
          child: Container(
            width: 150.0,
            height: 100.0,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/auth/verified.jpg",
                  height: 60,
                  color: mRed,
                  colorBlendMode: BlendMode.color,
                ),
                Text(
                  "You'r in".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      color: mRed,
                      fontSize: 20),
                )
              ],
            ),
          ),
        );
      });
}


Future<Map> getLocationCoordinates() async {
  loc.Location location = loc.Location();
  try {
    await location.serviceEnabled().then((value) async {
      if (!value) {
        await location.requestService();
      }
    });
    var coordinates;
    try {
      //coordinates = await location.getLocation();
      coordinates = await await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print("Error: $e");
    }
    return await getCurrentLocation(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );
  } catch (e) {
    print(e);
    return null;
  }
}

// Future<Map> getLocationCoordinates() async {
//   loc.Location location = loc.Location();
//   try {
//     await location.serviceEnabled().then((value) async {
//       if (!value) {
//         await location.requestService();
//       }
//     });
//     print("coordinates");
//     var coordinates;
//     try {
//       coordinates = await location.getLocation();
//     } catch (e) {
//       print("Error: $e");
//     }
//     print(coordinates);
//     return await coordinatesToAddress(
//       latitude: coordinates.latitude,
//       longitude: coordinates.longitude,
//     );
//   } catch (e) {
//     print(e);
//     return null;
//   }
// }

//geolocater package
Future getCurrentLocation({latitude, longitude}) async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  try {
    Map<String, dynamic> obj = {};
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    String currentAddress = "${place.locality ?? ''}, ${place.country ?? ''}.";

    print(currentAddress);
    obj['PlaceName'] = currentAddress;
    obj['latitude'] = position.latitude;
    obj['longitude'] = position.longitude;

//     return obj;
  } catch (aa) {
    print("Allow location $aa");
  }
}

//geocoder2 package
// Future coordinatesToAdressNew({latitude, longitude}) async {
//   try {
//     Map<String, dynamic> obj = {};
//     GeoData data = await Geocoder2.getDataFromCoordinates(
//         latitude: latitude,
//         longitude: longitude,
//         googleMapApiKey: "GOOGLE_MAP_API_KEY");
//     String address = data.address;
//     String city = data.city;
//     String country = data.country;
//     String latitude1 = data.latitude.toString();
//     String longitude2 = data.longitude.toString();
//
//     print(obj);
//     obj['PlaceName'] = address;
//     obj['latitude'] = latitude1;
//     obj['longitude'] = longitude2;
//     return obj;
//   } catch (one) {
//     print("In Allow location error $one");
//
//     return null;
//   }
// }

//geocoder package
// Future coordinatesToAddress({latitude, longitude}) async {
//
//   try {
//     Map<String, dynamic> obj = {};
//     final coordinates = Coordinates(latitude, longitude);
//     List<Address> result =
//         await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     String currentAddress =
//         "${result.first.locality ?? ''}, ${result.first.countryName ?? ''}.";
//
//     print(currentAddress);
//     obj['PlaceName'] = currentAddress;
//     obj['latitude'] = latitude;
//     obj['longitude'] = longitude;
//
//     return obj;
//   } catch (_) {
//     print(_);
//     return null;
//   }
// }


// Future coordinatesToAddress({latitude, longitude}) async {
//   try {
//     Map<String, dynamic> obj = {};
//     final coordinates = Coordinates(latitude, longitude);
//     List<Address> result =
//         await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     String currentAddress =
//         "${result.first.locality ?? ''}, ${result.first.countryName ?? ''}.";
//
//     print(currentAddress);
//     obj['PlaceName'] = currentAddress;
//     obj['latitude'] = latitude;
//     obj['longitude'] = longitude;
//
//     return obj;
//   } catch (_) {
//     print(_);
//     return null;
//   }
// }
