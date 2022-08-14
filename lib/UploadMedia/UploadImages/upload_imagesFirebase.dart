import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/variables.dart';

class ImageController extends ChangeNotifier {
  String imageUrl;
  final _firebaseStorage = FirebaseStorage.instance;
  FirebaseController firebaseController = FirebaseController();
//  List<String> imageurl = [];
  List<Map<String,dynamic>> imageurl = [];

  uploadImage(
      {@required XFile imagePath,
      @required String uid,
      String foldername}) async {
    var file = File(imagePath.path);

    if (imagePath != null) {
      //Upload to Firebase
      var snapshot =
          await _firebaseStorage.ref().child('${uid}/images').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      imageUrl = downloadUrl;
      notifyListeners();
    } else {
      print('No Image Path Received');
    }
    return imageUrl;
  }

  Future<List<String>> upload(List<File> images, String uid) async {
    List<String> _downloadUrls = [];

    await Future.forEach(images, (element) async {
      Reference ref = FirebaseStorage.instance.ref().child(uid).child(
          "images/" +
              DateTime.now().millisecondsSinceEpoch.toString() +
              uid +
              '.jpg');
      try {
        var referenceUrl;
        UploadTask uploadTask = ref.putFile(File(element.path));
        await uploadTask.whenComplete(() {}).then((value) async {
          referenceUrl = await value.ref.getDownloadURL();
        });
        _downloadUrls.add(referenceUrl);
        referenceUrl = "";
      } catch (e) {
        print(e.toString());
      }
    });

    return _downloadUrls;
  }

  Future<List<Map<String,dynamic>>> getAllImages({String uid}) async {
    imageurl.clear();
    var data = await firebaseController.userColReference
        .doc(uid)
        .collection(imagesCollectionName)
        .get();
    if (data != null) {
      if (data.docs.isNotEmpty) {
        var list =data.docs[0]['images'];
        if (list.length > 0) {
          list.forEach((imagesElement) {
            imageurl.add(imagesElement);
          });
        }
      }
    } else {
      imageurl = [];
    }
    return imageurl;
  }
}
