import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:provider/provider.dart';

import '../variables.dart';

class PhotoBrowser extends StatefulWidget {
  final int visiblePhotoIndex;
  final List<Images> images;
  final CreateAccountData user;

  PhotoBrowser(
      {@required this.visiblePhotoIndex,
      @required this.images,
      @required this.user});

  @override
  _PhotoBrowserState createState() => _PhotoBrowserState();
}

class _PhotoBrowserState extends State<PhotoBrowser> {
  int visiblePhotoIndex;

  @override
  void initState() {
    super.initState();
    visiblePhotoIndex = widget.visiblePhotoIndex;
  }

  @override
  void didUpdateWidget(PhotoBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visiblePhotoIndex != oldWidget.visiblePhotoIndex) {
      setState(() {
        visiblePhotoIndex = widget.visiblePhotoIndex;
      });
    }
  }

  void _prevImage() {
    if (widget.images.length > 1) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex > 0 ? visiblePhotoIndex - 1 : 0;
    });
  }

  void _nextImage() {
    if (widget.images.length > 1) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex < widget.images.length - 1
          ? visiblePhotoIndex + 1
          : visiblePhotoIndex;
    });
  }

  Widget _buildPhotoControls() {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new GestureDetector(
          onTap: _prevImage,
          child: new FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topLeft,
            child: new Container(
              color: Colors.transparent,
            ),
          ),
        ),
        new GestureDetector(
          onTap: _nextImage,
          child: new FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topRight,
            child: new Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Photo
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.blueGrey,
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                  blurRadius: 3),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: themeProvider.isDarkMode ? dRed : white,
          ),
          height: MediaQuery.of(context).size.height * .78,
          width: MediaQuery.of(context).size.width,
          child: new ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: widget.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.images[visiblePhotoIndex].imageUrl ??
                        "",
                    fit: BoxFit.cover,
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) => CupertinoActivityIndicator(
                      radius: 20,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                : widget.user.profilepic == ""
                    ? Image.asset(
                        placeholderImage,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.user.profilepic,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
          ),
        ),
        // Photo indicator
        new Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: new SelectedPhotoIndicator(
            photoCount: widget.images.length,
            visiblePhotoIndex: visiblePhotoIndex,
          ),
        ),
        _buildPhotoControls(),
      ],
    );
  }
}

class SelectedPhotoIndicator extends StatelessWidget {
  final int photoCount;
  final int visiblePhotoIndex;

  SelectedPhotoIndicator({this.visiblePhotoIndex, this.photoCount});

  Widget _buildInactiveIndicator() {
    return new Expanded(
      child: new Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: new Container(
          height: 4.0,
          decoration: new BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.5),
              borderRadius: new BorderRadius.circular(2.5)),
        ),
      ),
    );
  }

  Widget _buildActiveIndicator() {
    return new Expanded(
      child: new Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: new Container(
          height: 3.0,
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.circular(2.5),
              boxShadow: [
                new BoxShadow(
                    color: const Color(0x22000000),
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.0, 1.0))
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < photoCount; i++) {
      indicators.add(i == visiblePhotoIndex
          ? _buildActiveIndicator()
          : _buildInactiveIndicator());
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(0.0),
      child: new Row(
        children: _buildIndicators(),
      ),
    );
  }
}
