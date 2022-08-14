import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class Hobbies extends StatefulWidget {
  List hobbies;

  Hobbies({this.hobbies});

  @override
  _Hobbies createState() => _Hobbies();
}

class _Hobbies extends State<Hobbies> {
  List<Map<String, dynamic>> hobbieslist = [
    {'name': "Acting".tr(), 'ontap': false},
    {'name': "Activism".tr(), 'ontap': false},
    {'name': "Aquarium".tr(), 'ontap': false},
    {'name': "Animals".tr(), 'ontap': false},
    {'name': "Arts".tr(), 'ontap': false},
    {'name': "Artist".tr(), 'ontap': false},
    {'name': "Astronomy".tr(), 'ontap': false},
    {'name': "Astrology".tr(), 'ontap': false},
    {'name': "Badminton".tr(), 'ontap': false},
    {'name': "Baseball".tr(), 'ontap': false},
    {'name': "Basketball".tr(), 'ontap': false},
    {'name': "Beach".tr(), 'ontap': false},
    {'name': "Beatboxing".tr(), 'ontap': false},
    {'name': "Belly Dancing".tr(), 'ontap': false},
    {'name': "Bird watching".tr(), 'ontap': false},
    {'name': "Books".tr(), 'ontap': false},
    {'name': "Blogger".tr(), 'ontap': false},
    {'name': "Bhangra".tr(), 'ontap': false},
    {'name': "Biking".tr(), 'ontap': false},
    {'name': "Board Games".tr(), 'ontap': false},
    {'name': "Boating".tr(), 'ontap': false},
    {'name': "Body Building".tr(), 'ontap': false},
    {'name': "Bowling".tr(), 'ontap': false},
    {'name': "Boxing".tr(), 'ontap': false},
    {'name': "Beer".tr(), 'ontap': false},
    {'name': "Camping".tr(), 'ontap': false},
    {'name': "Car Racing".tr(), 'ontap': false},
    {'name': "Cat lover".tr(), 'ontap': false},
    {'name': "Cardio Workout".tr(), 'ontap': false},
    {'name': "Cartooning".tr(), 'ontap': false},
    {'name': "Casino Gambling".tr(), 'ontap': false},
    {'name': "Chess".tr(), 'ontap': false},
    {'name': "Cheerleading".tr(), 'ontap': false},
    {'name': "Collecting".tr(), 'ontap': false},
    {'name': "Coloring".tr(), 'ontap': false},
    {'name': "Compose Music".tr(), 'ontap': false},
    {'name': "Cooking".tr(), 'ontap': false},
    {'name': "Crafts".tr(), 'ontap': false},
    {'name': "Cricket".tr(), 'ontap': false},
    {'name': "Crossword".tr(), 'ontap': false},
    {'name': "Cycling".tr(), 'ontap': false},
    {'name': "Dancing".tr(), 'ontap': false},
    {'name': "Drinks".tr(), 'ontap': false},
    {'name': "Dog lover".tr(), 'ontap': false},
    {'name': "Disney".tr(), 'ontap': false},
    {'name': "Drawing".tr(), 'ontap': false},
    {'name': "Do nothing".tr(), 'ontap': false},
    {'name': "Entertaining".tr(), 'ontap': false},
    {'name': "Family".tr(), 'ontap': false},
    {'name': "Fishing".tr(), 'ontap': false},
    {'name': "Festivals".tr(), 'ontap': false},
    {'name': "Football".tr(), 'ontap': false},
    {'name': "Games".tr(), 'ontap': false},
    {'name': "Gardening".tr(), 'ontap': false},
    {'name': "Golf".tr(), 'ontap': false},
    {'name': "Guitar".tr(), 'ontap': false},
    {'name': "Gossiping".tr(), 'ontap': false},
    {'name': "Gymnastics".tr(), 'ontap': false},
    {'name': "Hiking".tr(), 'ontap': false},
    {'name': "Horseback Riding".tr(), 'ontap': false},
    {'name': "Hunting".tr(), 'ontap': false},
    {'name': "Internet".tr(), 'ontap': false},
    {'name': "Jewelry Making".tr(), 'ontap': false},
    {'name': "Knitting".tr(), 'ontap': false},
    {'name': "Magic".tr(), 'ontap': false},
    {'name': "Martial Arts".tr(), 'ontap': false},
    {'name': "Movies".tr(), 'ontap': false},
    {'name': "Meditation".tr(), 'ontap': false},
    {'name': "Museum".tr(), 'ontap': false},
    {'name': "Mountains".tr(), 'ontap': false},
    {'name': "Music".tr(), 'ontap': false},
    {'name': "Nail Art".tr(), 'ontap': false},
    {'name': "Netflix".tr(), 'ontap': false},
    {'name': "Non Vegetarian".tr(), 'ontap': false},
    {'name': "Off Road Driving".tr(), 'ontap': false},
    {'name': "Piano".tr(), 'ontap': false},
    {'name': "Puzzles".tr(), 'ontap': false},
    {'name': "Party".tr(), 'ontap': false},
    {'name': "Photography".tr(), 'ontap': false},
    {'name': "Politics".tr(), 'ontap': false},
    {'name': "Rafting".tr(), 'ontap': false},
    {'name': "Religious".tr(), 'ontap': false},
    {'name': "Reading".tr(), 'ontap': false},
    {'name': "Soccer".tr(), 'ontap': false},
    {'name': "Sleeping".tr(), 'ontap': false},
    {'name': "Sit idle".tr(), 'ontap': false},
    {'name': "Sneakers".tr(), 'ontap': false},
    {'name': "Shopping".tr(), 'ontap': false},
    {'name': "Socializing".tr(), 'ontap': false},
    {'name': "Stand up comedy".tr(), 'ontap': false},
    {'name': "Storytelling".tr(), 'ontap': false},
    {'name': "Surfing".tr(), 'ontap': false},
    {'name': "Swimming".tr(), 'ontap': false},
    {'name': "Vegan".tr(), 'ontap': false},
    {'name': "Vegetarian".tr(), 'ontap': false},
    {'name': "Vlogging".tr(), 'ontap': false},
    {'name': "Video Games".tr(), 'ontap': false},
    {'name': "Traveling".tr(), 'ontap': false},
    {'name': "Walking".tr(), 'ontap': false},
    {'name': "Writing".tr(), 'ontap': false},
    {'name': "Wine".tr(), 'ontap': false},
    {'name': "Yoga".tr(), 'ontap': false},
    {'name': "Zumba".tr(), 'ontap': false},
  ];

