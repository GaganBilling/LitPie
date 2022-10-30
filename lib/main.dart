import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Screens/BottomNavigation/Home/home.dart';
import 'package:litpie/Screens/BottomNavigation/Home/swipe/swipe_provider.dart';
import 'package:litpie/Screens/BottomNavigation/bottomNav.dart';
import 'package:litpie/Screens/BottomNavigation/notifications/notification_provider.dart';
import 'package:litpie/Screens/my_post/my_post_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/localNotificationController.dart';
import 'package:litpie/controller/pushNotificationController.dart';
import 'package:litpie/controller/rewardCollectController.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/Registration/OTPphoneUpdate.dart';
import 'package:litpie/Screens/WelcomeScreen.dart';
import 'package:litpie/Screens/noInternetScreen.dart';
import 'package:litpie/Screens/splashScreen.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/connectivityController.dart';
import 'package:litpie/controller/notificationBadgeController.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Registration/login.dart';
import 'Theme/colors.dart';
import 'Theme/theme_provider.dart';
import 'controller/chatBadgeController.dart';
import 'edit/Gender.dart';
import 'Registration/OTPcreateAccount.dart';
import 'Registration/OTPphoneLogin.dart';
import 'Registration/create_account.dart';
import 'Registration/dateofBirth.dart';
import 'location/turnlocationOn.dart';
import 'models/createAccountData.dart';
import 'package:location/location.dart' as loc;

import 'package:easy_localization/easy_localization.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'provider/global_posts/provider/globalPostProvider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  await EasyLocalization.ensureInitialized();

  //runApp(new MyApp());

  runApp(EasyLocalization(
    supportedLocales: [
      Locale('en', 'US'),
      Locale('es', 'ES'),
      Locale('fr', 'CA'),
      Locale('de', 'DE'),
      Locale('ru', 'RU'),
      Locale('it', 'IT')
    ],
    path: 'assets/translation',
    // saveLocale: true,
    fallbackLocale: Locale('en', 'US'),
    child: MyApp(),
  ));
}

