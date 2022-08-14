import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../../../variables.dart';

class RTChatLargeImage extends StatefulWidget {
  final largeImage;

  RTChatLargeImage(this.largeImage);

  @override
  _RTChatLargeImage createState() => _RTChatLargeImage();
}

class _RTChatLargeImage extends State<RTChatLargeImage>
    with SingleTickerProviderStateMixin {
  //double _maxScreenWidth;
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: themeProvider.isDarkMode ? black : black,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: themeProvider.isDarkMode ? black : black,
          child: Center(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                int sensitivity = 20;
                if (details.delta.dy > sensitivity) {
                  // Down Swipe
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height * .70,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: widget.largeImage != null
                          ? InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              panEnabled: false,
                              // Set it to false to prevent panning.
                              minScale: 1,
                              maxScale: 4,
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: widget.largeImage,
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) =>
                                    CupertinoActivityIndicator(
                                  radius: 15,
                                ),
                                errorWidget: (context, url, error) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          : Image.asset(placeholderImage, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
