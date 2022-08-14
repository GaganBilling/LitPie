import 'dart:collection';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Screens/BottomNavigation/Chat/RealtimeChat/RTChatLargeImage.dart';
import 'package:ntp/ntp.dart';
import 'package:litpie/Screens/Information.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/chatMessageModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:litpie/widgets/moreOptionDialog.dart';
import 'package:provider/provider.dart';

import 'package:swipe_to/swipe_to.dart';
import 'package:easy_localization/easy_localization.dart';

import 'RTChatSendMedia.dart';

class RTChatPage extends StatefulWidget {
  final CreateAccountData sender;
  final String chatId;
  final CreateAccountData second;

  RTChatPage({this.sender, this.chatId, this.second});

  @override
  _RTChatPageState createState() => _RTChatPageState();
}

class _RTChatPageState extends State<RTChatPage> {
  bool isHidden = false;
  bool isDeleted = false;
  bool isBlocked = false;
  bool isFetched = false;
  final focusNode = FocusNode();
  final BlockUserController blockUserController = BlockUserController();

  ChatMessageModel replyMessage;

  BlockedUserModel blockedModel;

  CollectionReference userCollRef =
      FirebaseFirestore.instance.collection("users");

  final TextEditingController _textController = new TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Realtime Chat
  FirebaseDatabase realDB = new FirebaseDatabase();
  DatabaseReference userChatRef;
  int chatMsgsLimit = 500;
  int minusOneDay;

