import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/variables.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class ImagesApiController {
  Future<bool> uploadImage({@required String uid, @required File image}) async {
    try {
      //URL
      var url = Uri.parse(uploadImageURL);

      //create multipart request for POST method
      var request = http.MultipartRequest("POST", url);

      //add text fields
      request.fields["uid"] = uid;

      //create multipart using filepath, string or bytes
      var pic = await http.MultipartFile.fromPath("image", image.path);

      //add multipart to request
      request.files.add(pic);

      var response = await request.send();
      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      var jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserImagesModel> getImages({@required String uid}) async {
    try {
      var url = Uri.parse(getImagesURL);
      Map jsonBody = {
        "uid": uid,
      };
      var body = jsonEncode(jsonBody);
      var response = await http.post(url, body: body);
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          //Transfer To Model
          // userImagesModel = UserImagesModel.fromJson(jsonResponse);

          return UserImagesModel.fromJson(jsonResponse);
        } else {
          return null;
        }
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Something went wrong, try again!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return null;
  }
}
