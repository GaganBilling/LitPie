import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VideoScrollScaffold extends StatefulWidget {
  final int currentIndex;

  final bool hasBottomPadding;
  final bool enableGesture;

  final Widget page;
  final AppBar appBar;

  final Function() onPullDownRefresh;

  const VideoScrollScaffold({
    Key key,
    this.hasBottomPadding: false,
    this.page,
    this.currentIndex: 0,
    this.enableGesture,
    this.onPullDownRefresh,
    @required this.appBar,
  }) : super(key: key);

  @override
  _VideoScrollScaffoldState createState() => _VideoScrollScaffoldState();
}

class _VideoScrollScaffoldState extends State<VideoScrollScaffold>
    with TickerProviderStateMixin {
  AnimationController animationControllerX;
  AnimationController animationControllerY;
  Animation<double> animationX;
  Animation<double> animationY;
  double offsetX = 0.0;
  double offsetY = 0.0;
  double inMiddle = 0;

  @override
  void initState() {
    super.initState();
  }

  double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    Widget body = _MiddlePage(
      absorbing: absorbing,
      onTopDrag: () {
        // absorbing = true;
        setState(() {});
      },
      offsetX: offsetX,
      offsetY: offsetY,
      isStack: !widget.hasBottomPadding,
      page: widget.page,
    );

    body = WillPopScope(
      onWillPop: () async {
        if (!widget.enableGesture) return true;
        if (inMiddle == 0) {
          return true;
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: widget.appBar,
          body: body,
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
    return body;
  }

  /// [offsetY] to 0.0
  Future animateToTop() {
    animationControllerY = AnimationController(
        duration: Duration(milliseconds: offsetY.abs() * 1000 ~/ 60),
        vsync: this);
    final curve = CurvedAnimation(
        parent: animationControllerY, curve: Curves.easeOutCubic);
    animationY = Tween(begin: offsetY, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetY = animationY.value;
        });
      });
    return animationControllerY.forward();
  }

  CurvedAnimation curvedAnimation() {
    animationControllerX = AnimationController(
        duration: Duration(milliseconds: max(offsetX.abs(), 60) * 1000 ~/ 500),
        vsync: this);
    return CurvedAnimation(
        parent: animationControllerX, curve: Curves.easeOutCubic);
  }

  Future animateTo([double end = 0.0]) {
    final curve = curvedAnimation();
    animationX = Tween(begin: offsetX, end: end).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = end;
    return animationControllerX.animateTo(1);
  }

  bool absorbing = false;
  double endOffset = 0.0;

  void calculateOffsetY(DragUpdateDetails details) {
    if (!widget.enableGesture) return;
    if (inMiddle != 0) {
      setState(() => absorbing = false);
      return;
    }
    final tempY = offsetY + details.delta.dy / 2;
    if (widget.currentIndex == 0) {
      // absorbing = true //TODO: Pull to refresh temporarily blocked
      if (tempY > 0) {
        if (tempY < 40) {
          offsetY = tempY;
        } else if (offsetY != 40) {
          offsetY = 40;
          // vibrate();
        }
      } else {
        absorbing = false;
      }
      setState(() {});
    } else {
      absorbing = false;
      offsetY = 0;
      setState(() {});
    }
    print(" io pop opopo   "+absorbing.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _MiddlePage extends StatelessWidget {
  final bool absorbing;
  final bool isStack;
  final Widget page;

  final double offsetX;
  final double offsetY;
  final Function onTopDrag;

  const _MiddlePage({
    Key key,
    this.absorbing,
    this.onTopDrag,
    this.offsetX,
    this.offsetY,
    this.isStack: false,
    this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget mainVideoList = Container(
      color: Colors.black, //background color
      child: page,
    );

    Widget middle = Transform.translate(
      offset: Offset(offsetX > 0 ? offsetX : offsetX / 5, 0),
      child: Stack(
        children: <Widget>[
          Container(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                mainVideoList,
                // tabBarContainer,
              ],
            ),
          ),
        ],
      ),
    );
    if (page is! PageView) {
      return middle;
    }
    return AbsorbPointer(
      absorbing: absorbing,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowGlow();
          return;
        },
        // } as bool Function(OverscrollIndicatorNotification),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            //When the finger leaves and is at the top, it intercepts the PageView sliding event,
            //TODO: No pull-to-refresh triggered
            if (notification.direction == ScrollDirection.idle &&
                notification.metrics.pixels == 0.0) {
              onTopDrag?.call();
              return false;
            }
            return true;
          },
          child: middle,
        ),
      ),
    );
  }
}
