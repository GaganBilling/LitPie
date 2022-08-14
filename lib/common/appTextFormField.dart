import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Theme/colors.dart';

class AppTextFormField extends StatelessWidget {
  TextEditingController textEditingController;
  String hintText;
  bool obscureValue;
  TextInputType textInputType;

  AppTextFormField({this.obscureValue,this.textEditingController, this.hintText,this.textInputType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      obscureText: obscureValue,
      keyboardType: textInputType,
      style: Theme.of(context).textTheme.subtitle1,
      decoration: InputDecoration(
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
          hintText: hintText.tr()),
    );
  }
}
