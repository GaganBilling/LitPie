import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/media/updatePlanPlacePic.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class PlanplacepicPicScreen extends StatefulWidget {
  final User currentUser;
  Function uploadPic;

  PlanplacepicPicScreen({this.currentUser, this.uploadPic});

  @override
  _PlanplacepicPicScreen createState() => _PlanplacepicPicScreen();
}

class _PlanplacepicPicScreen extends State<PlanplacepicPicScreen> {
  String planplacepic;

  bool dataisthere = false;

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("users");
  final FirebaseAuth auth = FirebaseAuth.instance;

  CreateAccountData accountData;

  final _transformationController = TransformationController();
  TapDownDetails _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      if (!mounted) return;
      setState(() {
        planplacepic = value == null ? "" : value.planplacepic;
        accountData = value;
        dataisthere = true;
      });
    });
  }

  Future<CreateAccountData> getUser() async {
    final User user = auth.currentUser;
    return FirebaseFirestore.instance
        .collection("Plans")
        .where("pdataOwnerID", isEqualTo: auth.currentUser.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.docs[0].data()))
        .catchError((e) {
      return null;
    });
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? white : dRed,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: dataisthere == false
          ? Center(child: LinearProgressCustomBar())
          : SingleChildScrollView(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 10, right: 10, bottom: 20),
                          child: Container(
                            height: _screenWidth >= miniScreenWidth
                                ? MediaQuery.of(context).size.height * .70
                                : MediaQuery.of(context).size.height * .60,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: AspectRatio(
                                    aspectRatio: 1,
                                    child: accountData != null &&
                                            accountData.planplacepic != null &&
                                            accountData.planplacepic.isNotEmpty
                                        ? InteractiveViewer(
                                            transformationController:
                                                _transformationController,
                                            panEnabled: false,
                                            // Set it to false to prevent panning.
                                            // boundaryMargin: EdgeInsets.all(80),
                                            minScale: 1,
                                            maxScale: 4,
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl:
                                                  accountData.planplacepic,
                                              useOldImageOnUrlChange: true,
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(
                                                radius: 15,
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
                                                    size: 30,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                            Icons.image_outlined,
                                            size:
                                                _screenWidth >= miniScreenWidth
                                                    ? 350
                                                    : 280,
                                            color:
                                                Colors.blueGrey.withOpacity(.5),
                                          ))
                                    // Image.asset(placeholderImage,
                                    //     fit: BoxFit.cover),
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        accountData != null &&
                                accountData.planplacepic != null &&
                                accountData.planplacepic.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: "Update".tr(),
                                    preferBelow: false,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdatePlanPlacePic()));
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 150.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mRed,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 90
                                                    : 80,
                                              ),
                                              child: Text(
                                                "Update".tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16, color: white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Tooltip(
                                    message: "Delete".tr(),
                                    preferBelow: false,
                                    child: InkWell(
                                      onTap: () {
                                        showoptionsdialog();
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 150.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mRed,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.delete_simple,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 90
                                                    : 80,
                                              ),
                                              child: Text(
                                                "Delete".tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16, color: white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: "Update".tr(),
                                    preferBelow: false,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdatePlanPlacePic()));
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 150.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mRed,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 90
                                                    : 80,
                                              ),
                                              child: Text(
                                                "Update".tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16, color: white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  onVerticalDragUpdate: (details) {
                    int sensitivity = 20;
                    if (details.delta.dy > sensitivity) {
                      // Down Swipe
                      Navigator.pop(context);
                    }
                  },
                  onDoubleTapDown: _handleDoubleTapDown,
                  onDoubleTap: _handleDoubleTap,
                ),
              ),
            ),
    );
  }

  void deletePic() async {
    if (planplacepic != null || planplacepic == "") {
      try {
        firebase_storage.Reference photoRef = await firebase_storage
            .FirebaseStorage.instance
            .ref()
            .storage
            .refFromURL(planplacepic);
        print(photoRef.fullPath);
        await photoRef.delete();
      } catch (e) {
        print(e);
      }
    }
    _uploadImages();
  }

  _uploadImages() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser.uid)
        .collection("plans")
        .doc(auth.currentUser.uid)
        .set({'planplacepic': ""}, SetOptions(merge: true)).then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Photo Deleted".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  showoptionsdialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: themeProvider.isDarkMode
                ? black.withOpacity(.5)
                : white.withOpacity(.5),
            content: Container(
              //height: MediaQuery.of(context).size.height / 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are You Sure?".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 30, right: 30),
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        deletePic();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          "Delete".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: mRed,
                        onPrimary: white,
                        // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 30, right: 30),
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          "Cancel".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: themeProvider.isDarkMode ? mBlack : white,
                        onPrimary: Colors.blue[700],
                        // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
