
import 'package:litpie/models/chatMessageModel.dart';
import 'package:litpie/models/createAccountData.dart';

class RecentChatModel {
  RecentChatModel({
    this.chatId,
    this.userDetail,
    this.lastMessage,
  });

  String chatId;
  CreateAccountData userDetail;
  ChatMessageModel lastMessage;

  factory RecentChatModel.fromJson({Map<String, dynamic> json, CreateAccountData userDetail}) => RecentChatModel(
    chatId: json["chatId"],
    userDetail: userDetail,
    lastMessage: ChatMessageModel.fromJson(json["lastMessage"]),
  );


}