/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:litpie/ApiController/StoriesApiController.dart';
import 'package:litpie/UploadMedia/UploadImages/upload_imagesFirebase.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/controller/mobileAdsController.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/swipeCardModel.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userVideosModel.dart';
import 'package:litpie/variables.dart';

import '../UploadMedia/UploadImages/uplopad_videosFirebase.dart';

class SwipeController extends ChangeNotifier {
  FirebaseController _firebaseController = FirebaseController();
  User currentUser;
  CreateAccountData currentUserData;

  List<SwipeCardModel> swipeCardModelList;
  List<Object> allSwipeRows = [];

  int swipeCount = 0;
  List<SwipeCardModel> swipeCardRemoved = [];
  List checkedUser = [];
  List<QueryDocumentSnapshot> likedByList = [];
  SwipeCardModel element;

  // List<CreateAccountData> users = [];
  List<QueryDocumentSnapshot> likedByUsersDocs = [];
  List<QueryDocumentSnapshot> querySnapshot_likedUIDsUsersDetail = [];

  //Load More Variables
  List<QueryDocumentSnapshot> swipeDocs = [];
  DocumentSnapshot lastDocument;
  DocumentSnapshot likedByUsersUID_lastDocument;
  bool hasMore = true;
  bool likedByUsersHasMore = true;
  bool isLoading = false;
  int initialDocLimit = 5;
  int laterDocLimit = 1;

  MobileAdsController _mobileAdsController = MobileAdsController();

  //loading
  bool isFetching = true;

  //6 liked by now //okay
  SwipeController() {
    print("Swiper Controller Constructor");
    init();
  }

  init() async {
    print("SwipeController Init State...");
    currentUser = _firebaseController.firebaseAuth.currentUser;
    currentUserData = await _firebaseController.currentUserData;

    swipeCardRemoved.clear();
    // await checkedUserOrNot();
    await getLikedByList();
    getSwipedCount();
    // await getUserList();
    await getInitialSwipeCard();
  }

  void getSwipedCount() {
    FirebaseController()
        .userColReference
        .doc(currentUser.uid)
        .collection("CheckedUser")
        .where(
      'timestamp',
      isGreaterThan: Timestamp.now().toDate().subtract(Duration(days: 1)),
    )
        .snapshots()
        .listen((event) {
      print("swipe " + event.docs.length.toString());
      swipeCount = event.docs.length;
      notifyListeners();
    });
  }

  //

  Future<void> getLikedByList() async {
    CollectionReference likedByRef = _firebaseController.userColReference
        .doc(currentUser.uid)
        .collection("LikedBy");
    // CollectionReference checkedUserRef = _firebaseController.userColReference.doc(currentUser.uid).collection("CheckedUser");
    QuerySnapshot tempQueries = await likedByRef.get();
    this.likedByList = tempQueries.docs;
    print("LikedByUSer : $likedByList");
  }

  Query likedByUserQuery({@required String userUid}) {
    if (currentUserData.showGender == 'everyone') {
      return _firebaseController.userColReference
          .where("uid", isEqualTo: userUid)
          .where("age",
          isGreaterThanOrEqualTo: currentUserData.ageRange["min"],
          isLessThanOrEqualTo: currentUserData.ageRange["max"])
          .orderBy("age", descending: false);
    } else {
      return _firebaseController.userColReference
          .where("uid", isEqualTo: userUid)
          .where("editInfo.userGender", isEqualTo: currentUserData.showGender)
          .where("age",
          isGreaterThanOrEqualTo: currentUserData.ageRange["min"],
          isLessThanOrEqualTo: currentUserData.ageRange["max"])
          .orderBy("age", descending: false);
    }
  }

  Query query() {
    if (currentUserData.showGender == 'everyone') {
      return _firebaseController.userColReference
          .where('age',
          isGreaterThanOrEqualTo: currentUserData.ageRange['min'],
          isLessThanOrEqualTo: currentUserData.ageRange['max'])

      /// int.parse(currentUser.ageRange['min'])
          .orderBy('age', descending: false);
    } else {
      return _firebaseController.userColReference
          .where('editInfo.userGender', isEqualTo: currentUserData.showGender)
          .where('age',
          isGreaterThanOrEqualTo: currentUserData.ageRange['min'],
          isLessThanOrEqualTo: currentUserData.ageRange['max'])
          .orderBy('age', descending: false);
    }
  }

