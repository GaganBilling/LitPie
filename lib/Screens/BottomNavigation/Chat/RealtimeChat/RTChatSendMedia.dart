import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/models/chatMessageModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';

class RTChatSendMedia extends StatefulWidget {
  final CreateAccountData sender;
  final String chatId;
  final CreateAccountData second;

  RTChatSendMedia(
      {@required this.sender, @required this.chatId, @required this.second});

  @override
  _RTChatSendMedia createState() => _RTChatSendMedia();
}

class _RTChatSendMedia extends State<RTChatSendMedia>
    with SingleTickerProviderStateMixin {
  bool uploading = false;
  final _storage = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  bool storagePermission = true;

  FirebaseDatabase realDB = new FirebaseDatabase();
  DatabaseReference userChatRef;

  // double _maxScreenWidth;
  File _image;
  String urls;

  @override
  void initState() {
    super.initState();
    userChatRef = realDB
        .reference()
        .child("chats")
        .child(widget.chatId)
        .child("messages");
    chooseImage(context: context);
  }

  _defaultPermission() async {
    storagePermission = await Permission.storage.isGranted;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _defaultPermission();

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
                  "SEND".tr(),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                onPressed: !uploading
                    ? () {
                        setState(() {
                          uploading = true;
                        });
                        _uploadImages();
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
      body: uploading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //  SizedBox(height: 200,),
                  Container(
                    child: Text(
                      "Sending...".tr(),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LinearProgressCustomBar(),
                ],
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
                              child: Image(
                                  image: FileImage(_image), fit: BoxFit.fill),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
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

  chooseImage({@required BuildContext context}) async {
    if (storagePermission) {
      final pickedImage = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 60);

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
      await _askStoragePermission(context: context);
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

  Future<void> _uploadImages() async {
    if (_image != null) {
      String url;
      int timestamp = new DateTime.now().millisecondsSinceEpoch;
      var _ref = _storage
          .ref()
          .child(auth.currentUser.uid)
          .child('chats/${widget.chatId}/img_' + timestamp.toString() + '.jpg');
      await _ref.putFile(_image).whenComplete(() async {
        await _ref.getDownloadURL().then((value) {
          url = value;
          print("Downloadable Url: $url");
        });
      });
      urls = url;
      await _sendImage(messageText: 'Photo', imageUrl: url).then((value) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Photo sent",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  Future<void> _sendImage({String messageText, String imageUrl}) async {
    DateTime now = await NTP.now();
    ChatMessageModel message = ChatMessageModel(
        receiverId: widget.second.uid,
        senderId: widget.sender.uid,
        senderName: widget.sender.name,
        text: messageText,
        imageUrl: imageUrl,
        isRead: false,
        liked: false,
        type: MessageType.image,
        createdAt: now.millisecondsSinceEpoch);

    userChatRef.push().set(message.toJson()).then((value) {}).catchError((e) {
      print("Send Text Error: $e");
      //TODO: toast something went wrong
    });
  }
}
