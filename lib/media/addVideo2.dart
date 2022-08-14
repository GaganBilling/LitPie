import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/media/ConfirmVideo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class AddVideo2 extends StatefulWidget {
  final String videoFrom;
  final Function callback;

  const AddVideo2({Key key, @required this.videoFrom, this.callback})
      : super(key: key);

  @override
  _AddVideo2 createState() => _AddVideo2();
}

class _AddVideo2 extends State<AddVideo2> {
  bool storagePermission = true;

  _defaultPermission() async {
    storagePermission = await Permission.storage.isGranted;
  }

  Future pickVideo(ImageSource source) async {
    if (storagePermission) {
      await ImagePicker()
          .pickVideo(source: source, maxDuration: Duration(seconds: 61))
          .then((video) async {
        if (video != null) {
          VideoPlayerController testLength =
              new VideoPlayerController.file(File(video.path));
          await testLength.initialize();
          if (widget.videoFrom == "normal") {
            if (testLength.value.duration.inSeconds > 61) {

              Fluttertoast.showToast(
                  msg: "Video must be less than 60 Seconds".tr(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConfirmVideo(
                            videofile: File(video.path),
                            imageSource: source,
                            videoFrom: widget.videoFrom,
                            callback: (value) {
                              if(value!=null && value) {
                                widget.callback(value);
                              }
                            },
                          ))).whenComplete(() {});
            }
          } else {
            if (testLength.value.duration.inSeconds > 31) {
              video = null;
              Fluttertoast.showToast(
                  msg: "Video must be less than 30 Seconds".tr(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConfirmVideo(
                            videofile: File(video.path),
                            imageSource: source,
                            videoFrom: widget.videoFrom,
                            callback: (value) {
                              if(value!=null && value) {
                                widget.callback(value);
                              }
                            },
                          )));
            }
          }
        } else {
          Fluttertoast.showToast(
              msg: "No Video Selected!!".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }

      }).catchError((err) {
        print("Pick Video Error: $err");
        //something went wrong, try another video file
        Fluttertoast.showToast(
            msg: "Something went wrong, try another video!!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    } else {
      await _askStoragePermission(context: context);
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

  @override
  void initState() {
    super.initState();
    _defaultPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.image_search,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      label: Text(
                        "Open Gallery".tr(),
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () => pickVideo(ImageSource.gallery)
                          .then((value) {
                        widget.callback(value);
                      }),
                      style: ElevatedButton.styleFrom(
                        primary: mRed,
                        onPrimary: white,
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                if (widget.videoFrom == "normal")
                  Center(
                    child: Text(
                      "Pick Video which is 60 seconds or less.".tr(),
                      style: TextStyle(
                          //fontFamily: 'Handlee',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: lRed),
                    ),
                  ),
                if (widget.videoFrom == "story")
                  Center(
                    child: Text(
                      "Pick Video which is 30 seconds or less.".tr(),
                      style: TextStyle(
                          // fontFamily: 'Handlee',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: lRed),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
