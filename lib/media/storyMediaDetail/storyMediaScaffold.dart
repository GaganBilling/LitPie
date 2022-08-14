import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double scrollSpeed = 300;

class StoryMediaScaffold extends StatefulWidget {
  final int currentIndex;

  final bool hasBottomPadding;
  final bool enableGesture;

  final Widget page;
  final AppBar appBar;

  final Function() onPullDownRefresh;

  const StoryMediaScaffold({
    Key key,
    this.hasBottomPadding: false,
    this.page,
    this.currentIndex: 0,
    this.enableGesture,
    this.onPullDownRefresh,
    @required this.appBar,
  }) : super(key: key);

  @override
  _StoryMediaScaffoldState createState() => _StoryMediaScaffoldState();
}

class _StoryMediaScaffoldState extends State<StoryMediaScaffold>
    with TickerProviderStateMixin {
  AnimationController animationControllerX;
  AnimationController animationControllerY;
  Animation<double> animationX;
  Animation<double> animationY;
  double offsetX = 0.0;
  double offsetY = 0.0;
  int currentIndex = 0;
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

    // body = GestureDetector(
    //   onVerticalDragUpdate: calculateOffsetY,
    //   onVerticalDragEnd: (_) async {
    //     if (!widget.enableGesture) return;
    //     absorbing = false;
    //     if (offsetY != 0) {
    //       await animateToTop();
    //       // widget.onPullDownRefresh.call();
    //       setState(() {});
    //     }
    //   },
    //   child: body,
    // );

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
