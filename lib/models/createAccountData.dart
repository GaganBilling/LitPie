import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/models/userVideosModel.dart';

class CreateAccountData {
  final String name,
      email,
      dOB,
      age,
      uid,
      username,
      countryCode,
      gender,
      themeMode,
      address,
      phone,
      password,
      profilepic,
      showGender,
      pName,
      pDoing,
      pVenue,
      pCity,
      pDate,
      pTimeBegin,
      pTimeEnd,
      pRname,
      pRdate,
      pRuid,
      deviceToken,
      planplacepic;

  final Map coordinates, editInfo, socioInfo, ageRange;
  final List hobbies;
  List<String> imageUrl = [];
  UserVideosModel userVideosModel;
  UserStoriesModel userStoriesModel;
  int maxDistance;
  var distanceBW, roseColl, roseRec;
  Timestamp lastmsg;
  Timestamp nametimestamp, rosetimestamp;
  final bool isBlocked, isHidden, isVaccinated, isDeleted, ADMIN;
  bool isOnline;

  CreateAccountData(
      {@required this.name,
      this.ADMIN,
      this.email,
      this.planplacepic,
      this.dOB,
      @required this.age,
      this.gender,
      this.isVaccinated,
      this.username,
      @required this.uid,
      this.countryCode,
      this.address,
      this.socioInfo,
      this.roseColl,
      this.roseRec,
      this.phone,
      this.password,
      this.profilepic,
      this.coordinates,
      this.themeMode,
      this.pRname,
      this.pRdate,
      this.pRuid,
      this.hobbies,
      this.showGender,
      this.isBlocked,
      this.isOnline,
      this.isHidden,
      this.lastmsg,
      this.nametimestamp,
      this.rosetimestamp,
      this.ageRange,
      this.maxDistance,
      this.imageUrl,
      this.editInfo,
      this.distanceBW,
      this.pName,
      this.pDoing,
      this.pVenue,
      this.pCity,
      this.pDate,
      this.pTimeBegin,
      this.pTimeEnd,
      this.deviceToken,
      this.isDeleted});

  factory CreateAccountData.fromJson(Map<String, dynamic> json) {
    return CreateAccountData(
      ADMIN: json['isHidden'] != null ? json['isHidden'] : false,
      name: json['name'],
      email: json['email'],
      age: json['age'],
      planplacepic: json['planplacepic'],
      pName: json['pName'],
      pCity: json['pCity'],
      pDoing: json['pDoing'],
      pVenue: json['pVenue'],
      deviceToken: json['deviceToken'],
      pDate: json['pDate'],
      pTimeBegin: json['pTimeBegin'],
      pTimeEnd: json['pTimeEnd'],
      themeMode: json['lightMode'],
      isBlocked: json['isBlocked'] != null ? json['isBlocked'] : false,
      isOnline: json['isOnline'] != null ? json['isOnline'] : false,
      isHidden: json['isHidden'] != null ? json['isHidden'] : false,
      isVaccinated: json['isVaccinated'] != null ? json['isVaccinated'] : false,
      isDeleted: json['isDeleted'] != null ? json['isDeleted'] : false,

      // age:((DateTime.now().difference(DateTime.parse(json['DOB'])).inDays) / 365.2425).truncate().toString(),
      dOB: json['DOB'],
      hobbies: json['hobbies'],
      address: json['location']['address'],
      coordinates: json['location'],
      username: json['username'],
      uid: json['uid'],
      editInfo: json['editInfo'],
      socioInfo: json['socioInfo'],
      maxDistance: json['maximum_distance'],
      showGender: json['showGender'],
      phone: json['phone'],
      profilepic: json['profilepic'],
      pRdate: json['pRdate'],
      pRname: json['pRname'],
      pRuid: json['pRuid'],
    );
  }

  factory CreateAccountData.fromDocument(Map<String, dynamic> doc) {
    return CreateAccountData(
        ADMIN: doc['ADMIN'] != null ? doc['ADMIN'] : false,
        uid: doc['uid'],
        dOB: doc['DOB'],
        email: doc['email'],
        pName: doc['pName'],
        pCity: doc['pCity'],
        pDoing: doc['pDoing'],
        deviceToken: doc['deviceToken'],
        pVenue: doc['pVenue'],
        planplacepic: doc['planplacepic'],
        pDate: doc['pDate'],
        pTimeBegin: doc['pTimeBegin'],
        pTimeEnd: doc['pTimeEnd'],
        username: doc['username'],
        isBlocked: doc['isBlocked'] != null ? doc['isBlocked'] : false,
        isOnline: doc['isOnline'] != null ? doc['isOnline'] : false,
        isHidden: doc['isHidden'] != null ? doc['isHidden'] : false,
        isDeleted: doc['isDeleted'] != null ? doc['isDeleted'] : false,
        isVaccinated: doc['isVaccinated'] != null ? doc['isVaccinated'] : false,
        themeMode: doc['lightMode'],
        phone: doc['phone'],
        profilepic: doc['profilepic'],
        name: doc['name'],
        editInfo: doc['editInfo'],
        socioInfo: doc['socioInfo'],
        ageRange: doc['age_range'] == null || doc['age_range'] == {}
            ? {"min": "20", "max": "50"}
            : doc['age_range'],
        showGender: doc['showGender'],
        hobbies: doc['hobbies'] != null
            ? List.generate(doc['hobbies'].length, (index) {
                return doc['hobbies'][index];
              })
            : [],
        maxDistance: doc['maximum_distance'],
        age: doc['age'],
        // age: ((DateTime.now().difference(DateTime.parse(doc["user_DOB"])).inDays) / 365.2425).truncate(),
        address: doc['location'] != null ? doc['location']['address'] : "",
        coordinates: doc['location'],
        nametimestamp: doc['Nametimestamp'],
        rosetimestamp: doc['Rosetimestamp'],
        pRdate: doc['pRdate'],
        pRname: doc['pRname'],
        pRuid: doc['pRuid'],
        roseColl: doc['roseColl'],
        roseRec: doc['roseRec'],
        imageUrl: []);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'username': username,
      'DOB': dOB,
      'uid': uid,
      'deviceToken': deviceToken,
      'showGender': showGender,
      'editInfo': editInfo,
      'socioInfo': socioInfo,
      'hobbies': hobbies,
      'location': coordinates,
      'maximum_distance': maxDistance,
      'phone': phone,
      'profilepic': profilepic,
    };
  }
}
