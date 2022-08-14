import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/UploadMedia/UploadImages/uplopad_videosFirebase.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfirmVideo extends StatefulWidget {
  final File videofile;
  final ImageSource imageSource;
  final String videoFrom;
  final Function callback;

  ConfirmVideo(
      {@required this.videofile,
      @required this.imageSource,
      @required this.videoFrom,
      this.callback});

  @override
  _ConfirmVideo createState() => _ConfirmVideo();
}

class _ConfirmVideo extends State<ConfirmVideo> {
  //double _maxScreenWidth;
  bool uploading = false;
  VideoPlayerController _controller;

  User currentUserRef;
  FirebaseController firebaseController = FirebaseController();
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = VideoPlayerController.file(widget.videofile);
    });
    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();
    currentUserRef = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<File> compressVideo() async {
    if (widget.imageSource == ImageSource.gallery) {
      return widget.videofile;
    } else {
      final compressedvideo = await VideoCompress.compressVideo(
          widget.videofile.path,
          quality: VideoQuality.MediumQuality);
      return File(compressedvideo.path);
    }
  }

  Future<File> getPreviewImage() async {
    File previewImage = await VideoCompress.getFileThumbnail(
      widget.videofile.path,
    );
    return previewImage;
  }

  Future<void> uploadVideo() async {
    String uid = currentUserRef.uid;
    File thumbnailImage = await getPreviewImage();
    if (widget.videoFrom == "normal") {
      //Normal Video
      try {
        await VideoController()
            .uploadVideo(
                uid: uid,
                videoPath: widget.videofile.path,
                thumbnail: thumbnailImage)
            .then((String videoPath) async {
          if (videoPath != null) {
            String videoThumbNailPath =
                await VideoController().uploadThumbNail(thumbnailImage, uid);
            if (videoThumbNailPath != null) {
              bool data = await getUserData(videoPath, videoThumbNailPath);
              if (data) {
                uploading = false;
                setState(() {});
                widget.callback(true);
              }
            }
          }
        });
      } catch (e) {
        uploading = false;
        setState(() {});
        print(e.toString());
      }
    } else {
      print("Other video uploaded");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? black : white,
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
                    fontSize: 15,
                  ),
                ),
                onPressed: !uploading
                    ? () async {
                        setState(() {
                          uploading = true;
                        });
                        if (_controller.value.isInitialized) {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          }
                        } // pause
                        uploadVideo();
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
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            //show videos in this container that what u are uploading
                            SizedBox(
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: Stack(
                                  children: [
                                    VideoPlayer(_controller),
                                    _ControlsOverlay(_controller),
                                    //AspectRatioVideo(_controller),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<bool> getUserData(String urls, String thumbNailUrls) async {
    var uniqueId = uuid.v1();
    bool isGetUserData = false;
    var videoData = await firebaseController.userColReference
        .doc(currentUserRef.uid)
        .collection(videosCollectionName)
        .get();
    if (videoData.docs.isEmpty) {
      await firebaseController.userColReference
          .doc(currentUserRef.uid)
          .collection(videosCollectionName)
          .doc(currentUserRef.uid)
          .set({
        "videos": [
          {
            "video": urls,
            'thumbnail': thumbNailUrls,
            "id": uniqueId,
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            "createdBy": currentUserRef.uid,
          }
        ],
      });
      isGetUserData = true;
    } else if (videoData.docs.length > 0) {
      QuerySnapshot videosurl = await firebaseController.userColReference
          .doc(currentUserRef.uid)
          .collection(videosCollectionName)
          .get();
      List<Map<String, dynamic>> list = [];
      videoData.docs.forEach((element) {
        var data = element["videos"];
        data.forEach((e) {
          list.add(e);
        });
      });
      if (list.length < 20) {
        {
          list.add({
            "video": urls,
            'thumbnail': thumbNailUrls,
            "id": uniqueId,
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            "createdBy": currentUserRef.uid,
          });

          await firebaseController.userColReference
              .doc(currentUserRef.uid)
              .collection(videosCollectionName)
              .doc(currentUserRef.uid)
              .set({
            "videos": list,
          }).catchError((e) {
            print(e.toString());
          });
        }
        if (mounted) {
          setState(() {});
        }
        isGetUserData = true;
        Navigator.pop(context);
      } else {
        isGetUserData = false;
        Fluttertoast.showToast(
            msg: "Can't upload more than 20 videos",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: mRed,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pop(context);
        /* Navigator.of(context).popUntil(ModalRoute.withName('/page1'));*/
      }
    }
    Navigator.pop(context);
    return isGetUserData;
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.isInitialized) {
      initialized = controller.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay(this.controller);

  final VideoPlayerController controller;

  @override
  __ControlsOverlayState createState() => __ControlsOverlayState();
}

class __ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? null
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
            setState(() {});
          },
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                // const SizedBox(width: 10),
                //Text(getPosition()),
                const SizedBox(width: 8),
                Expanded(child: buildIndicator()),
                const SizedBox(width: 12),

                const SizedBox(width: 8),
              ],
            )),
      ],
    );
  }

  Widget buildIndicator() => Container(
        margin: EdgeInsets.all(8).copyWith(right: 0),
        height: 10,
        child: VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
        ),
      );
}
