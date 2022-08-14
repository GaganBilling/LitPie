import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class CreatePollScrenn extends StatefulWidget {
  VoidCallback callback;

  CreatePollScrenn(this.callback);

  @override
  _CreatePollScrennState createState() => _CreatePollScrennState();
}

class _CreatePollScrennState extends State<CreatePollScrenn> {
  FirebaseController _firebaseController = FirebaseController();

  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  TextEditingController option5Controller = TextEditingController();

  bool anonymously = false;
  String profilepic, name;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  List<String> durationList = [
    "1 " + "Day".tr(),
    "2 " + "Day".tr(),
    "3 " + "Day".tr(),
    "4 " + "Day".tr(),
    "5 " + "Day".tr(),
    "6 " + "Day".tr(),
    "7 " + "Day".tr()
  ];

  String defaultDurationValue;

  void clearTextController() {
    questionController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();
    option5Controller.clear();
    defaultDurationValue = null;
    if (mounted) setState(() {});
  }

  Timestamp getDuration(String itemValue) {
    int index = durationList.indexOf(itemValue) + 1;
    var today = DateTime.now();
    var duration = today.add(Duration(days: index));
    return Timestamp.fromDate(duration);
  }

  void publishPoll() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      String question = questionController.text.trimLeft();
      List<String> optionList = [];
      optionList.add(option1Controller.text.trimLeft());
      optionList.add(option2Controller.text.trimLeft());
      if (option3Controller.text.trim().isNotEmpty)
        optionList.add(option3Controller.text.trimLeft());
      if (option4Controller.text.trim().isNotEmpty)
        optionList.add(option4Controller.text.trimLeft());
      if (option5Controller.text.trim().isNotEmpty)
        optionList.add(option5Controller.text.trimLeft());

      try {
        var id = _firebaseController.postColReference.doc().id;
        var pollData = PollDataModel(
          pollQuestion: PollQuestion(
              question: question,
              createdBy: _firebaseController.currentFirebaseUser.uid,
              createdAt: Timestamp.now(),
              duration: getDuration(defaultDurationValue)),
          pollOption: List.generate(optionList.length,
              (index) => PollOption(option: optionList[index], voteCount: 0)),
          userWhoVoted: {},
          createdBy: _firebaseController.currentFirebaseUser.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: id,
          postId: id,
          type: "poll",
          anonymously: anonymously,
        ).toJson();
        // Map<String, dynamic> questionMap = PollQuestion(question: question, createdBy: _firebaseController.currentFirebaseUser.uid, createdAt: Timestamp.now()).toJson();
        // List<Map<String, dynamic>> optionsMap = List.generate(optionList.length, (index) => PollOption(option: optionList[index], voteCount: 0).toJson());
        // questionMap["options"] = optionsMap;
        print(pollData);
        await _firebaseController.postColReference
            .doc(id)
            .set(pollData)
            .then((value) {
          widget.callback();
          Fluttertoast.showToast(
              msg: "Poll Published Successfully!".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
          clearTextController();
          Navigator.of(context).pop();
        }).catchError((e) {
          print(e);
          Fluttertoast.showToast(
              msg: "Poll Published Failed!".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg: "Poll Published Failed!".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Poll".tr()),
          centerTitle: true,
          elevation: 0,
          backgroundColor: mRed,
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
                        hintText: "Type poll question here...".tr(),
                        maxLength: 201,
                        maxLine: 5,
                        validator: _validateQuestion,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    //Option 1
                    buildValidationTextFormField(
                        controller: option1Controller,
                        context: context,
                        maxLength: 51,
                        maxLine: 1,
                        hintText: "Type Option 1 here...".tr(),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Option 1 is required".tr();
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 10.0,
                    ),

                    //Option 2
                    buildValidationTextFormField(
                        controller: option2Controller,
                        context: context,
                        maxLength: 51,
                        maxLine: 1,
                        hintText: "Type Option 2 here...".tr(),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Option 2 is required".tr();
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 10.0,
                    ),

                    //Option 3
                    buildValidationTextFormField(
                      controller: option3Controller,
                      context: context,
                      maxLength: 51,
                      maxLine: 1,
                      hintText: "Type Option 3 here...".tr(),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    //Option 4
                    buildValidationTextFormField(
                      controller: option4Controller,
                      context: context,
                      maxLength: 51,
                      maxLine: 1,
                      hintText: "Type Option 4 here...".tr(),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    //Option 5
                    buildValidationTextFormField(
                      controller: option5Controller,
                      context: context,
                      maxLength: 51,
                      maxLine: 1,
                      hintText: "Type Option 5 here...".tr(),
                    ), //

                    SizedBox(
                      height: 10.0,
                    ),

                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: defaultDurationValue,
                        isExpanded: true,
                        elevation: 0,
                        iconEnabledColor: mRed,
                        validator: (val) {
                          if (val == null) return "Please Select Duration".tr();
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: lRed)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: mRed, width: 3)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: mRed)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: mRed, width: 3)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                        ),
                        hint: Text("Please Select Duration For Poll".tr()),
                        onChanged: (newDuration) {
                          setState(() {
                            defaultDurationValue = newDuration;
                          });
                        },
                        items: durationList.map((durationItem) {
                          return DropdownMenuItem<String>(
                              value: durationItem,
                              child: Text("$durationItem"));
                        }).toList(),
                      ),
                    ),

                    SizedBox(
                      height: 20.0,
                    ),

                    //todo name and pic functionality
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            Text("Post Anonymously.".tr())
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
                        onPressed: publishPoll,
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
    double fontSize = 16.0,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLine,
      style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: fontSize),
      decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
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
          hintText: hintText),
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
