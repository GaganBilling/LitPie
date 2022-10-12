import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:litpie/models/allStoriesModel.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/variables.dart';
import 'package:easy_localization/easy_localization.dart';

class StoriesApiController {
  Future<UserStoriesModel> getStories({@required String uid}) async {
    try {
      var url = Uri.parse(getStoriesURL);
      Map jsonBody = {
        "uid": uid,
      };
      var body = jsonEncode(jsonBody);
      var response = await http.post(url, body: body);
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          return UserStoriesModel.fromJson(jsonResponse);
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

  Future<AllStoriesModel> getInitialStoriesWithPagination(
      {@required String currentUserId}) async {
    int rowLimit = globalStoryLimit;
    // int rowLimit = 2; //for testing purpose //it is working
    try {
      var url = Uri.parse(getInitialStoriesWithPaginationURL);
      Map jsonBody = {"uid": currentUserId, "limit": rowLimit};

      var body = jsonEncode(jsonBody);
      var response = await http.post(url, body: body);
      var jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> tempJson = {
        "singleStory": [],
        "status": "",
        "itemCount": 0,
      };
      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          print(jsonResponse);
          //Check User Exist in Block List Or Not
          // AllStoriesModel finalStories = AllStoriesModel.fromJson(tempJson);
          AllStoriesModel tempStories = AllStoriesModel.fromJson(jsonResponse);
          // for(int i=0; i<tempStories.singleStory.length;i++){
          //   String userID = tempStories.singleStory[i].uid;
          //   if(await BlockUserController().blockedExistOrNot(currentUserId: currentUserId, anotherUserId: userID) == null){
          //    finalStories.singleStory.add(tempStories.singleStory[i]);
          //   }
          // }
          //
          // if(finalStories.singleStory.length>0){
          //   finalStories.status = tempStories.status;
          //   finalStories.itemCount = finalStories.singleStory.length;
          //   return finalStories;
          // }
          return tempStories; // return AllStoriesModel.fromJson(tempJson);
        }
      }

      return AllStoriesModel.fromJson(tempJson);
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

  Future<AllStoriesModel> getLaterStoriesWithPagination(
      {@required String currentUserId,
      @required String lastStoryId,
      @required int limit}) async {
    int rowLimit = limit;
    try {
      var url = Uri.parse(getLaterStoriesWithPaginationURL);
      Map jsonBody = {
        "uid": currentUserId,
        "limit": rowLimit,
        "last_story_id": lastStoryId
      };

      var body = jsonEncode(jsonBody);
      var response = await http.post(url, body: body);
      var jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> tempJson = {
        "singleStory": [],
        "status": "",
        "itemCount": 0,
      };
      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          // AllStoriesModel finalStories = AllStoriesModel.fromJson(tempJson);
          AllStoriesModel tempStories = AllStoriesModel.fromJson(jsonResponse);
          //Check User Exist in Block List or Not
          // for(int i=0; i<tempStories.singleStory.length;i++){
          //   String userID = tempStories.singleStory[i].uid;
          //   if(await BlockUserController().blockedExistOrNot(currentUserId: currentUserId, anotherUserId: userID) == null){
          //     finalStories.singleStory.add(tempStories.singleStory[i]);
          //   }
          // }
          //
          // if(finalStories.singleStory.length>0){
          //   finalStories.status = tempStories.status;
          //   finalStories.itemCount = finalStories.singleStory.length;
          //   return finalStories;
          // }
          return tempStories; //return AllStoriesModel.fromJson(tempJson);
        }
      }
      return AllStoriesModel.fromJson(tempJson);
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

  Future<bool> deletStory({@required String storyId}) async {
    try {
      var url = Uri.parse(deleteStoryURL);
      Map jsonBody = {
        "storyid": storyId,
      };
      var body = jsonEncode(jsonBody);
      var response = await http.post(url, body: body);
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse["status"] == "200") {
          //Model
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }

    } catch (e) {
      print("deleteError: $e");
      Fluttertoast.showToast(
          msg: "Something went wrong, try again!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }
}
