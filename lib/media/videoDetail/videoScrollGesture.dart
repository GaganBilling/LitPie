import 'dart:async';

import 'package:flutter/material.dart';

class VideoScrollGesture extends StatefulWidget {
  const VideoScrollGesture({
    Key key,
    @required this.child,
    this.onSingleTap,
  }) : super(key: key);

  final Function onSingleTap;
  final Widget child;

  @override
  _VideoScrollGestureState createState() => _VideoScrollGestureState();
}

class _VideoScrollGestureState extends State<VideoScrollGesture> {
  GlobalKey _key = GlobalKey();

  Offset _p(Offset p) {
    RenderBox getBox = _key.currentContext.findRenderObject() as RenderBox;
    return getBox.globalToLocal(p);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        widget.onSingleTap().call();
        setState(() {});
      },
      child: Stack(
        children: <Widget>[
          widget.child,
        ],
      ),
    );
  }
}
