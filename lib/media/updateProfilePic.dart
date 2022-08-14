import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Theme/theme_provider.dart';

class UpdateProfilepic extends StatefulWidget {
  ImageSource _imageSource;

  UpdateProfilepic(this._imageSource);

  @override
  _UpdateProfilepic createState() => _UpdateProfilepic();
}

class _UpdateProfilepic extends State<UpdateProfilepic>
    with SingleTickerProviderStateMixin {
  bool uploading = false;
  final _stoarge = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  bool storagePermission = true;

  // double _maxScreenWidth;
  File _image;
  String urls;

  @override
  void initState() {
    super.initState();
    _defaultPermission();
    chooseImage();
  }

  _defaultPermission() async {
    storagePermission = await Permission.storage.isGranted;
    //cameraPermission = await Permission.camera.isGranted;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: !uploading
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: themeProvider.isDarkMode ? white : dRed,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : Container(),
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
                onPressed: !uploading
                    ? () {
                        setState(() {
                          uploading = true;
                        });
                        _uploadImages().whenComplete(() {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav()));
                          setState(() {
                            print("Refresh");
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        });
                      }
                    : null,
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
      body: WillPopScope(
        onWillPop: () async {
          return !uploading;
        },
        child: uploading
            ? Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  color: Colors.black38,
                  // child: CircularProgressIndicator(),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Uploading...".tr()),
                        SizedBox(
                          height: 12.0,
                        ),
                        LinearProgressCustomBar(),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        if (_image != null)
                          Container(
                            // height: MediaQuery.of(context).size.height,
                            padding: EdgeInsets.all(20),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Image(
                                      image: FileImage(
                                          _image != null ? _image : _image),
                                      fit: BoxFit.fill),
                                ),
                              ),
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

  chooseImage() async {
    if (storagePermission) {
      final pickedImage = await ImagePicker()
          .pickImage(source: widget._imageSource, imageQuality: 60);

      if (pickedImage != null) {
        File croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedImage.path,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: Platform.isAndroid
                ? [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio5x3,
                    CropAspectRatioPreset.ratio5x4,
                    CropAspectRatioPreset.ratio7x5,
                    CropAspectRatioPreset.ratio16x9
                  ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: "Want to crop Image?".tr(),
                toolbarColor: Colors.blueGrey,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
                minimumAspectRatio: 1.0, title: "Want to crop Image?".tr()));
        if (croppedFile != null)
          setState(() {
            _image = File(croppedFile?.path);
          });
        if (croppedFile?.path != null) if (croppedFile?.path == null)
          retrieveLostData();
      }
    } else {
      await _askStoragePermission();
    }
  }

  Future<void> _askStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        storagePermission = true;
      });
      return Permission.storage.status;
    } else {
      setState(() {
        storagePermission = false;
      });
      //popup
      Future.delayed(Duration.zero, () {
        showDialog(
            barrierDismissible: false,
            context: this.context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Please Enable Storage Permission".tr()),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: mRed,
                            onPrimary: mYellow,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.7)),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            //openAppSetting
                            await openAppSettings();
                          },
                          child: Text("Open Settings".tr(),
                              style: TextStyle(fontSize: 20))),
                    ],
                  ));
            });
      });

      Fluttertoast.showToast(
          msg: "Please Enable Storage Permission".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return Permission.storage.status;
      //
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file.path);
      });
    } else {
      print(response.file);
    }
  }

  _uploadImages() async {
    if (_image != null) {
      var _ref = await _stoarge
          .ref()
          .child(auth.currentUser.uid)
          .child("profilepic/" + basename(_image.path));
      await _ref.putFile(_image);
      urls = await _ref.getDownloadURL();
      setState(() {});

      print("uploading:" + urls);
      Fluttertoast.showToast(
          msg: "Updated".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.uid)
          .set({'profilepic': urls}, SetOptions(merge: true)).then((_) {
        print("pic uploded");
      });
    }
  }
}
