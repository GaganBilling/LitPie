import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/variables.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ImageDetail extends StatefulWidget {
  final UserImagesModel imagesModel;
  final int currentIndex;

  ImageDetail(
      {Key key, @required this.imagesModel, @required this.currentIndex})
      : super(key: key);

  @override
  _ImageDetail createState() => _ImageDetail();
}

class _ImageDetail extends State<ImageDetail> {
  int _currentIndex;
  PageController _pageController;

  FirebaseController _firebaseController = FirebaseController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SafeArea(child: _buildContent(context))),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        int sensitivity = 30;
        if (details.delta.dy > sensitivity) {
          // Down Swipe
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          InteractiveViewer(
            child: _buildPhotoViewGallery(),
            panEnabled: false, // Set it to false to prevent panning.
            // boundaryMargin: EdgeInsets.all(80),
            minScale: 1,
            maxScale: 4,
          ),
          _buildIndicator(),
          _deleteImage(context), // add report sign here
          _cancelBtn(context),
        ],
      ),
    );
  }

  Widget _deleteImage(BuildContext context) {
    return Positioned(
      right: 2,
      top: 7,
      child: _firebaseController.userColReference
                  .doc(_firebaseController.currentFirebaseUser.uid)
                  .collection(imagesCollectionName)
                  .where("uid",
                      isEqualTo: _firebaseController.currentFirebaseUser.uid)
                  .get() !=
              null
          ? deleteBtn(context)
          : reportIconButton(),
    );
  }

  Widget _cancelBtn(BuildContext context) {
    return Positioned(
      left: -5,
      top: -9,
      child: Cancelbtn(),
    );
  }

  Widget _buildIndicator() {
    return Positioned(
      bottom: 2.0,
      left: 2.0,
      right: 2.0,
      // child: _buildDot(),
      child: _buildDottedIndicator(),
    );
  }

  Row _buildDottedIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // children: widget.imagesModel.images
      children: widget.imagesModel.images
          .map<Widget>((img) => _buildDot(img))
          .toList(),
    );
  }

  Container _buildDot(Images currentImage) {
    return Container(
      width: 5,
      height: 5,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: new BoxDecoration(
          color:
              _currentIndex == widget.imagesModel.images.indexOf(currentImage)
                  ? Colors.red
                  : Colors.white,
          borderRadius: new BorderRadius.circular(2.5),
          boxShadow: [
            new BoxShadow(
                color: Colors.red,
                blurRadius: 10.0,
                spreadRadius: 0.0,
                offset: const Offset(0.0, 1.0))
          ]),
    );
  }

  PhotoViewGallery _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      itemCount: widget.imagesModel.images.length,
      // itemCount: widget.imagesModel.length,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider:
              NetworkImage(widget.imagesModel.images[index].imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
        );
      },
      scrollPhysics: const BouncingScrollPhysics(),
      pageController: _pageController,
      onPageChanged: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      scrollDirection: Axis.horizontal,
    );
  }

  IconButton reportIconButton() {
    return IconButton(
        icon: Icon((CupertinoIcons.flag), size: 25, color: Colors.blueGrey),
        onPressed: () {});
  }

  Widget deleteBtn(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    //final auth = FirebaseAuth.instance;
    return IconButton(
        icon: Icon(
          (CupertinoIcons.delete),
          color: Colors.blueGrey,
          size: 25,
        ),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: themeProvider.isDarkMode
                        ? black.withOpacity(.5)
                        : white.withOpacity(.5),
                    content: Container(
                      // height: MediaQuery.of(context).size.height / 5,
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
                                if (mounted)
                                  setState(() {
                                    if (widget.imagesModel
                                            .images[_currentIndex] !=
                                        null) {
                                      var result = widget.imagesModel.images
                                          .remove(widget.imagesModel
                                              .images[_currentIndex]);
                                      var dataList = [];
                                      if (widget.imagesModel.images.length >
                                          0) {
                                        print('sfdksndf sdf');
                                        print(widget.imagesModel.images.length);
                                       // UserImagesModel sd = UserImagesModel.fromJson(widget.imagesModel.images);
                                        widget.imagesModel.images
                                            .forEach((element) async {
                                              print(element.toJson());
                                        //  dataList.add(element);
                                              dataList= widget.imagesModel.images.map((v) => v.toJson()).toList();
                                          print(dataList.length);
                                          print(result);
                                          if (result == true) {
                                            print("inside 2");
                                            print(dataList.toString());
                                            _firebaseController.userColReference
                                                .doc(_firebaseController
                                                    .currentFirebaseUser.uid)
                                                .collection(
                                                    imagesCollectionName)
                                                .doc(_firebaseController
                                                    .currentFirebaseUser.uid)
                                                .set({"images": dataList.toList()});
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Image Deleted Successfully!!"
                                                        .tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        });
                                      } else {
                                        _firebaseController.userColReference
                                            .doc(_firebaseController
                                                .currentFirebaseUser.uid)
                                            .collection(imagesCollectionName)
                                            .doc(_firebaseController
                                                .currentFirebaseUser.uid)
                                            .update({"images": []});
                                        Navigator.of(context).pop();
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Images Deletion Failed!!".tr(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.blueGrey,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      Navigator.of(context).pop();
                                    }
                                    if(widget.imagesModel.images.length !=
                                        0) {
                                      Navigator.of(context).pop();
                                    }

                                    //API
                                  });

                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Delete".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
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
                              child: Text(
                                "Cancel".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary:
                                    themeProvider.isDarkMode ? mBlack : white,
                                onPrimary: Colors.blue[700],
                                //  padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.7)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
        });
  }
}

class Cancelbtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(15.0),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.blueGrey,
          size: 25,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
