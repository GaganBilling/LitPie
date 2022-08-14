import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum TypeOfReport {
  profile,
  video,
  storyVideo,
  storyImage,
  poll,
  post,
  image,
  explorePlan
}

class ReportUser extends StatefulWidget {
  final String currentUserUID;
  final String secondUserUID;
  final TypeOfReport typeOfReport;
  final String url;
  final String thumbnailUrl;
  final String mediaID;

  ReportUser(
      {@required this.currentUserUID,
      @required this.secondUserUID,
      @required this.typeOfReport,
      this.url,
      this.thumbnailUrl,
      this.mediaID});

  ReportUser.pollReport({
    this.currentUserUID,
    this.secondUserUID,
    this.typeOfReport,
    this.url,
    this.thumbnailUrl,
    this.mediaID,
  });

  @override
  _ReportUserState createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  TextEditingController reasonCtlr = TextEditingController();
  bool other = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (widget.typeOfReport == TypeOfReport.poll ||
        widget.typeOfReport == TypeOfReport.post) {
      return CupertinoAlertDialog(
        title: Container(
          // color:  themeProvider.isDarkMode?black:white,
          child: Column(
            children: <Widget>[
              Card(
                color: themeProvider.isDarkMode ? black : white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  Icons.security,
                  color: mRed,
                  size: 35,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Report User".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              Text(
                "Is this person bothering you? Tell us what they did.".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: !other
            ? <Widget>[
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text(widget.typeOfReport == TypeOfReport.post
                          ? "Report This Post".tr()
                          : "Report This Poll".tr()),
                      leading: Icon(
                        Icons.poll,
                        color: mRed,
                      ),
                      onTap: () => _newReport(
                              context,
                              widget.typeOfReport == TypeOfReport.post
                                  ? "Report on Post"
                                  : "Report on Poll")
                          .then((value) => Navigator.pop(context))),
                ),
                Divider(
                  height: 1,
                ),
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text(
                        "Other".tr(),
                      ),
                      leading: Icon(
                        Icons.report_problem,
                        color: Colors.green,
                      ),
                      onTap: () {
                        setState(() {
                          other = true;
                        });
                      }),
                ),
              ]
            : <Widget>[
                Material(
                    color: themeProvider.isDarkMode ? black : white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: reasonCtlr,
                            decoration: InputDecoration(
                                hintText: "Additional Info(optional)".tr()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: mRed,
                                onPrimary: mYellow,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.7)),
                              ),
                              onPressed: () =>
                                  _newReport(context, reasonCtlr.text)
                                      .then((value) => Navigator.pop(context)),
                              child: Text("Report User".tr()),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Container(
          child: Column(
            children: <Widget>[
              Card(
                color: themeProvider.isDarkMode ? black : white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  Icons.security,
                  color: mRed,
                  size: 35,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Report User".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              Text(
                "Is this person bothering you? Tell us what they did.".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: !other
            ? <Widget>[
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text("Inappropriate Media".tr()),
                      leading: Icon(
                        Icons.camera_alt,
                        color: mRed,
                      ),
                      onTap: () => _newReport(context, "Inappropriate Media")
                          .then((value) => Navigator.pop(context))),
                ),
                Divider(
                  height: 1,
                ),
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text(
                        "Feels Like Spam".tr(),
                      ),
                      leading: Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.orange,
                      ),
                      onTap: () => _newReport(context, "Feels Like Spam")
                          .then((value) => Navigator.pop(context))),
                ),
                Divider(
                  height: 1,
                ),
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text(
                        "User is underage".tr(),
                      ),
                      leading: Icon(
                        Icons.call_missed_outgoing,
                        color: Colors.blue,
                      ),
                      onTap: () => _newReport(context, "User is underage")
                          .then((value) => Navigator.pop(context))),
                ),
                Divider(
                  height: 1,
                ),
                Material(
                  color: themeProvider.isDarkMode ? black : white,
                  child: ListTile(
                      title: Text(
                        "Other".tr(),
                      ),
                      leading: Icon(
                        Icons.report_problem,
                        color: Colors.green,
                      ),
                      onTap: () {
                        setState(() {
                          other = true;
                        });
                      }),
                ),
                Divider(
                  height: 1,
                ),
              ]
            : <Widget>[
                Material(
                    color: themeProvider.isDarkMode ? black : white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: reasonCtlr,
                            decoration: InputDecoration(
                                hintText: "Additional Info(optional)".tr()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: mRed,
                                onPrimary: mYellow,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.7)),
                              ),
                              onPressed: () =>
                                  _newReport(context, reasonCtlr.text)
                                      .then((value) => Navigator.pop(context)),
                              child: Text("Report User".tr()),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
      );
    }
  }

  Future _newReport(context, String reason) async {
    if (widget.typeOfReport == TypeOfReport.video) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      print(widget.mediaID);
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "video",
          'url': widget.url,
          'thumbnailUrl': widget.thumbnailUrl,
          'mediaID': widget.mediaID,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'docID': id,
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.storyVideo) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "storyVideo",
          'url': widget.url,
          'thumbnailUrl': widget.thumbnailUrl,
          'mediaID': widget.mediaID,
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.image) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "image",
          'url': widget.url,
          'mediaID': widget.mediaID,
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.storyImage) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "storyImage",
          'url': widget.url,
          'mediaID': widget.mediaID,
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.profile) {
      String docId = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(docId).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "profile",
          'timestamp': FieldValue.serverTimestamp(),
          'docID': docId,
          'isRead': false
        }).then((value) {
          print(docId);
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.poll) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "poll",
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'mediaID': widget.mediaID,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.post) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "post",
          'mediaID': widget.mediaID,
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    } else if (widget.typeOfReport == TypeOfReport.explorePlan) {
      String id = FirebaseFirestore.instance.collection("Reports").doc().id;
      try {
        await FirebaseFirestore.instance.collection("Reports").doc(id).set({
          'reported_by': widget.currentUserUID,
          'victim_id': widget.secondUserUID,
          'reason': reason,
          'type': "Explore Plan",
          'timestamp': FieldValue.serverTimestamp(),
          'docID': id,
          'mediaID': widget.mediaID,
          'isRead': false
        }).then((value) {
          FirebaseFirestore.instance.collection("Reports").doc("count").update({
            "isRead": false,
            "new": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          });
        });
      } catch (e) {
        print('error in reporting $e');
      }
    }

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
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
                        "Reported".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 17,
                            color: mRed),
                      )
                    ],
                  )));
        });
  }
}
