import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/media/updateProfilePic.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePicScreen extends StatefulWidget {
  final User currentUser;

  ProfilePicScreen({this.currentUser});

  @override
  _ProfilePicScreenState createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends State<ProfilePicScreen> {
  String profilepic;
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
        profilepic = value.profilepic;
        accountData = value;
        dataisthere = true;
      });
    });
  }

  Future<CreateAccountData> getUser() async {
    final User user = auth.currentUser;
    return _reference
        .doc(user.uid)
        .get()
        .then((m) => CreateAccountData.fromDocument(m.data()));
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mRed,
        actions: [
          Tooltip(
            message: "Update".tr(),
            preferBelow: false,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                updateProfilePicture();
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 150.0,
                ),
                decoration: BoxDecoration(
                  color: mRed,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
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
                  borderRadius: BorderRadius.circular(100.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                child: Icon(
                  CupertinoIcons.delete_simple,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: accountData.profilepic.isNotEmpty
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
                                            imageUrl: accountData.profilepic,
                                            useOldImageOnUrlChange: true,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              radius: 15,
                                            ),
                                            errorWidget:
                                                (context, url, error) => Column(
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
                                      : Image.asset(placeholderImage,
                                          fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
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
                    // else if(details.delta.dy < -sensitivity){
                    //   // Up Swipe
                    // }
                  },
                  onDoubleTapDown: _handleDoubleTapDown,
                  onDoubleTap: _handleDoubleTap,
                ),
              ),
            ),
    );
  }

  void deletePic() async {
    if (profilepic != null || profilepic == "") {
      try {
        firebase_storage.Reference photoRef = await firebase_storage
            .FirebaseStorage.instance
            .ref()
            .storage
            .refFromURL(profilepic);
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
        .set({'profilepic': ""}, SetOptions(merge: true)).then((_) {
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

  updateProfilePicture() {
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
                    "Update Profile Picture".tr(),
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
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _screenWidth >= miniScreenWidth ? 220 : 180,
                        ),
                        child: Text(
                          "Camera".tr(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 16 : 14),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) =>
                                    UpdateProfilepic(ImageSource.camera)))
                            .whenComplete(() => getUser().then((value) {
                                  if (!mounted) return;
                                  setState(() {
                                    profilepic = value.profilepic;
                                    accountData = value;
                                    dataisthere = true;
                                  });
                                }));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: mRed,
                        onPrimary: white,
                        // padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
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
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _screenWidth >= miniScreenWidth ? 220 : 180,
                        ),
                        child: Text(
                          "Gallery".tr(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize:
                                  _screenWidth >= miniScreenWidth ? 16 : 14),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) =>
                                    UpdateProfilepic(ImageSource.gallery)))
                            .whenComplete(() => getUser().then((value) {
                                  if (!mounted) return;
                                  setState(() {
                                    profilepic = value.profilepic;
                                    accountData = value;
                                    dataisthere = true;
                                  });
                                }));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: mRed,
                        onPrimary: white,
                        // padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
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

//   updateProfilePicture() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           String title = "Update Profile Picture";
//           return Dialog(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//               child: Wrap(children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             title,
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 18.0),
//                           ),
//                           GestureDetector(
//                             behavior: HitTestBehavior.translucent,
//                             onTap: () {
//                               Navigator.of(context, rootNavigator: false).pop();
//                             },
//                             child: Container(
//                               child: Icon(
//                                 Icons.clear,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Divider(),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                             onTap: () {
//                               Navigator.of(context)
//                                   .push(MaterialPageRoute(
//                                       builder: (context) =>
//                                           UpdateProfilepic(ImageSource.camera)))
//                                   .whenComplete(() => getUser().then((value) {
//                                         if (!mounted) return;
//                                         setState(() {
//                                           profilepic = value.profilepic;
//                                           accountData = value;
//                                           dataisthere = true;
//                                         });
//                                       }));
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Icon(Icons.camera),
//                                 ),
//                                 SizedBox(
//                                   width: 10.0,
//                                 ),
//                                 Container(child: Text("CAMERA")),
//                               ],
//                             )),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         GestureDetector(
//                             onTap: () {
//                               Navigator.of(context)
//                                   .push(MaterialPageRoute(
//                                       builder: (context) => UpdateProfilepic(
//                                           ImageSource.gallery)))
//                                   .whenComplete(() => getUser().then((value) {
//                                         if (!mounted) return;
//                                         setState(() {
//                                           profilepic = value.profilepic;
//                                           accountData = value;
//                                           dataisthere = true;
//                                         });
//                                       }));
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Icon(Icons.photo),
//                                 ),
//                                 SizedBox(
//                                   width: 10.0,
//                                 ),
//                                 Text("Gallery"),
//                               ],
//                             )),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10.0,
//                     ),
//                   ],
//                 ),
//               ]),
//             ),
//           );
//         });
//   }

}
