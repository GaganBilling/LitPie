import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/userImagesModel.dart';
import 'package:litpie/models/userStoriesModel.dart';
import 'package:litpie/models/userVideosModel.dart';

class SwipeCardModel {
  //This model is for Global
  final CreateAccountData createAccountData;
  UserImagesModel images;
  UserVideosModel userVideosModel;
  UserStoriesModel stories;
  BlockedUserModel blockedUserModel;

  SwipeCardModel(
      {this.createAccountData,
      this.images,
      this.userVideosModel,
      this.stories,
      this.blockedUserModel, videos});
}
