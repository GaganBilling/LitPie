import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Screens/viewMyPlans.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/media/placePicScreen.dart';
import 'package:litpie/provider/global_posts/provider/globalPostProvider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class PlanDate extends StatefulWidget {
  @override
  _PlanDate createState() => _PlanDate();
}

class _PlanDate extends State<PlanDate> {
  FirebaseController _firebaseController = FirebaseController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _doingController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeBeginController = TextEditingController();
  TextEditingController _timeEndController = TextEditingController();

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");

  //double _maxScreenWidth;

  TimeOfDay startTime;
  TimeOfDay endTime;
  DateTime pTimeStamp;
  String planplacepic;

  Map<String, dynamic> planData;
  bool isUploading = false;
  String planId;

  Future updatePlanData() async {
    isUploading = true;

    var ref = FirebaseFirestore.instance.collection("Plans").doc();

    planData = {
      "pCity": _cityController.text,
      "pName": _nameController.text,
      "pVenue": _venueController.text,
      "pDoing": _doingController.text,
      "pDate": _dateController.text,
      "pTimeBegin": _timeBeginController.text,
      "pTimeEnd": _timeEndController.text,
      "pTimeStamp": Timestamp.fromDate(getFullDateTime(pTimeStamp, startTime)),
      "pdataOwnerID": _firebaseController.currentFirebaseUser.uid,
      "createdAt": Timestamp.now(),
      "planplacepic": planplacepic,
      "planId": ref.id,
    };

    ref.set(planData, SetOptions(merge: true)).then((value) {
      isUploading = false;

      Fluttertoast.showToast(
          msg: "Plan updated!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((e) {
      isUploading = false;

      print("ERROR (Plan Update): $e");
    });

    ref
        .set(planData)
        .then((value) => print("Plan added to the collection"))
        .catchError((e) {
      print(e.toString());
    });
  }

  void getAllData() async {
    QuerySnapshot doc = await _firebaseController.planColReference
        .where("pdataOwnerID",
            isEqualTo: _firebaseController.currentFirebaseUser.uid)
        .get();

    if (doc.docs.isNotEmpty) {
      Map<String, dynamic> data = doc.docs[0].data();
      setState(() {
        planplacepic = data['planplacepic'];
        _cityController.text = data['pCity'];
        _nameController.text = data['pName'];
        _venueController.text = data['pVenue'];
        _doingController.text = data['pDoing'];
        _timeBeginController.text = data['pTimeBegin'];
        planId = data['planId'];
        if (data['pTimeBegin'] != "") {
          int hour = int.parse(data['pTimeBegin'].split(":")[0]);
          int minute =
              int.parse(data['pTimeBegin'].split(":")[1].split(" ")[0]);
          startTime = TimeOfDay(hour: hour, minute: minute);
        }

        _timeEndController.text = data['pTimeEnd'];
        if (data['pTimeEnd'] != "") {
          int hour = int.parse(data['pTimeEnd'].split(":")[0]);
          int minute = int.parse(data['pTimeEnd'].split(":")[1].split(" ")[0]);
          endTime = TimeOfDay(hour: hour, minute: minute);
        }

        pTimeStamp =
            data['pTimeStamp'] == null ? null : data['pTimeStamp'].toDate();

        _dateController.text = getFormatDateFromTimestamp(pTimeStamp);
      });
    }
  }

  String getFormatDateFromTimestamp(DateTime date) {
    return date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString() +
        ", " +
        DateFormat('EEEE').format(date);
  }

  void initState() {
    super.initState();
    getAllData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> openTimeBegin(BuildContext context) async {
    final TimeOfDay t = await openTimePicker(context);
    if (t != null) {
      setState(() {
        startTime = t;
        _timeBeginController.text = t.format(context);
      });
    } else {
      _timeBeginController.clear();
    }
  }

  Future<void> openTimeEnd(BuildContext context) async {
    final TimeOfDay t = await openTimePicker(context);
    if (t != null) {
      setState(() {
        endTime = t;
        _timeEndController.text = t.format(context);
      });
    } else {
      _timeEndController.clear();
    }
  }

  Future<TimeOfDay> openTimePicker(BuildContext context) async {
    return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                      onBackground: mRed,
                      surface: lRed,
                      primary: Colors.white,
                      onSurface: Colors.white),
                  buttonTheme: ButtonThemeData(
                      colorScheme: ColorScheme.dark(
                    primary: white,
                  ))),
              child: child);
        });
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Create Plan",style: TextStyle(color: mRed)),

            leading: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: themeProvider.isDarkMode ? white : Colors.black,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: ElevatedButton(
                  child: isUploading
                      ? Center(child: CircularProgressIndicator())
                      : Text(
                          "View My Plans".tr(),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ViewMyPlans(),
                      ),
                    );
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 25.0,
                    ),
                    buildPlanTextField(
                      themeProvider: themeProvider,
                      validator: _validateName,
                      controller: _nameController,
                      hint: "Give it a name!".tr(),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    buildPlanTextField(
                      themeProvider: themeProvider,
                      validator: _validateDoing,
                      controller: _doingController,
                      hint: "What are we doing?".tr(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    buildPickerTextField(
                      themeProvider: themeProvider,
                      hint: "Pick Date".tr(),
                      controller: _dateController,
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: mRed,
                        size: 24,
                      ),
                      validator: _validateDate,
                      onTap: () {
                        planCalendar();
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildPickerTextField(
                            themeProvider: themeProvider,
                            hint: "From".tr(),
                            controller: _timeBeginController,
                            icon: Icon(
                              Icons.access_time_outlined,
                              color: mRed,
                              size: 24,
                            ),
                            validator: _validateTimeBegin,
                            onTap: () {
                              openTimeBegin(context);
                            },
                          ),
                          // child: Container(
                          //   padding: EdgeInsets.only(left: 25.0, right: 10),
                          //   child: OutlinedButton(
                          //     child: Row(
                          //       children: [
                          //         Align(
                          //           alignment: Alignment.centerLeft,
                          //           child: Icon(
                          //             Icons.access_time_outlined,
                          //             color: mRed,
                          //             size: 24,
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(
                          //               left: 12.0, top: 15, bottom: 15),
                          //           child: Align(
                          //             alignment: Alignment.centerLeft,
                          //             child: Text(
                          //                 pTimeBegin != null
                          //                     ? pTimeBegin
                          //                     : _timeBegincontroller.text,
                          //                 textAlign: TextAlign.start,
                          //                 style: TextStyle(fontSize: 18)),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     onPressed: () {
                          //       openTimeBegin(context);
                          //     },
                          //     style: OutlinedButton.styleFrom(
                          //         primary:
                          //             themeProvider.isDarkMode ? white : black,
                          //         side: BorderSide(
                          //           color: Colors.blueGrey,
                          //           style: BorderStyle.solid,
                          //         ),
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(
                          //           20.0,
                          //         ))),
                          //   ),
                          // ),
                        ),
                        Text(
                          "To".tr(),
                          style: TextStyle(fontSize: 20),
                        ),
                        Expanded(
                          child: buildPickerTextField(
                            themeProvider: themeProvider,
                            hint: "Until".tr(),
                            controller: _timeEndController,
                            icon: Icon(
                              Icons.access_time_outlined,
                              color: mRed,
                              size: 24,
                            ),
                            validator: _validateTimeEnd,
                            onTap: () {
                              openTimeEnd(context);
                            },
                          ),
                          // child: Container(
                          //   padding: EdgeInsets.only(left: 10.0, right: 25),
                          //   child: OutlinedButton(
                          //     child: Row(
                          //       children: [
                          //         Align(
                          //           alignment: Alignment.centerLeft,
                          //           child: Icon(
                          //             Icons.access_time_outlined,
                          //             color: mRed,
                          //             size: 24,
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(
                          //               left: 12.0, top: 15, bottom: 15),
                          //           child: Align(
                          //             alignment: Alignment.centerLeft,
                          //             child: Text(
                          //                 pTimeEnd != null
                          //                     ? pTimeEnd
                          //                     : "Until".tr(),
                          //                 textAlign: TextAlign.start,
                          //                 style: TextStyle(
                          //                     fontSize: 18,
                          //                     fontWeight: FontWeight.w500)),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     onPressed: () {
                          //       openTimeEnd(context);
                          //     },
                          //     style: OutlinedButton.styleFrom(
                          //         primary:
                          //             themeProvider.isDarkMode ? white : black,
                          //         side: BorderSide(
                          //           color: Colors.blueGrey,
                          //           style: BorderStyle.solid,
                          //         ),
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(
                          //           20.0,
                          //         ))),
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    buildPlanTextField(
                      themeProvider: themeProvider,
                      validator: _validateVenu,
                      controller: _venueController,
                      hint: "Enter Venue/Location/Place.".tr(),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    buildPlanTextField(
                      themeProvider: themeProvider,
                      validator: _validateCity,
                      controller: _cityController,
                      hint: "Enter City.".tr(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        var globalPostProvider =
                        Provider.of<GlobalPostProvider>(context, listen: false);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PlanplacepicPicScreen(uploadPic: (urls) {
                                      print("skjdf "+urls);
                                      setState(() {
                                        planplacepic = urls;
                                      });
                                    })
                            )).then((value) {
                          print("ssfsdf "+globalPostProvider.planPicData);
                          setState(() {
                            planplacepic = globalPostProvider.planPicData;
                          });
                        });
                      },
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  child: planplacepic != null
                                      ? planplacepic.isNotEmpty
                                          ? CachedNetworkImage(
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.fill,
                                              imageUrl: planplacepic,
                                              useOldImageOnUrlChange: true,
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(
                                                radius: 1,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.error,
                                                    color: Colors.blueGrey,
                                                    size: 1,
                                                  ),
                                                  Text(
                                                    "Error".tr(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 5),
                                                  )
                                                ],
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                80,
                                              ),
                                              child: Container(
                                                height: 35,
                                                width: 35,
                                                child: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: mRed,
                                                ),
                                              ),
                                            )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            80,
                                          ),
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              color: mRed,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                planplacepic != null
                                    ? planplacepic.isNotEmpty
                                        ? Text("Update Image".tr(),
                                            overflow: TextOverflow.ellipsis)
                                        : Tooltip(
                                            preferBelow: false,
                                            message:
                                                "Do you want to add Image for reference"
                                                    .tr(),
                                            child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: _screenWidth >=
                                                          miniScreenWidth
                                                      ? 270
                                                      : 190,
                                                ),
                                                child: Text(
                                                  "Do you want to add Image for reference"
                                                      .tr(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                            textStyle: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 14
                                                    : 12),
                                          )
                                    : Tooltip(
                                        preferBelow: false,
                                        message:
                                            "Do you want to add Image for reference?"
                                                .tr(),
                                        child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth: _screenWidth >=
                                                      miniScreenWidth
                                                  ? 270
                                                  : 190,
                                            ),
                                            child: Text(
                                              "Do you want to add Image for reference?"
                                                  .tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                        textStyle: TextStyle(
                                            fontSize:
                                                _screenWidth >= miniScreenWidth
                                                    ? 14
                                                    : 12))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      child: Text("Save plan".tr(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await updatePlanData();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: mRed,
                        onPrimary: white,
                        elevation: 3,
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 60.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    // (pTimeStamp != null)
                    //     ? Tooltip(
                    //         message: "Remove Plan".tr(),
                    //         preferBelow: false,
                    //         child: ElevatedButton(
                    //           child: Text("Remove Plan".tr(),
                    //               overflow: TextOverflow.ellipsis,
                    //               style: TextStyle(
                    //                   fontSize: 22,
                    //                   fontWeight: FontWeight.bold)),
                    //           onPressed: () {
                    //             showDialog(
                    //                 context: context,
                    //                 builder: (context) => AlertDialog(
                    //                       backgroundColor:
                    //                           themeProvider.isDarkMode
                    //                               ? black.withOpacity(.5)
                    //                               : white.withOpacity(.8),
                    //                       content: Container(
                    //                         // height: MediaQuery.of(context).size.height / 4,
                    //                         child: Column(
                    //                           mainAxisSize: MainAxisSize.min,
                    //                           children: [
                    //                             Text(
                    //                               "This will remove all the data related to this plan, if any. \nAre You Sure?"
                    //                                   .tr(),
                    //                               textAlign: TextAlign.center,
                    //                               style:
                    //                                   TextStyle(fontSize: 16),
                    //                             ),
                    //                             SizedBox(
                    //                               height: 15,
                    //                             ),
                    //                             Container(
                    //                               width: MediaQuery.of(context)
                    //                                   .size
                    //                                   .width,
                    //                               margin: EdgeInsets.only(
                    //                                   left: 30, right: 30),
                    //                               height: 50,
                    //                               child: ElevatedButton(
                    //                                 onPressed: () async {
                    //                                   removeOldPlan();
                    //                                   Fluttertoast.showToast(
                    //                                       msg: "Plan removed!!"
                    //                                           .tr(),
                    //                                       toastLength: Toast
                    //                                           .LENGTH_SHORT,
                    //                                       gravity: ToastGravity
                    //                                           .BOTTOM,
                    //                                       timeInSecForIosWeb: 3,
                    //                                       backgroundColor:
                    //                                           Colors.blueGrey,
                    //                                       textColor:
                    //                                           Colors.white,
                    //                                       fontSize: 16.0);
                    //                                   Navigator.pop(context);
                    //                                   Navigator.of(context)
                    //                                       .pop();
                    //                                   setState(() {});
                    //                                 },
                    //                                 child: Text(
                    //                                   "YES".tr(),
                    //                                   textAlign:
                    //                                       TextAlign.center,
                    //                                   style: TextStyle(
                    //                                       fontSize: 20),
                    //                                 ),
                    //                                 style: ElevatedButton
                    //                                     .styleFrom(
                    //                                   primary: mRed,
                    //                                   onPrimary: white,
                    //                                   // padding: EdgeInsets.fromLTRB(80.0, 15.0, 80.0, 10.0),
                    //                                   elevation: 5,
                    //                                   shape:
                    //                                       RoundedRectangleBorder(
                    //                                           borderRadius:
                    //                                               BorderRadius
                    //                                                   .circular(
                    //                                                       20.7)),
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                             SizedBox(
                    //                               height: 10,
                    //                             ),
                    //                             Container(
                    //                               width: MediaQuery.of(context)
                    //                                   .size
                    //                                   .width,
                    //                               margin: EdgeInsets.only(
                    //                                   left: 30, right: 30),
                    //                               height: 50,
                    //                               child: ElevatedButton(
                    //                                 onPressed: () {
                    //                                   Navigator.of(context)
                    //                                       .pop();
                    //                                 },
                    //                                 child: Text(
                    //                                   "NO".tr(),
                    //                                   textAlign:
                    //                                       TextAlign.center,
                    //                                   style: TextStyle(
                    //                                       fontSize: 20),
                    //                                 ),
                    //                                 style: ElevatedButton
                    //                                     .styleFrom(
                    //                                   primary: themeProvider
                    //                                           .isDarkMode
                    //                                       ? mBlack
                    //                                       : white,
                    //                                   onPrimary:
                    //                                       Colors.blue[700],
                    //                                   // padding: EdgeInsets.fromLTRB(80.0, 15.0, 80.0, 10.0),
                    //                                   elevation: 5,
                    //                                   shape:
                    //                                       RoundedRectangleBorder(
                    //                                           borderRadius:
                    //                                               BorderRadius
                    //                                                   .circular(
                    //                                                       20.7)),
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     ));
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             primary: mRed,
                    //             onPrimary: white,
                    //             elevation: 3,
                    //             padding: EdgeInsets.symmetric(
                    //                 vertical: 12.0, horizontal: 60.0),
                    //             shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20)),
                    //           ),
                    //         ),
                    //       )
                    //     : Container(),
                    SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlanTextField(
      {@required ThemeProvider themeProvider,
      @required TextEditingController controller,
      @required String hint,
      @required Function(String) validator}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
      child: TextFormField(
        validator: validator,
        controller: controller,
        style: Theme.of(context).textTheme.subtitle1,
        decoration: InputDecoration(
            errorStyle: TextStyle(
              color: themeProvider.isDarkMode ? white : black,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: lRed)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: mRed, width: 3)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: mRed)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: mRed, width: 3)),
            hintText: hint),
      ),
    );
  }

  Widget buildPickerTextField({
    @required ThemeProvider themeProvider,
    @required TextEditingController controller,
    @required String hint,
    @required VoidCallback onTap,
    @required Widget icon,
    @required Function(String) validator,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
      child: TextFormField(
        validator: validator,
        controller: controller,
        style: Theme.of(context).textTheme.subtitle1,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
            prefixIcon: icon,
            errorStyle: TextStyle(
              color: themeProvider.isDarkMode ? white : black,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: lRed)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(color: mRed, width: 3)),
            hintText: hint),
      ),
    );
  }

  String _validateName(String value) {
    if (value.length == 0) {
      return "Give it some name.".tr();
    }
    if (value.length > 13) {
      return "Cannot exceed 13 letters.".tr();
    }
    return null;
  }

  String _validateCity(String value) {
    if (value.length == 0) {
      return "Enter City.".tr();
    }
    if (value.length > 20) {
      return "Cannot exceed 20 letters.".tr();
    }
    return null;
  }

  String _validateVenu(String value) {
    if (value.length == 0) {
      return "Enter Venue.".tr();
    }
    if (value.length > 25) {
      return "Cannot exceed 25 letters.".tr();
    }
    return null;
  }

  String _validateDoing(String value) {
    if (value.length == 0) {
      return "Tell them what are you planing to do.".tr();
    }
    if (value.length > 150) {
      return "Cannot exceed 150 letters.".tr();
    }
    return null;
  }

  String _validateDate(String date) {
    if (date.isEmpty) {
      return "Please Select Date".tr();
    }
    return null;
  }

  String _validateTimeBegin(String time) {
    if (time.isEmpty) {
      return "Please Select From Time!!".tr();
    }
    return null;
  }

  String _validateTimeEnd(String time) {
    if (time.isEmpty) {
      return "Please Select Until Time!!".tr();
    }
    return null;
  }

  bool validateAllFields() {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    return true;
  }

  Future planCalendar() async {
    DateTime date1 = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 6)),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    surface: lRed,
                    primary: white,
                  ),
                  dialogBackgroundColor: lRed,
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(primary: white))),
              child: child);
        });

    if (date1 != null) {
      pTimeStamp = date1;
      _dateController.text = getFormatDateFromTimestamp(pTimeStamp);
    } else {
      _dateController.clear();
    }
    setState(() {});
  }

  DateTime getFullDateTime(DateTime date, TimeOfDay time) {
    DateTime finalDateTime;
    finalDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return finalDateTime;
  }

  void updatePlanRequest() {
    _firebaseController.planColReference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .collection('planRequest')
        .get()
        .then((planRequest1) {
      List<String> usersIds = [];
      planRequest1.docs.forEach((requestDoc1) {
        print(requestDoc1.data());
        if (requestDoc1.data()["request"] == "received") {
          usersIds.add(requestDoc1.id);
          print("Doc Deleted");
          print("usersIds: $usersIds");
          requestDoc1.reference.delete();
        }
      });

      usersIds.forEach((uid) {
        _reference
            .doc(uid)
            .collection('planRequest')
            .get()
            .then((planRequest2) {
          planRequest2.docs.forEach((requestDoc) {
            print(requestDoc.data());
            print("DocID: ${requestDoc.id}");
            if (requestDoc.id == _firebaseController.currentFirebaseUser.uid) {
              print("plan found");
              if (requestDoc.data()["request"] == "sent") {
                print("sent found");
                requestDoc.reference.delete();
              }
            }
          });
        });
      });
    });
  }

  void removeOldPlan() async {
    print('uid: ${_firebaseController.currentFirebaseUser.uid}');
    print("Plan removed");

    FirebaseFirestore.instance
        .collection("Plans")
        .doc(planId)
        .collection("planRequest")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      }
    });

    var planData = await FirebaseFirestore.instance
        .collection("Plans")
        .where("pdataOwnerID",
            isEqualTo: _firebaseController.currentFirebaseUser.uid)
        .where("planId", isEqualTo: planId)
        .get();
    planData.docs.forEach((element) {
      element.reference.delete();
    });

    /* _reference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .collection('plans')
        .doc(_firebaseController.currentFirebaseUser.uid)
        .set({
      "pCity": "",
      "pDoing": "",
      "pName": "",
      "pVenue": "",
      "pDate": "",
      "pTimeBegin": "",
      "pTimeEnd": "",
      "pTimeStamp": null,
      "planplacepic": "",
      "uid": _firebaseController.currentFirebaseUser.uid,
      "createdAt": null,
    }, SetOptions(merge: true)).then((_) {
      print("success!");

    });*/
  }
}
