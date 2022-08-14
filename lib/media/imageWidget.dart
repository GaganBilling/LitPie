import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String imageList;
  final VoidCallback onImageTap;

  const ImageWidget(
      {Key key, @required this.imageList, @required this.onImageTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey,
            offset: Offset(2, 2),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: NetworkImage(imageList),
            fit: BoxFit.cover,
            child: InkWell(onTap: onImageTap),
          ),
        ),
      ),
    );
  }
}
