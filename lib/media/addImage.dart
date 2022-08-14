import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:litpie/Theme/colors.dart';
import 'dart:async';

import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

import '../controller/FirebaseController.dart';

class AddImages extends StatefulWidget {
  final ImageFrom imageFrom;
  final Function callback;

  AddImages({Key key, @required this.imageFrom, this.callback})
      : super(key: key);

  @override
  _AddImages createState() => _AddImages();
}

class _AddImages extends State<AddImages> with SingleTickerProviderStateMixin {
  bool uploading = false;
  final auth = FirebaseAuth.instance;

  // double _maxScreenWidth;
  File _image;
  List<String> urls = [];
  List<File> mutilpleImages = [];
  List<XFile> images = [];
  List<String> url = [];
  bool storagePermission = true;
  bool cameraPermission = true;
  FirebaseController firebaseController = FirebaseController();
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _defaultPermission();
  }

  _defaultPermission() async {
    storagePermission = await Permission.storage.isGranted;
    cameraPermission = await Permission.camera.isGranted;
    if (mounted) setState(() {});
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: ElevatedButton(
                  child: Text(
                    "SAVE".tr(),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: !uploading
                      ? () async {
                          setState(() {
                            uploading = true;
                          });
                          uploadMultipleImages();
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
            leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ))),
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
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: "Gallery".tr(),
                              preferBelow: false,
                              child: InkWell(
                                onTap: () async {
                                  if (!uploading) {
                                    images = await pickMutipleImages(
                                        context: context);
                                    if (images.isNotEmpty) {
                                      setState(() {});
                                    }
                                  }
                                } /*=> !uploading ? chooseImage(context: context) : null*/,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: _screenWidth >= miniScreenWidth
                                        ? 150
                                        : 130,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mRed,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_search,
                                        color: Colors.white,
                                        size: _screenWidth >= miniScreenWidth
                                            ? 22.0
                                            : 18,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                _screenWidth >= miniScreenWidth
                                                    ? 130
                                                    : 90,
                                          ),
                                          child: Text(
                                            "Gallery".tr(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 18
                                                    : 16,
                                                color: white),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Tooltip(
                              message: "Camera".tr(),
                              preferBelow: false,
                              child: InkWell(
                                onTap: () => !uploading
                                    ? chooseCamera(context: context)
                                    : null,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: _screenWidth >= miniScreenWidth
                                        ? 150
                                        : 130,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mRed,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: _screenWidth >= miniScreenWidth
                                            ? 22.0
                                            : 18,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                _screenWidth >= miniScreenWidth
                                                    ? 130
                                                    : 90,
                                          ),
                                          child: Text(
                                            "Camera".tr(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: _screenWidth >=
                                                        miniScreenWidth
                                                    ? 18
                                                    : 16,
                                                color: white),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Tooltip(
                        //         message: "Gallery".tr(),
                        //         preferBelow: false,
                        //         child: Container(
                        //           padding:  EdgeInsets.only(left: _screenWidth >= miniScreenWidth ? 30.0 : 20.0, right: 10.0),
                        //           child: ElevatedButton(
                        //
                        //             child: Row(
                        //               children: [
                        //                 Icon(Icons.image_search,color: Colors.white, size:_screenWidth >= miniScreenWidth ?  22.0:18,),
                        //                 SizedBox(width: 10,),
                        //                 Expanded(child: Text("Gallery".tr(),overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:_screenWidth >= miniScreenWidth ?  18:16),)),
                        //               ],
                        //             ),
                        //             onPressed: () => !uploading ? chooseImage(context: context) : null,
                        //             style: ElevatedButton.styleFrom(
                        //               primary: mRed,
                        //               onPrimary:  white,
                        //               padding: EdgeInsets.fromLTRB(
                        //                   _screenWidth >= miniScreenWidth ? 20.0 : 15.0, 15.0, _screenWidth >= miniScreenWidth ? 20.0 : 10.0, 10.0),
                        //               elevation: 5,
                        //               shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.circular(20.7)
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //
                        //     Expanded(
                        //       child: Tooltip(
                        //         message: "Camera".tr(),
                        //         preferBelow: false,
                        //         child: Container(
                        //           padding: EdgeInsets.only(left: 10.0, right:  _screenWidth >= miniScreenWidth ? 30.0 : 20.0),
                        //           child: ElevatedButton(
                        //            child: Row(
                        //              children: [
                        //                Icon(Icons.camera_alt_outlined,color: Colors.white, size: _screenWidth >= miniScreenWidth ?22.0:18,),
                        //                SizedBox(width: 10,),
                        //                Expanded(child: Text("Camera".tr(),overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ?  18:16),)),
                        //              ],
                        //            ),
                        //             onPressed: () => !uploading ? chooseCamera(context: context) : null,
                        //             style: ElevatedButton.styleFrom(
                        //               primary: mRed,
                        //               onPrimary:  white,
                        //               padding: EdgeInsets.fromLTRB(
                        //                   _screenWidth >= miniScreenWidth ? 20.0 : 15.0, 15.0, _screenWidth >= miniScreenWidth ? 20.0 : 10.0, 10.0),
                        //               elevation: 5,
                        //               shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.circular(20.7)
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),),
                        //
                        //   ],
                        // ),

                        if (images != null)
                          SingleChildScrollView(
                            child: Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              height: 500,
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        crossAxisCount: 2,
                                        childAspectRatio: 2 / 3),
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 8.0,
                                    right: 8.0,
                                    bottom: 8.0),
                                itemCount: images.length,
                                itemBuilder: (context, j) {
                                  List paths = [];
                                  images.map((e) {
                                    paths.add(e.path);
                                  }).toList();
/*
                                  if(paths.length>20){
                                    Fluttertoast.showToast( msg: "Only 20 Images aer uploded",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.blueGrey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }*/
                                  return Container(
                                      child: Image.file(File(paths[j]),
                                          fit: BoxFit.cover));
                                },
                              ),
                            ),
                          )
                        /*         Container(
                            margin: EdgeInsets.all(20.0),
                            width: double.infinity,
                            height: 400,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey,
                                  offset: Offset(2, 2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: Material(
                                color: Colors.transparent,
                                child: Image(image: FileImage(_image), fit: BoxFit.fill),
                              ),
                            ),
                          ),*/
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _askCameraPermission({@required BuildContext context}) async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        cameraPermission = true;
      });
    } else {
      setState(() {
        cameraPermission = false;
      });
      //popup
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text("Please Enable Camera Permission".tr()),
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
      Fluttertoast.showToast(
          msg: "Please Enable Camera Permission".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      //
    }
  }

  chooseCamera({@required BuildContext context}) async {
    if (cameraPermission) {
      final pickedImage = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 60);

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
      await _askCameraPermission(context: context);
    }
  }

  Future<void> _askStoragePermission({@required BuildContext context}) async {
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
      showDialog(
          barrierDismissible: false,
          context: context,
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

  Future<List<XFile>> pickMutipleImages(
      {@required BuildContext context}) async {
    List<XFile> images = await ImagePicker().pickMultiImage(imageQuality: 60);
    if (images != null) {
      return images;
    }
    return [];
  }

  Future uploadMultipleImages() async {
    if (images.length > 0) {
      images.forEach((element) {
        mutilpleImages.add(File(element.path));
      });
      if (mutilpleImages.length > 0 && mutilpleImages.length <= 20) {
        await ImageController()
            .upload(mutilpleImages, auth.currentUser.uid)
            .whenComplete(() {})
            .then((value) async {
          urls = value;
          uploading = false;
          var data = await getUserData();
          if(data!=null && data) {
            if (data != null) {
              Navigator.pop(context);
              widget.callback(true);
            }
          }else{
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Can't upload more than 20 images",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: mRed,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      } else {
        Fluttertoast.showToast(
            msg: "You can't upload more than".tr() +
                " $imageUploadLimit " +
                "Images!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        uploading = false;
      }
      print(urls);
    }
  }

  Future<bool> getUserData() async {

    bool isUpload = false;
    var imageData = await firebaseController.userColReference
        .doc(auth.currentUser.uid)
        .collection(imagesCollectionName)
        .get();
    if (imageData.docs.isEmpty) {
      List<Map<String,dynamic>> imageList=[];
      urls.forEach((element) {
        var uniqueId = uuid.v1();
        imageList.add({
          "image":element,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "id":uniqueId,
          "uid": auth.currentUser.uid
        });
      });
      await firebaseController.userColReference
          .doc(auth.currentUser.uid)
          .collection(imagesCollectionName)
          .doc(auth.currentUser.uid)
          .set({
        "images": imageList,
      });
      isUpload = true;
    } else if (imageData.docs.length > 0) {
      QuerySnapshot imagesurl = await firebaseController.userColReference
          .doc(auth.currentUser.uid)
          .collection(imagesCollectionName)
          .get();
      List<Map<String,dynamic>> imageList=[];
      imagesurl.docs.forEach((element) {
        var data = element["images"];
        if(data.length>0) {
          data.forEach((e) {
            imageList.add(e);
          });
        }
      });
      if (imageList.length < 20) {
        if(urls.length>0) {
          urls.forEach((element) {
            var uniqueId = uuid.v1();
            imageList.add({
              "image": element,
              "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
              "id": uniqueId,
              "uid": auth.currentUser.uid
            });
          });
        }
        await firebaseController.userColReference
            .doc(auth.currentUser.uid)
            .collection(imagesCollectionName)
            .doc(auth.currentUser.uid)
            .update({
          "images": imageList
        });
        isUpload = true;
      } else {
        isUpload = false;

      }
    }
    return isUpload;
  }
}