Future<void> messageHandler(RemoteMessage message) async {
  if (message.data["screen"] == "notifications") {
    FlutterAppBadger.updateBadgeCount(1);
  }
  bool soundOn = message.data["sound"] == "true" ? true : false;
  bool vibrateOn = message.data["vibrate"] == "true" ? true : false;
  LocalNotification().showFcmNotification(
      title: message.data['title'],
      msg: message.data['body'],
      sound: soundOn,
      vibrate: vibrateOn,
      screen: message.data["screen"],
      data: message.data);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoading = true;
  bool isLocation = true;
  bool isAuth = false;
  bool isRegistered = false;
  bool isUserDetailExist = false;
  CreateAccountData currentUser;
  SharedPreferences prefs;

  //Location location = Location();

  PushNotificationController _pushNotificationController =
      PushNotificationController();

  FirebaseController _firebaseController = FirebaseController();

  Future<CreateAccountData> getUser() async {
    return _firebaseController.userColReference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .get()
        .then((m) {
      if (m["editInfo"] == null) {
        return null;
      }
      return CreateAccountData.fromDocument(m.data());
    });
  }

  int finddays(int m2, int y2) {
    int day2;
    if (m2 == 2 ||
        m2 == 3 ||
        m2 == 5 ||
        m2 == 7 ||
        m2 == 8 ||
        m2 == 10 ||
        m2 == 12)
      day2 = 31;
    else if (m2 == 4 || m2 == 6 || m2 == 9 || m2 == 11)
      day2 = 30;
    else {
      if (y2 % 4 == 0)
        day2 = 29;
      else
        day2 = 28;
    }
    return day2;
  }

  String dateOfBirthToAge({@required DateTime dobDate}) {
    int d, m, y;
    String days1 = "", month1 = "", year1 = "";
    String dy = DateFormat('EEEE').format(dobDate);
    print('day $dy');
    d = int.parse(DateFormat("dd").format(dobDate));
    m = int.parse(DateFormat("MM").format(dobDate));
    y = int.parse(DateFormat("yyyy").format(dobDate));
    int d1 = int.parse(DateFormat("dd").format(DateTime.now()));
    int m1 = int.parse(DateFormat("MM").format(DateTime.now()));
    int y1 = int.parse(DateFormat("yyyy").format(DateTime.now()));

    int day = finddays(m1, y1);
    if (d1 - d >= 0)
      days1 = (d1 - d).toString() + " days";
    else {
      days1 = (d1 + day - d).toString() + " days";
      m1 = m1 - 1;
    }
    if (m1 - m >= 0)
      month1 = (m1 - m).toString() + " months";
    else {
      month1 = (m1 + 12 - m).toString() + " months";
      y1 = y1 - 1;
    }
    year1 = (y1 - y).toString() + " years";

    String age = (y1 - y).toString();
    return age;
  }

  /// blocks rotation; sets orientation to: portrait
  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void initState() {
    _pushNotificationController.fcmInitialization(navigatorKey: navigatorKey);
    _portraitModeOnly();
    kInit();
    WidgetsBinding.instance.addObserver(this);
    FlutterAppBadger.removeBadge();

    if (_firebaseController.currentFirebaseUser != null) {
      getUser().then((value) async {
        currentUser = value;
        Constants().setDeviceToken();

        if (currentUser != null) {
          Map<String, dynamic> updateDataMap = {
            "isOnline": prefs.getBool('isOnline'),
            "lastLogin": Timestamp.now()
          };
          DateTime userDOB = DateFormat('d/M/yyyy').parse(currentUser.dOB);
          print("User DOB (String): ${currentUser.dOB}");
          print("User DOB (Date): $userDOB");

          String userAge = dateOfBirthToAge(dobDate: userDOB);
          if (currentUser.age != userAge) {
            print("DOB Updated");
            updateDataMap['age'] = userAge;
          }

          _firebaseController.userColReference
              .doc(currentUser.uid)
              .update(updateDataMap);
        } else {
          Fluttertoast.showToast(
              msg: "Complete Your Profile!".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
      _updateLocation();
    }
    _checkAuth();
  }

  void kInit() async {
    prefs = await SharedPreferences.getInstance();

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization()
          .then((value) {
        prefs.setBool("appTrackPermission", true);
      });
    } catch (e) {
      print("AppTrackPermission Error: $e");
    }
  }

  void _enableRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _enableRotation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;

    if (isBackground) {
      // service.stop();
      goOffline();
    } else {
      // service.start();
      if (_firebaseController.currentUserData != null &&
          _firebaseController.firebaseAuth.currentUser != null) {
        _firebaseController.userColReference
            .doc(_firebaseController.firebaseAuth.currentUser.uid)
            .update({'isOnline': prefs.getBool('isOnline') ?? false});
      }
    }
  }

  goOffline() {
    if (currentUser != null) {
      _firebaseController.userColReference
          .doc(currentUser.uid)
          .update({'isOnline': false});
    }
  }

  Map<String, dynamic> userData = {};

  Future setUserData(Map<String, dynamic> userData) async {
    if (_firebaseController.currentUserData != null) {
      final auth = FirebaseAuth.instance;
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser.uid)
            .set(userData, SetOptions(merge: true));
      } catch (E) {
        print(E.toString());
      }
    }
  }

  _updateLocation() async {
    bool serviceEnabled;
    geoLocator.LocationPermission permission;

    serviceEnabled = await geoLocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLocation = false;
        print("Location Off (ServiceEnabled)");
      });
      permission = await geoLocator.Geolocator.checkPermission();
      if (permission == geoLocator.LocationPermission.denied) {
        permission = await geoLocator.Geolocator.requestPermission();
        setState(() {
          isLocation = false;
          print("Location Off (ServiceEnabled 2)");
          // TurnLocationOn();
        });
      }
    } else {
      setState(() {
        isLocation = true;
      });
      await _updateLocationdata();
    }
  }


  _updateLocationdata() async {
    var currentLocation;
    try {
      print("location 2");
      // getLocationCoordinates().then((value) => print("location: $value"));
      try {
        currentLocation = await getLocationCoordinates();
      } catch (e) {
        print(e.toString());
      }
      print("CurrentLocation : $currentLocation");
      if (currentLocation == null) {
        setState(() {
          isLocation = false;
         // TurnLocationOn();
        });
      } else {
        if (mounted)
          setState(() {
            isLocation = true;
            userData.addAll(
              {
                'location': {
                  'latitude': currentLocation['latitude'],
                  'longitude': currentLocation['longitude'],
                  'address': currentLocation['PlaceName'],
                },
              },
            );
          });
        setUserData(userData);
      }
    } catch (e) {
      print("Location Error: $e");
    }
  }


  Future<Map> getLocationCoordinates() async {
    loc.Location location = loc.Location();
    try {
      await location.serviceEnabled().then((value) async {
        if (!value) {
          await location.requestService();
        }
      });
      var coordinates = await location.getLocation();
      print("Coordinates $coordinates");
      return await getCurrentLocation(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
    } catch (e) {
      print("Get Co-ordinate Error: $e");
      return null;
    }
  }

  //geolocater package
  Future<Map<String, dynamic>> getCurrentLocation({latitude, longitude}) async {
    geoLocator.Position position =
        await geoLocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geoLocator.LocationAccuracy.high);
    try {
      Map<String, dynamic> obj = {};
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude,localeIdentifier: "en");
      Placemark place;
      if(placemarks != null) {
        place = placemarks[0];
      }
      String currentAddress =
          "${place.locality ?? ''}, ${place.country ?? ''}.";

      print(currentAddress);
      obj['PlaceName'] = currentAddress;
      obj['latitude'] = position.latitude;
      obj['longitude'] = position.longitude;

      return obj;
    } catch (aa) {
      print("Allow location4 $aa");
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
  //     print("address $address");
  //     obj['PlaceName'] = address;
  //     obj['latitude'] = latitude;
  //     obj['longitude'] = longitude;
  //     return obj;
  //   } catch (one) {
  //     print("main dart page location error $one");
  //     return null;
  //   }
  // }

//geocoder package
//   Future coordinatesToAddress({latitude, longitude}) async {
//     try {
//       Map<String, dynamic> obj = {};
//       final coordinates = Coordinates(latitude, longitude);
//       List<Address> result =
//           await Geocoder.local.findAddressesFromCoordinates(coordinates);
//       String currentAddress =
//           "${result.first.locality ?? ''}, ${result.first.countryName ?? ''}.";
//
//       print(currentAddress);
//       obj['PlaceName'] = currentAddress;
//       obj['latitude'] = latitude;
//       obj['longitude'] = longitude;
//
//       return obj;
//     } catch (_) {
//       print(_);
//       return null;
//     }
//   }

  Future _checkAuth() async {
    final User currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: currentUser.uid)
          .get()
          .then((QuerySnapshot snapshot) async {
        if (snapshot.docs.length > 0) {
          if (snapshot.docs[0]['location'] != null) {
            final snapshot = await FirebaseFirestore.instance
                .collection(userCollectionName)
                .doc(currentUser.uid)
                .collection(rCollectionName)
                .get();
            // final snapshot = await FirebaseFirestore.instance .collection(rCollectionName).get();
            print("R Collectio Check ${snapshot.docs.length}");
            if (snapshot.docs.length > 0) {
              isUserDetailExist = true;
            }
            if (mounted)
              setState(() {
                isRegistered = true;
                isLoading = false;
              });
          } else {
            if (mounted)
              setState(() {
                isAuth = true;
                isLoading = false;
              });
          }
          print("LoggedIn ${currentUser.uid}");
        } else {
          if (mounted)
            setState(() {
              isLoading = false;
            });
        }
      });
    } else {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: mRed,
    ));
    GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (context) => NotificationBadgeController()),
        ChangeNotifierProvider(create: (context) => ChatBadgeController()),
        // ChangeNotifierProvider(create: (context) => SwipeController()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => RewardCollectController()),
        ChangeNotifierProvider(
          create: (context) => GlobalPostProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyPostProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SwipeProvider(),
        )
      ],
      child: Consumer2<ThemeProvider, ConnectivityProvider>(
        builder: (cont, themeProvider, connectivityProvider, child) {
          return MaterialApp(
              navigatorKey: key,
              debugShowCheckedModeBanner: false,
              // supportedLocales: [Locale('en','US'), Locale('es','ES')],
              supportedLocales: context.supportedLocales,
              // localizationsDelegates: [
              //   CountryLocalizations.delegate,
              //   GlobalMaterialLocalizations.delegate,
              //   GlobalWidgetsLocalizations.delegate,
              // ],
              locale: EasyLocalization.of(context).locale,
              localizationsDelegates: context.localizationDelegates,
              //title: 'Flutter Demo',
              themeMode: themeProvider.thememode,
              theme: MyThemes.lightTheme,
              darkTheme: MyThemes.darkTheme,
              routes: {
                '/OTPcreateaccount': (context) => OTPCreateAccount(
                      phone: (ModalRoute.of(context).settings.arguments
                          as Map)['phone'],
                      ext: (ModalRoute.of(context).settings.arguments
                          as Map)['countryCode'],
                    ),
                '/Dateofbirth': (context) => DateofBirth(),
                '/BottomNav': (context) => BottomNav(),
                '/Splash': (context) => Splash(),
                '/Welcome': (context) => Welcome(),
                '/Home': (context) => Home(),
                // '/SendMedia': (context) => SendMedia(),
                '/CreateAccount': (context) => CreateAccount(),
                '/TurnLocationOn': (context) => TurnLocationOn(),
                '/OTPupdatephone': (context) => OTPphoneupdate(
                      phone: (ModalRoute.of(context).settings.arguments
                          as Map)['phone'],
                      ext: (ModalRoute.of(context).settings.arguments
                          as Map)['countryCode'],
                    ),
                '/OTPphoneLogin': (context) => OTPphoneLogin(
                      phone: (ModalRoute.of(context).settings.arguments
                          as Map)['phone'],
                      countryCode: (ModalRoute.of(context).settings.arguments
                          as Map)['countryCode'],
                    ),
              },
              home: connectivityProvider.isOnline != null
                  ? !connectivityProvider.isOnline
                      ? NoInternetScreen()
                      // : currentUser == null && isAuth
                      //     ? Gender()
                      : isLoading
                          ? Splash()
                          : !isLocation
                              ? TurnLocationOn()
                              : !isUserDetailExist && isAuth
                                  ? Gender()
                                  : isRegistered
                                      ? BottomNav()
                                      : isAuth
                                          ? Welcome()
                                          : Login()
                  // : currentUser == null && isAuth
                  //     ? Gender()
                  : isLoading
                      ? Splash()
                      : !isLocation
                          ? TurnLocationOn()
                          : !isUserDetailExist && isAuth
                              ? Gender()
                              : isRegistered
                                  ? BottomNav()
                                  : isAuth
                                      ? Welcome()
                                      : Login());
        },
      ),
    );
  }
}