  Future<bool> checkedUserOrNotBool({@required String uid}) async {
    QuerySnapshot querySnapshot = await _firebaseController.userColReference
        .doc(currentUser.uid)
        .collection("CheckedUser")
        .where("LikedUser", isEqualTo: uid.toString())
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> getInitialSwipeCard() async {
    print("getInitialSwipeCard Called");
    isFetching = true;
    if (!hasMore) {
      print("No More Swipe Card");
      return;
    }

    QuerySnapshot querySnapshot;
    QuerySnapshot querySnapshot_likedUsersUID;

    if (likedByUsersHasMore) {
      //if likedByUser has more data to laod then only load new data
      likedByUsersDocs.clear();

      while (likedByUsersDocs.length < initialDocLimit) {
        if (likedByUsersUID_lastDocument == null) {
          swipeCardModelList = [];
          querySnapshot_likedUsersUID = await _firebaseController
              .userColReference
              .doc(currentUser.uid)
              .collection("LikedBy")
              .limit(initialDocLimit)
              .get();
        } else {
          querySnapshot_likedUsersUID = await _firebaseController
              .userColReference
              .doc(currentUser.uid)
              .collection("LikedBy")
              .limit(laterDocLimit)
              .startAfterDocument(likedByUsersUID_lastDocument)
              .get();
        }

        if (querySnapshot_likedUsersUID.docs.length <= 0) {
          likedByUsersHasMore = false;
          print("No More Liked Users UIDs");
          break;
        } else {
          likedByUsersDocs.addAll(querySnapshot_likedUsersUID.docs);
          //assign Last Document from LikedByUsers
          likedByUsersUID_lastDocument = querySnapshot_likedUsersUID
              .docs[querySnapshot_likedUsersUID.docs.length - 1];
        }
      }

      //Print Likedby Users
      likedByUsersDocs.forEach((element) {
        print("${likedByUsersDocs.indexOf(element)} : ${element.id}");
      });

      //Getting likedUIDsUsersDetail For Swipe Card
      for (int i = 0; i < likedByUsersDocs.length; i++) {
        QuerySnapshot tempQuerySnapshot =
        await likedByUserQuery(userUid: likedByUsersDocs[i]["LikedBy"])
            .get();

        if (tempQuerySnapshot.docs.isNotEmpty)
          querySnapshot_likedUIDsUsersDetail.add(tempQuerySnapshot.docs[0]);
      }

      //add to SwipeCardModelList -->
      //await
      _getFinalUsersFromDocuments(querySnapshot_likedUIDsUsersDetail);
    }

    //when likedByUserHasMore == false
    if (!likedByUsersHasMore) {
      print("Normal User Called");
      while (swipeCardModelList.length < initialDocLimit) {
        if (lastDocument == null) {
          querySnapshot = await query().limit(laterDocLimit).get();
        } else {
          querySnapshot = await query()
              .limit(laterDocLimit)
              .startAfterDocument(lastDocument)
              .get();
        }

        if (querySnapshot.docs.length < laterDocLimit) {
          hasMore = false;
          print("No More Swipe Load");
          break;
        } else {
          lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
          //add to SwipeCardModelList -->
          //await
          _getFinalUsersFromDocuments(querySnapshot.docs);
          // print("Temp Users Length: ${tempUsers.length}");
        }
      }
    }

    //Print Likedby Users
    // swipeCardModelList.forEach((element) {
    //   print(
    //       "${swipeCardModelList.indexOf(element)} : ${element.createAccountData.uid}"); //these are all users
    // });
    print("Swipes Length: ${swipeCardModelList.length}");
    isFetching = false;
    notifyListeners();
    // }catch(e){
    //   print("Error (GetInitialSwipeCard -> Controller) : $e");
    // }
  }

  Future<void> _getFinalUsersFromDocuments(
      List<QueryDocumentSnapshot> docs) async {
    swipeCardRemoved.clear();
    await Future.forEach(docs, (QueryDocumentSnapshot element) async {
      CreateAccountData temp =
      CreateAccountData.fromDocument(element.data());
      var distance = Constants()
          .calculateDistance(currentUser: currentUserData, anotherUser: temp);
      temp.distanceBW = distance.round();
      BlockedUserModel blockedUserModel = await BlockUserController()
          .blockedExistOrNot(
          currentUserId: currentUserData.uid, anotherUserId: temp.uid);

      await getCheckedValue(temp,distance,blockedUserModel);
    });

  }
  Future<void> getCheckedValue(CreateAccountData temp, double distance,
      BlockedUserModel blockedUserModel) async {
    bool isChecked = await checkedUserOrNotBool(uid: temp.uid);
    if (isChecked) {
      if (distance <= currentUserData.maxDistance &&
          temp.uid != currentUserData.uid &&
          !temp.isBlocked &&
          !temp.isDeleted &&
          !temp.isHidden &&
          blockedUserModel == null) {
        temp.imageUrl.clear();
        swipeCardModelList.insert(
            0,
            SwipeCardModel(
                createAccountData: temp,
                images: null,
                userVideosModel: UserVideosModel(videos: []),
                stories: null,
                blockedUserModel: null));

        ImageController().getAllImages(uid: temp.uid).then((images) {
          List<Images> image = [];
          images.forEach((element) {
            var data = {
              "imgid": "",
              "image_url": element,
              "uploaded_on": "",
            };
            Images images = Images.fromJson(data);
            image.add(images);
          });
          userImagesModel.images = image;
          return userImagesModel;
        }).whenComplete(() {
          notifyListeners();
        });

        VideoController().getAllVideos(temp.uid).then((videos) {
          List<Videos> lis = [];
          videos.forEach((element) async {
            var data = {
              "videoid": "",
              "video_url": element["video"],
              "thumbnail_url": element['thumbnail'],
              "uploaded_on": "",
            };
            Videos video = Videos.fromJson(data);
            lis.add(video);
          });
          print("the ${temp.name} uid is ${temp.uid}");
          userVideosModel.videos = lis;
          notifyListeners();
          if (swipeCardModelList != null && swipeCardModelList.length > 0)
            for (int i = 0; i < swipeCardModelList.length; i++) {
              if (swipeCardModelList[i] is SwipeCardModel) {
                print("the user id :${temp.uid}");
                print("the user id :${temp.name}");
                if (swipeCardModelList[i].createAccountData.uid == temp.uid) {
                  if (userVideosModel.videos != null &&
                      userVideosModel.videos.length > 0) {
                    print(swipeCardModelList[i].createAccountData.name);
                    print(userVideosModel.videos.length);
                    swipeCardModelList[i].userVideosModel.videos.addAll(userVideosModel.videos);
                    swipeCardModelList[i].userVideosModel.videos;
                    print(
                        "The length of item videos are :${swipeCardModelList[i].userVideosModel.videos.length}");
                  }
                }
              }
              notifyListeners();
            }
          print(swipeCardModelList);
        }).whenComplete(() {
          notifyListeners();
        });

        StoriesApiController().getStories(uid: temp.uid).then((stories) {
          if (stories != null) {
            temp.userStoriesModel = stories;
            swipeCardModelList.forEach((elem) {
              if (elem is SwipeCardModel) {
                SwipeCardModel element = elem;
                if (element.createAccountData.uid == temp.uid)
                  element.stories = stories;
                notifyListeners();
              }
            });
          } else {
            print("No Stories : ${temp.uid}");
          }
        }).whenComplete(() {
          notifyListeners();
        });
      }
    }
  }


  void removeSwipeCard({@required SwipeCardModel swipeCardModel}) {
    swipeCardModelList.remove(swipeCardModel);
    notifyListeners();
  }
}
*/
