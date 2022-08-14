import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:litpie/models/allStoriesModel.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/models/userVideosModel.dart';

final String userCollectionName = "users";
final String userDevicesCollectionName = "devices";
final String plansCollectionName = "Plans";
final String planRequestCollectionName = "planRequest";
final String matchesCollectionName = "Matches";
final String checkedUserCollectionName = "CheckedUser";
final String rCollectionName = "R";
final String likedByCollectionName = "LikedBy";
final String pollCollectionName = "polls";
final String blockedCollectionName = "blocked";
final String unFriendCollectionName = "UnFriended";
final String chatCountCollectionName = "chatCount";
final String deletedUsersCollectionName = "deletedUsers";
final String postCollectionName = 'Post';
final String likeDislikeCollectionName = 'PostLikes';
final String commentCollectionName = 'Comments';
final String notificationCollectionName = 'Notifications';
final String commentsLikesCollectionName = 'CommentLikes';
final String imagesCollectionName = 'Images';
final String videosCollectionName = 'Videos';
//NotificationCount

// Global Variables
final double miniScreenWidth = 360.0;
int plansLimit = 10;
List<Object> plansUsers; //CreateAccountData
List<Object> plansDocs; //QueryDocumentSnapshot
DocumentSnapshot plansLastDocument;
List onlineUsers;
bool onlineUserIsFetching = true;
bool plansLoading = true;
bool isOnline;
int roseCollCollectionLimit = 13;
int roseCollCollectionLimitByAd = 1;

final int imageUploadLimit = 20;
final int videoUploadLimit = 20;
final int globalStoryLimit = 18;

//Swipe Count
int swipeCount = 0;

final String apiPrimaryURL = "https://litpie.in/api/";
final String apiImagesURL = "https://litpie.in/api/UserImages/";
final String apiVideosURL = "https://litpie.in/api/UserVideos/";
final String apiStoriesURL = "https://litpie.in/api/UserStories/";

//Images URLs
final String uploadImageURL = apiPrimaryURL + "images/uploadImage.php";
final String getImagesURL = apiPrimaryURL + "images/getImages.php";


//Stories URLs
final String deleteStoryURL = apiPrimaryURL + "stories/deleteStory.php";
final String getStoriesURL = apiPrimaryURL + "stories/getStories.php";
final String getInitialStoriesWithPaginationURL =
    apiPrimaryURL + "stories/getInitialStoriesWithPagination.php";
final String getLaterStoriesWithPaginationURL =
    apiPrimaryURL + "stories/getLaterStoriesWithPagination.php";

//Global Models
UserImagesModel userImagesModel = UserImagesModel();
UserVideosModel userVideosModel = UserVideosModel();
UserStoriesModel userStoriesModel=UserStoriesModel();
AllStoriesModel allStoriesModel;

//Placeholder Image URL
final String placeholderImage = "assets/images/profile-dummy.png";

//Enums
enum ImageFrom { normalImage, storyImage }

//Test Ads Unit id
String testAdInterstitial = "ca-app-pub-3940256099942544/1033173712";
String testAdRewarded = "ca-app-pub-3940256099942544/5224354917";
String testAdBanner = "ca-app-pub-3940256099942544/6300978111";
