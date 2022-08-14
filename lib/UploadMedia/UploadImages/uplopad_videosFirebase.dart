import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/variables.dart';

class VideoController extends ChangeNotifier {
  FirebaseController firebaseController = FirebaseController();
  final _firebaseStorage = FirebaseStorage.instance;
  List<Map<String, dynamic>> videoUrl = [];

  Future<String> uploadVideo(
      {@required String videoPath,
      @required String uid,
      @required File thumbnail}) async {
    String videoUrl;
    var file = File(videoPath);

    if (videoPath != null) {
      //Upload to Firebase
      Reference ref = await _firebaseStorage.ref().child(uid).child("video/" +
          DateTime.now().millisecondsSinceEpoch.toString() +
          uid +
          '.mp4');
      final UploadTask uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() {
        print("vdieo uploading completed");
      }).then((value) async {
        var url = await value.ref.getDownloadURL();
        videoUrl = url;
      });
    } else {
      print('No Video Path Received');
    }
    return videoUrl;
  }

  Future<List<Map<String, dynamic>>> getAllVideos(String uid) async {
    videoUrl.clear();
    var data = await firebaseController.userColReference
        .doc(uid)
        .collection(videosCollectionName)
        .get();
    if (data != null) {
      if (data.docs.isNotEmpty) {
        data.docs.forEach((element) {
          var list = element["videos"];
          if(list.length>0) {
            list.forEach((e) {
              videoUrl.add(e);
            });
          }else{

          }
        });
      }
    }
    return videoUrl;
  }

  Future<String> uploadThumbNail(File thumbnail, String uid) async {
    String thumbnailUrl;
    try{
      var thumbFile = File(thumbnail.path);
      if (thumbFile != null) {
        Reference thumbRef = await _firebaseStorage.ref().child(uid).child(
            "thumbnail/" +
                DateTime.now().millisecondsSinceEpoch.toString() +
                uid +
                'jpg');
        final UploadTask uploadThumbTask = thumbRef.putFile(thumbFile);

        await uploadThumbTask.whenComplete(() {}).then((value) async {
          thumbnailUrl = await value.ref.getDownloadURL();
        });
      }
      return thumbnailUrl;
    }catch(e){
      print(e.toString());
    }
    return thumbnailUrl;
  }
}