  Map<String, dynamic> userData = {};

  Future setUserData(Map<String, dynamic> userData) async {
    final auth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .set(userData, SetOptions(merge: true));
  }

  List selected = [];
  bool select = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // double _maxScreenWidth;

  double _screenWidth;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.hobbies != null) {
      var data = hobbieslist
          .where((element) => widget.hobbies.contains(element['name']))
          .toList();
      if (data.length > 0) {
        data.forEach((element) {
          element.update("ontap", (value) => true);
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10, right: 0),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: ElevatedButton(
                  child: Text(
                    "SAVE".tr(),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    userData.addAll({"hobbies": selected});
                    setUserData(userData);
                    Fluttertoast.showToast(
                        msg: "Updated".tr(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: mRed,
                      onPrimary: white,
                      padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        child: Text(
                          "My Interests".tr(),
                          style: TextStyle(
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 30 : 20,
                              fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.only(
                          top: 40,
                          left: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.3,
                      padding: EdgeInsets.all(20),
                      child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: hobbieslist.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Tooltip(
                                  message: "${hobbieslist[index]["name"]}".tr(),
                                  child: ElevatedButton(
                                    child: Text(
                                      "${hobbieslist[index]["name"]}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize:
                                            _screenWidth >= miniScreenWidth
                                                ? 16
                                                : 14,
                                        fontWeight: FontWeight.w500,
                                        // color: man ? mRed : Colors.blueGrey
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (selected.length < 30) {
                                          hobbieslist[index]["ontap"] =
                                              !hobbieslist[index]["ontap"];
                                          if (hobbieslist[index]["ontap"]) {
                                            selected.add(
                                                hobbieslist[index]["name"]);
                                            print(hobbieslist[index]["name"]);
                                            print(selected);
                                          } else {
                                            selected.remove(
                                                hobbieslist[index]["name"]);
                                            print(selected);
                                          }
                                        } else {
                                          if (hobbieslist[index]["ontap"]) {
                                            hobbieslist[index]["ontap"] =
                                                !hobbieslist[index]["ontap"];
                                            selected.remove(
                                                hobbieslist[index]["name"]);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Can only select".tr() +
                                                    " 30",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: hobbieslist[index]["ontap"]
                                          ? mRed
                                          : Colors.blueGrey,
                                      onPrimary: white,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.7)),
                                    ),
                                  ),
                                ));
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