  @override
  void initState() {
    FlutterAppBadger.removeBadge();
    updateMinusOneDay();
    userChatRef = realDB
        .reference()
        .child("chats")
        .child(widget.chatId)
        .child("messages");
    init();
    super.initState();
    checkHiddenBlockedDeleted();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateMinusOneDay() async {
    DateTime serverDateTime = await NTP.now();
    minusOneDay =
        Timestamp.fromDate(serverDateTime.subtract(Duration(hours: 24)))
            .millisecondsSinceEpoch;
  }

  Future<void> init() async {
    blockedModel = await blockUserController.blockedExistOrNot(
        currentUserId: widget.sender.uid, anotherUserId: widget.second.uid);
    if (mounted)
      setState(() {
        isFetched = true;
      });
  }

  checkHiddenBlockedDeleted() async {
    await userCollRef.doc(widget.second.uid).get().then((value) {
      //is Hidden
      if (value['isHidden'] != null && value['isHidden']) {
        if (mounted)
          setState(() {
            isHidden = true;
          });
      } else {
        if (mounted)
          setState(() {
            isHidden = false;
          });
      }

      //is BLock
      if (value['isBlocked'] != null && value['isBlocked']) {
        if (mounted)
          setState(() {
            isBlocked = true;
          });
      } else {
        if (mounted)
          setState(() {
            isBlocked = false;
          });
      }

      //is Deleted
      if (value['isDeleted'] != null && value['isDeleted']) {
        if (mounted)
          setState(() {
            isDeleted = true;
          });
      } else {
        if (mounted)
          setState(() {
            isDeleted = false;
          });
      }

      return;
    });
  }

  void replyToMessage(ChatMessageModel message) {
    focusNode.requestFocus();
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReplyMessage() {
    setState(() {
      replyMessage = null;
    });
  }

  List<Widget> generateSenderLayout(ChatMessageModel chatMessage) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return <Widget>[
      Expanded(
        child: SwipeTo(
          onRightSwipe: () {
            replyToMessage(chatMessage);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: chatMessage.imageUrl != ''
                    ? InkWell(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, right: 15),
                                  child: Stack(
                                    children: <Widget>[
                                      CachedNetworkImage(
                                        placeholder: (context, url) => Center(
                                          child: CupertinoActivityIndicator(
                                            radius: 10,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .65,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        imageUrl: chatMessage.imageUrl ?? '',
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        child: chatMessage.isRead == false
                                            ? Icon(
                                                Icons.done,
                                                color: lRed,
                                                size: 15,
                                              )
                                            : Icon(
                                                Icons.done_all,
                                                color: mRed,
                                                size: 15,
                                              ),
                                      )
                                    ],
                                  ),
                                  height: 150,
                                  width: 150.0,
                                  color: themeProvider.isDarkMode
                                      ? mBlack
                                      : Colors.grey[100],
                                  padding: EdgeInsets.all(5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                      chatMessage.createdAt != null
                                          ? ":" +
                                              DateFormat.MMMd()
                                                  .add_jm()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          chatMessage
                                                              .createdAt))
                                                  .toString()
                                          : "",
                                      style: TextStyle(
                                        color: lRed,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                      )),
                                )
                              ],
                            ),
                            chatMessage.liked == true
                                ? Positioned(
                                    top: 6,
                                    right: 22,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (chatMessage.senderId !=
                                            widget.sender.uid) {
                                          onLikedTap(chatMessage);
                                        }
                                      },
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ))
                                : Positioned(
                                    //alignment: FractionalOffset.centerRight,
                                    top: 5,
                                    right: 15,
                                    child: GestureDetector(
                                      onTap: () {
                                        onLikedTap(chatMessage);
                                      },
                                      child: chatMessage.senderId !=
                                              widget.sender.uid
                                          ? Icon(
                                              CupertinoIcons.heart,
                                              color:
                                                  Colors.red.withOpacity(0.5),
                                              size: 16,
                                            )
                                          : Container(),
                                    ),
                                  ),
                          ],
                        ),
                        onLongPress: () {
                          if (chatMessage.senderId != widget.sender.uid) {
                            onLikedTap(chatMessage);
                          }
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => RTChatLargeImage(
                                chatMessage.imageUrl,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        clipBehavior: Clip.antiAlias,
                        width: MediaQuery.of(context).size.width * 0.65,
                        margin: EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 80.0, right: 10),
                        decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? mBlack
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (chatMessage.replyChatMessage != null)
                              Container(
                                padding: EdgeInsets.only(
                                  top: 10.0,
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 6.0,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: lRed.withOpacity(0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatMessage.replyChatMessage.senderId ==
                                              widget.sender.uid
                                          ? "You".tr()
                                          : widget.second.name.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : mBlack,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6.0,
                                    ),
                                    chatMessage.replyChatMessage.imageUrl != ''
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                top: 2.0,
                                                bottom: 2.0,
                                                right: 15),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 10,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .65,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .9,
                                              imageUrl: chatMessage
                                                      .replyChatMessage
                                                      .imageUrl ??
                                                  '',
                                              fit: BoxFit.fitWidth,
                                            ),
                                            height: 80.0,
                                            width: 80.0,
                                            color: lRed.withOpacity(0.5),
                                            padding: EdgeInsets.all(5),
                                          )
                                        : Text(
                                            chatMessage.replyChatMessage.text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white70
                                                  : mBlack,
                                              fontSize: 15.0,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            // if(chatMessage.replyChatMessage != null)
                            // Text(chatMessage.replyChatMessage.text),
                            Container(
                              padding: EdgeInsets.only(
                                top: chatMessage.replyChatMessage == null
                                    ? 15.0
                                    : 6.0,
                                left: chatMessage.replyChatMessage == null
                                    ? 15.0
                                    : 15.0,
                                right: chatMessage.replyChatMessage == null
                                    ? 15.0
                                    : 15.0,
                                bottom: chatMessage.replyChatMessage == null
                                    ? 15.0
                                    : 10.0,
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                chatMessage.text,
                                                style: TextStyle(
                                                  //  color: Colors.black87,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                              chatMessage.createdAt != null
                                                  ? ":" +
                                                      DateFormat.MMMd()
                                                          .add_jm()
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  chatMessage
                                                                      .createdAt))
                                                          .toString()
                                                  : "",
                                              style: TextStyle(
                                                color: lRed,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          chatMessage.isRead == false
                                              ? Icon(
                                                  Icons.done,
                                                  color: lRed,
                                                  size: 15,
                                                )
                                              : Icon(
                                                  Icons.done_all,
                                                  color: mRed,
                                                  size: 15,
                                                )
                                        ],
                                      ),
                                    ],
                                  ),
                                  chatMessage.liked == true
                                      ? Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (chatMessage.senderId !=
                                                  widget.sender.uid) {
                                                onLikedTap(chatMessage);
                                              }
                                            },
                                            child: Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                              size: 25,
                                            ),
                                          ))
                                      : Positioned(
                                          //alignment: FractionalOffset.centerRight,
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              onLikedTap(chatMessage);
                                            },
                                            child:
                                                chatMessage.replyChatMessage ==
                                                            null &&
                                                        chatMessage.senderId !=
                                                            widget.sender.uid
                                                    ? Icon(
                                                        CupertinoIcons.heart,
                                                        color: Colors.red
                                                            .withOpacity(0.5),
                                                        size: 16,
                                                      )
                                                    : Container(),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        )),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  _messagesIsRead(ChatMessageModel chatMessage) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return <Widget>[
      Expanded(
        child: SwipeTo(
          onRightSwipe: () {
            replyToMessage(chatMessage);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: chatMessage.imageUrl != ''
                    ? InkWell(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, right: 15),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 10,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    height: MediaQuery.of(context).size.height *
                                        .65,
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    imageUrl: chatMessage.imageUrl ?? '',
                                    fit: BoxFit.fitWidth,
                                  ),
                                  height: 150,
                                  width: 150.0,
                                  color: lRed.withOpacity(0.5),
                                  padding: EdgeInsets.all(5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                      chatMessage.createdAt != null
                                          ? ":" +
                                              DateFormat.MMMd()
                                                  .add_jm()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          chatMessage
                                                              .createdAt))
                                                  .toString()
                                          : "",
                                      style: TextStyle(
                                        color: lRed,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                      )),
                                )
                              ],
                            ),
                            chatMessage.liked == true
                                ? Positioned(
                                    top: 6,
                                    right: 22,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (chatMessage.senderId !=
                                            widget.sender.uid) {
                                          onLikedTap(chatMessage);
                                        }
                                      },
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ))
                                : Positioned(
                                    //alignment: FractionalOffset.centerRight,
                                    top: 12,
                                    right: 22,
                                    child: GestureDetector(
                                      onTap: () {
                                        onLikedTap(chatMessage);
                                      },
                                      child: chatMessage.senderId !=
                                              widget.sender.uid
                                          ? Icon(
                                              CupertinoIcons.heart,
                                              color:
                                                  Colors.red.withOpacity(0.5),
                                              size: 16,
                                            )
                                          : Container(),
                                    ),
                                  ),
                          ],
                        ),
                        onLongPress: () {
                          if (chatMessage.senderId != widget.sender.uid) {
                            onLikedTap(chatMessage);
                          }
                        },
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => RTChatLargeImage(
                              chatMessage.imageUrl,
                            ),
                          ));
                        },
                      )
                    : Stack(
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            width: MediaQuery.of(context).size.width * 0.65,
                            margin: EdgeInsets.only(
                                top: 8.0, bottom: 8.0, right: 10),
                            decoration: BoxDecoration(
                                color: lRed.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: <Widget>[
                                if (chatMessage.replyChatMessage != null)
                                  Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: 10.0,
                                          left: 10.0,
                                          right: 10.0,
                                          bottom: 6.0,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: lRed.withOpacity(0.3),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0),
                                            topRight: Radius.circular(15.0),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chatMessage.replyChatMessage
                                                          .senderId ==
                                                      widget.sender.uid
                                                  ? "You".tr()
                                                  : widget.second.name
                                                      .toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white70
                                                    : mBlack,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6.0,
                                            ),
                                            chatMessage.replyChatMessage
                                                        .imageUrl !=
                                                    ''
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        top: 2.0,
                                                        bottom: 2.0,
                                                        right: 15),
                                                    child: CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              Center(
                                                        child:
                                                            CupertinoActivityIndicator(
                                                          radius: 10,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .65,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .9,
                                                      imageUrl: chatMessage
                                                              .replyChatMessage
                                                              .imageUrl ??
                                                          '',
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                    height: 80.0,
                                                    width: 80.0,
                                                    color:
                                                        lRed.withOpacity(0.5),
                                                    padding: EdgeInsets.all(5),
                                                  )
                                                : Text(
                                                    chatMessage
                                                        .replyChatMessage.text,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? Colors.white70
                                                          : mBlack,
                                                      fontSize: 15.0,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: chatMessage.replyChatMessage == null
                                        ? 15.0
                                        : 6.0,
                                    left: chatMessage.replyChatMessage == null
                                        ? 15.0
                                        : 15.0,
                                    right: chatMessage.replyChatMessage == null
                                        ? 15.0
                                        : 15.0,
                                    bottom: chatMessage.replyChatMessage == null
                                        ? 15.0
                                        : 10.0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  child: Text(
                                                    chatMessage.text,
                                                    style: TextStyle(
                                                      // color: Colors.black87,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                chatMessage.createdAt != null
                                                    ? ":" +
                                                        DateFormat.MMMd()
                                                            .add_jm()
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    chatMessage
                                                                        .createdAt))
                                                            .toString()
                                                    : "",
                                                style: TextStyle(
                                                  color: lRed,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          chatMessage.liked == true
                              ? Positioned(
                                  top: 15,
                                  right: 17,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (chatMessage.senderId !=
                                          widget.sender.uid) {
                                        onLikedTap(chatMessage);
                                      }
                                    },
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                                  ))
                              : Positioned(
                                  //alignment: FractionalOffset.centerRight,
                                  top: 15,
                                  right: 17,
                                  child: GestureDetector(
                                    onTap: () {
                                      onLikedTap(chatMessage);
                                    },
                                    child: chatMessage.replyChatMessage == null
                                        ? Icon(
                                            CupertinoIcons.heart,
                                            color: Colors.red.withOpacity(0.5),
                                            size: 16,
                                          )
                                        : Container(),
                                  ),
                                ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  onLikedTap(ChatMessageModel chatMessage) {
    if (!chatMessage.liked) {
      userChatRef.child(chatMessage.messageId).update({
        "liked": true,
      });
    }
    if (chatMessage.liked) {
      userChatRef.child(chatMessage.messageId).update({
        "liked": false,
      });
    }
  }

  List<Widget> generateReceiverLayout(ChatMessageModel chatMessage) {
    if (!chatMessage.isRead) {
      userChatRef.child(chatMessage.messageId).update({
        "isRead": true,
      });
    }
    return _messagesIsRead(chatMessage);
  }

  generateMessages(List<ChatMessageModel> chatMessages) {
    return chatMessages
        .map<Widget>((msg) {
          // print(msg.text);
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: msg.type == MessageType.videoCall
                      ? [
                          Text(
                            msg.createdAt != null
                                ? "${msg.text} : " +
                                    DateFormat.MMMd()
                                        .add_jm()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                msg.createdAt))
                                        .toString() +
                                    " by".tr() +
                                    " ${msg.senderId == widget.sender.uid ? " You".tr() : "${widget.second.name}"}"
                                        .toUpperCase()
                                : "",
                            //     style: TextStyle(
                            //   color: lRed,
                            //   fontSize: 12.0,
                            //   fontWeight: FontWeight.w600,
                            // ),
                          )
                        ]
                      : msg.senderId != widget.sender.uid
                          ? generateReceiverLayout(
                              msg,
                            )
                          : generateSenderLayout(msg)),
            ),
          );
        })
        .toList()
        .reversed
        .toList();
  }

  void moreBtn(
      {@required BuildContext context,
      @required CreateAccountData currentUser,
      @required CreateAccountData anotherUser}) async {
    var value = await showDialog(
        context: context,
        builder: (context) => MoreOptionDialog(
              currentUser: currentUser,
              anotherUser: anotherUser,
              isUnfriend: true,
            ));

    if (value == "block") {
      Navigator.of(context).pop();
      init();
    } else if (value == "unfriend") {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDarkMode ? dRed : white,
      appBar: AppBar(
          elevation: 0,
          titleSpacing: 0.0,
          backgroundColor: mRed,
          title: Row(
            children: [
              InkWell(
                child: CircleAvatar(
                  backgroundColor: lRed,
                  radius: 20.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: widget.second.profilepic != ''
                        ? CachedNetworkImage(
                            imageUrl: widget.second.profilepic ?? '',
                            useOldImageOnUrlChange: true,
                            placeholder: (context, url) =>
                                CupertinoActivityIndicator(
                              radius: 15,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Image.asset(placeholderImage, fit: BoxFit.cover),
                  ),
                ),
                onTap: !isDeleted
                    ? !isHidden
                        ? !isBlocked
                            ? () => showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return Info(widget.second, widget.sender);
                                }).then((value) => Navigator.of(context).pop())
                            : null
                        : null
                    : null,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                widget.second.name.toUpperCase(),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            // color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            SizedBox(
              width: 13,
            ),
            Tooltip(
              message: "More".tr(),
              preferBelow: false,
              child: IconButton(
                icon: Icon(
                  (CupertinoIcons.ellipsis_vertical),
                ),
                onPressed: () {
                  moreBtn(
                      context: context,
                      currentUser: widget.sender,
                      anotherUser: widget.second);
                },
              ),
            ),
          ]),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0)),
                    color: themeProvider.isDarkMode ? dRed : white,
                    // themeProvider.isDarkMode? dRed : white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      if (minusOneDay != null)
                        StreamBuilder(
                          stream: userChatRef
                              .orderByChild("createdAt")
                              .startAt(minusOneDay)
                              .limitToLast(chatMsgsLimit)
                              .onValue,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            // print("Chat Detail : ");
                            updateMinusOneDay();
                            if (!snapshot.hasData) {
                              return Container(

                                  child: LinearProgressCustomBar()

                                  );
                            } else {


                              if (snapshot.data.snapshot.exists) {
                                userCollRef
                                    .doc(widget.sender.uid)
                                    .collection(chatCountCollectionName)
                                    .doc("count")
                                    .update({
                                  "isRead": true,
                                  "new": 0,
                                }).catchError((e) {
                                  print(e.code);
                                  if (e.code == "not-found") {
                                    userCollRef
                                        .doc(widget.sender.uid)
                                        .collection(chatCountCollectionName)
                                        .doc("count")
                                        .set({
                                      "isRead": true,
                                      "new": 0,
                                    });
                                  }
                                });


                                final mapKeys =
                                    snapshot.data.snapshot.value.keys.toList();
                                Map maps =
                                    HashMap.from(snapshot.data.snapshot.value);
                                List<ChatMessageModel> chats = [];

                                for (int i = 0; i < mapKeys.length; i++) {
                                  maps[mapKeys[i].toString()]["msgId"] =
                                      mapKeys[i].toString();
                                  chats.add(ChatMessageModel.fromJson(
                                      maps[mapKeys[i].toString()]));
                                }



                                return Expanded(
                                  child: ListView(
                                    reverse: true,
                                    children:
                                        generateMessages(chats), //TODO: error
                                  ),
                                );
                              }
                            }
                            return Expanded(
                              child: ListView(
                                reverse: true,
                                children: generateMessages([]), //TODO: error
                              ),
                            );
                          },
                        ),
                      Divider(height: 1.0),
                      Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          borderRadius: replyMessage != null
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                )
                              : null,
                          color: themeProvider.isDarkMode
                              ? mBlack
                              : Colors.grey[100],
                        ),
                        child: blockedModel != null
                            ? blockedModel.blockedBy == widget.sender.uid
                                ? Text("Unblock to Continue".tr(),
                                    style: TextStyle(
                                        fontFamily: 'Handlee',
                                        fontWeight: FontWeight.w700,
                                        color: lRed,
                                        decoration: TextDecoration.none,
                                        fontSize: 22))
                                : Text("User not Available".tr(),
                                    style: TextStyle(
                                        fontFamily: 'Handlee',
                                        fontWeight: FontWeight.w700,
                                        color: lRed,
                                        decoration: TextDecoration.none,
                                        fontSize: 22))
                            : isHidden
                                ? Text("Profile Hidden.".tr(),
                                    style: TextStyle(
                                        fontFamily: 'Handlee',
                                        fontWeight: FontWeight.w700,
                                        color: lRed,
                                        decoration: TextDecoration.none,
                                        fontSize: 22))
                                : isBlocked
                                    ? Text(
                                        "Sorry, you can't send a message.".tr(),
                                        style: TextStyle(
                                            fontFamily: 'Handlee',
                                            fontWeight: FontWeight.w700,
                                            color: lRed,
                                            decoration: TextDecoration.none,
                                            fontSize: 22))
                                    : isDeleted
                                        ? Text("Profile Deleted.".tr(),
                                            style: TextStyle(
                                                fontFamily: 'Handlee',
                                                fontWeight: FontWeight.w700,
                                                color: lRed,
                                                decoration: TextDecoration.none,
                                                fontSize: 22))
                                        : _buildTextComposer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isFetched)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: LinearProgressCustomBar(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getDefaultSendButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Transform.rotate(
        angle: -pi / 9,
        child: Icon(
          Icons.send,
          size: 25,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconTheme(
        data: IconThemeData(
            color: _textController.text.trim().length > 0 ? mRed : lRed),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyMessage != null)
                Container(
                  color: themeProvider.isDarkMode
                      ? lRed.withOpacity(.3)
                      : lRed.withOpacity(.3),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            replyMessage.senderId == widget.sender.uid
                                ? "You".tr()
                                : widget.second.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          )),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyMessage = null;
                              });
                            },
                            child: Icon(
                              Icons.cancel_outlined,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : mBlack,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        replyMessage.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white54
                              : mBlack,
                        ),
                      )
                    ],
                  ),
                ),
              if (replyMessage != null)
                Divider(
                  height: 0.0,
                  color: Colors.white54,
                ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.photo_camera,
                            color: mRed,
                          ),
                          onPressed: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => RTChatSendMedia(
                                      chatId: widget.chatId,
                                      second: widget.second,
                                      sender: widget.sender,
                                    )));
                          }),
                    ),
                    new Flexible(
                      child: new TextFormField(

                        controller: _textController,
                        maxLines: 15,
                        minLines: 1,
                        onChanged: (String messageText) {

                        },
                        decoration: new InputDecoration.collapsed(
                            floatingLabelBehavior: FloatingLabelBehavior.auto,

                            hintText: "Send a message...".tr()),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_textController.text.trim().length > 0)
                          _sendText(_textController.text.trimRight());
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: getDefaultSendButton(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText(String text) async {
    _textController.clear();
    DateTime now = await NTP.now();
    ChatMessageModel message = ChatMessageModel(
      receiverId: widget.second.uid,
      senderId: widget.sender.uid,
      senderName: widget.sender.name,
      text: text,
      imageUrl: "",
      isRead: false,
      liked: false,
      type: MessageType.text,
      createdAt: now.millisecondsSinceEpoch,
      replyChatMessage: replyMessage,
    );


    await userChatRef.push().set(message.toJson()).then((value) {
      userCollRef
          .doc(widget.second.uid)
          .collection(chatCountCollectionName)
          .doc("count")
          .update({
        "isRead": false,
        "new": FieldValue.increment(1),
      }).catchError((e) {
        print(e.code);
        if (e.code == "not-found") {
          userCollRef
              .doc(widget.second.uid)
              .collection(chatCountCollectionName)
              .doc("count")
              .set({
            "isRead": false,
            "new": FieldValue.increment(1),
          });
        }
      });
    }).catchError((e) {
      print("Send Text Error: $e");
      //TODO: toast something went wrong
    });
    cancelReplyMessage();
  }

  Future<void> onJoin(callType) async {
    if (blockedModel == null || !isHidden || !isDeleted || !isBlocked) {

      Map<Permission, PermissionStatus> status = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (status[Permission.camera].isGranted) {
        if (status[Permission.microphone].isGranted) {
          ChatMessageModel message = ChatMessageModel(
              receiverId: widget.second.uid,
              senderId: widget.sender.uid,
              senderName: widget.sender.name,
              text: callType,
              imageUrl: "",
              liked: false,
              isRead: false,
              type: MessageType.videoCall,
              createdAt: Timestamp.now().millisecondsSinceEpoch);

          print(message.toJson());

          await userChatRef.push().set(message.toJson()).then((value) {
            setState(() {
              _textController.clear();
            });
          }).catchError((e) {
            print("Send Text Error: $e");
            //TODO: toast something went wrong
          });

        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "Blocked!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
