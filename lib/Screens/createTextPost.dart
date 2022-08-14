import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/provider/global_posts/model/textPostModel.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import '../variables.dart';

class createTextPost extends StatefulWidget {
  VoidCallback callback;

  createTextPost(this.callback);

  @override
  _createTextPostState createState() => _createTextPostState();
}

class _createTextPostState extends State<createTextPost> {
  TextEditingController questionController = TextEditingController();
  bool anonymously = false;
  String textPost, createdBy, postId;
  Timestamp createdAt;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FirebaseController _firebaseController = FirebaseController();
  double _screenWidth;

  void publishPost() {
    //todo
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      String postId = const Uuid().v1();
      TextPostModel _TexPostModel = TextPostModel(
        commentsCount: 0,
        likesCount: 0,
        textPost: questionController.text,
        createdBy: _firebaseController.currentFirebaseUser.uid,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        anonymously: anonymously,
        postId: postId,
        type: "post",
      );

      _firebaseController.postColReference
          .doc(postId)
          .set(_TexPostModel.toMap())
          .then((value) {
        widget.callback();
        Fluttertoast.showToast(
            msg: "Post Published Successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        questionController.clear();

        Navigator.of(context).pop();
      }).catchError((e) {
        print(e);
        Fluttertoast.showToast(
            msg: "Post Published Failed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mRed,
          title: Text("Create Post".tr()),
          centerTitle: true,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: buildValidationTextFormField(
                        context: context,
                        controller: questionController,
                        hintText:
                            "Type whatever you want Ask/Confess/Share here..."
                                .tr(),
                        maxLength: 501,
                        maxLine: 5,
                        validator: _validateQuestion,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    //todo name and pic functionality
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: mRed,
                              value: anonymously,
                              onChanged: (bool newValue) {
                                setState(() {
                                  anonymously = newValue;
                                });
                              },
                            ),
                            GestureDetector(
                                onLongPress: () {},
                                child: Text("Post Anonymously.".tr()))
                          ],
                        )),

                    SizedBox(
                      height: 20.0,
                    ),

                    Tooltip(
                      message: "Publish".tr(),
                      preferBelow: false,
                      child: ElevatedButton(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text("Publish".tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: _screenWidth >= miniScreenWidth
                                        ? 22
                                        : 18,
                                    fontWeight: FontWeight.bold))),
                        onPressed: publishPost,
                        style: ElevatedButton.styleFrom(
                          primary: mRed,
                          onPrimary: white,
                          elevation: 3,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 60.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
    );
  }

  TextFormField buildValidationTextFormField({
    @required BuildContext context,
    @required TextEditingController controller,
    @required String hintText,
    @required int maxLength,
    validator(String value),
    int maxLine,
    TextInputType keyboard,
    double fontSize = 16.0,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLine,
      keyboardType: TextInputType.name,
      style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: fontSize),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: lRed)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: mRed, width: 3)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: mRed)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: mRed, width: 3)),
        hintText: hintText,
      ),
      buildCounter: (context, {currentLength, isFocused, maxLength}) {
        int utf8Length = utf8.encode(controller.text).length;

        return Container(
          child: Text(
            '$utf8Length/$maxLength',
            style: Theme.of(context).textTheme.caption,
          ),
        );
      },
      inputFormatters: [
        Utf8LengthLimitingTextInputFormatter(maxLength),
      ],
    );
  }

  String _validateQuestion(String value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return "Must be [a-z] only and minimum 10 letters".tr();
    }
    return null;
  }
}
