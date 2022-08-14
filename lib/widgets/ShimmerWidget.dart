import 'package:flutter/material.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    @required this.width,
    @required this.height,
  }) : this.shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    @required this.width,
    @required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: shapeBorder,
        color: Colors.grey,
      ),
      width: width,
      height: height,
    );
  }
}
