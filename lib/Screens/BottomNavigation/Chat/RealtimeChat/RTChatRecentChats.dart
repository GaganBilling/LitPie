import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:litpie/Screens/BottomNavigation/Chat/RealtimeChat/RTChatPage.dart';
import 'package:ntp/ntp.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/unfriendController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/models/recentChatModel.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/buildShimmerListView.dart';
import 'package:litpie/widgets/moreOptionDialog.dart';
import 'package:litpie/widgets/slideableWidget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class RTChatRecentChats extends StatefulWidget {
  final CreateAccountData currentUser;

  RTChatRecentChats(this.currentUser);

  @override
  _RTChatRecentChatsState createState() => _RTChatRecentChatsState();
}

class _RTChatRecentChatsState extends State<RTChatRecentChats> {
  final db = FirebaseFirestore.instance;
  FirebaseDatabase rtDB = new FirebaseDatabase();
  DatabaseReference chatRef;
  CollectionReference userCollRef;
  List<RecentChatModel> recentChats;
  List<RecentChatModel> tempRecentChats = [];
  int minusOneDay;

  @override
  initState() {
    chatRef = rtDB.reference().child("chats");
    userCollRef = db.collection(userCollectionName);
    updateMinusOneDay();
    readNotificationCounter();
    super.initState();
  }

  void readNotificationCounter() {
    userCollRef.doc(widget.currentUser.uid).collection(chatCountCollectionName).doc("count").set({
      "isRead": true,
      "new": 0,
    });
  }

  //double _maxScreenWidth;

  void updateMinusOneDay() async {
    DateTime serverDateTime = await NTP.now();
    minusOneDay = Timestamp.fromDate(serverDateTime.subtract(Duration(hours: 24))).millisecondsSinceEpoch;
    getRecentChat();
  }

  getRecentChat() {
    try{
      chatRef.onValue.listen((event) async {
        tempRecentChats = [];
        DataSnapshot data = event.snapshot;
        List mapKeys=[];
        if (data.exists) {
          data.children
            ..forEach((element) {
              mapKeys.add(element.key);
              print(mapKeys.length);
            });

          for (int i = 0; i < mapKeys.length; i++) {
            if (mapKeys[i].toString().contains(widget.currentUser.uid)) {
              Map<String, dynamic> recentChatJson = {};
              DatabaseEvent chatSnapshot = await chatRef.child(mapKeys[i].toString()).child("messages").orderByChild("createdAt").limitToLast(1).once();
              if (chatSnapshot.snapshot.exists) {
                recentChatJson["chatId"] = mapKeys[i].toString();
                Map lastMessagesMap = HashMap.from(chatSnapshot.snapshot.value);
                String lastMsgId = lastMessagesMap.keys.toList()[0];
                recentChatJson["lastMessage"] = lastMessagesMap[lastMsgId];
                recentChatJson["lastMessage"]["msgId"] = lastMsgId;

                List usersIds = mapKeys[i].toString().split('-');
                String userId = usersIds[0] == widget.currentUser.uid ? usersIds[1] : usersIds[0];
                CreateAccountData userDetail = await getUserDetail(userId);
                tempRecentChats.add(RecentChatModel.fromJson(userDetail: userDetail, json: recentChatJson));
              }
            }
          }
        }
        if (!mounted) return;
        tempRecentChats.sort((a, b) {
          return b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt);
        });
        setState(() {
          recentChats = tempRecentChats;
        });
      });
    }catch(e){
      print(e.toString());
    }
  }

  Future<CreateAccountData> getUserDetail(String uid) async {
    var data = await userCollRef.doc(uid).get();
    return CreateAccountData.fromDocument(data.data());
  }

  double _screenWidth;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _screenWidth = MediaQuery.of(context).size.width;
    return recentChats == null || minusOneDay == null
        ? BuildShimmerListView()
        : recentChats.isEmpty
            ? Container(
                child: Center(
                  child: Text(
                    "No Message".tr(),
                    style: TextStyle(color: lRed, fontSize: 16),
                  ),
                ),
              ) //empty content
            : RefreshIndicator(
                color: Colors.white,
                backgroundColor: mRed,
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                  return null;
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: recentChats.length,
                    itemBuilder: (context, index) {
                      return SlidableWidget(
                        onDismissed: (action) => dismissSlidableItem(context, index, action),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => RTChatPage(
                                          sender: widget.currentUser,
                                          second: recentChats[index].userDetail,
                                          chatId: recentChats[index].chatId,
                                        )))
                                .whenComplete(() {
                              setState(() {
                                recentChats = null;
                              });
                              updateMinusOneDay();
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: Colors.blueGrey, offset: Offset(2, 2), spreadRadius: 2, blurRadius: 3),
                              ],
                              color: themeProvider.isDarkMode ? dRed : white,
                              //  color: snapshot.data.docs[0]['sender_id'] != currentUser.uid && !snapshot.data.docs[0]['isRead'] ? mRed.withOpacity(.1) : lRed.withOpacity(.2),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: lRed,
                                radius: 30.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: recentChats[index].userDetail.profilepic != ""
                                      ? CachedNetworkImage(
                                          imageUrl: recentChats[index].userDetail.profilepic ?? '',
                                          useOldImageOnUrlChange: true,
                                          placeholder: (context, url) => CupertinoActivityIndicator(
                                            radius: 15,
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        )
                                      : Image.asset(placeholderImage, fit: BoxFit.cover),
                                ),
                              ),
                              title: Text(
                                recentChats[index].userDetail.name.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: _screenWidth >= miniScreenWidth ? 16.0 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: recentChats[index].lastMessage.createdAt < minusOneDay
                                  ? Text("Messages Disappeared!!".tr())
                                  : Text(
                                      recentChats[index].lastMessage.text,
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: _screenWidth >= miniScreenWidth ? 15.0 : 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              trailing: recentChats[index].lastMessage.createdAt < minusOneDay
                                  ? GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext buildContext) {
                                              return SimpleDialog(
                                                contentPadding: EdgeInsets.all(10.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                backgroundColor: Colors.blueGrey.withOpacity(0.5),
                                                children: [
                                                  Text("Messages will disappear after 24 Hours whether read or not.\n So it is better to stay active.".tr(),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'Handlee',
                                                          fontWeight: FontWeight.w700,
                                                          color: white,
                                                          decoration: TextDecoration.none,
                                                          fontSize: _screenWidth >= miniScreenWidth ? 20 : 16)),
                                                ],
                                              );
                                            });
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          recentChats[index].lastMessage.createdAt != null
                                              ? DateFormat.MMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(recentChats[index].lastMessage.createdAt)).toString()
                                              : "",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: _screenWidth >= miniScreenWidth ? 15.0 : 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        recentChats[index].lastMessage.senderId != widget.currentUser.uid && !recentChats[index].lastMessage.isRead
                                            ? Container(
                                                width: 50.0,
                                                height: 20.0,
                                                decoration: BoxDecoration(
                                                  color: mRed,
                                                  borderRadius: BorderRadius.circular(30.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "NEW".tr(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Text(""),
                                        //it is fetching live, bcoz of stream listen//
                                        recentChats[index].lastMessage.senderId == widget.currentUser.uid && !recentChats[index].lastMessage.isRead
                                            ? Icon(
                                                Icons.done,
                                                color: lRed,
                                                size: 15,
                                              )
                                            : recentChats[index].lastMessage.senderId != widget.currentUser.uid && !recentChats[index].lastMessage.isRead
                                                ? SizedBox.shrink()
                                                : Icon(
                                                    Icons.done_all,
                                                    color: mRed,
                                                    size: 15,
                                                  ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
  }

  void dismissSlidableItem(BuildContext context, int index, SlidableAction action) {
    setState(() {
    });

    switch (action) {
      case SlidableAction.more:
        moreBtn(context: context, currentUser: widget.currentUser, anotherUser: recentChats[index].userDetail);
        break;
      case SlidableAction.unfriend:
        unfriendBtn(context: context, currentUser: widget.currentUser, anotherUser: recentChats[index].userDetail);

        break;
    }
  }

  void unfriendBtn({@required BuildContext context, @required CreateAccountData currentUser, @required CreateAccountData anotherUser}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: themeProvider.isDarkMode ? black.withOpacity(.5) : white.withOpacity(.5),
              content: Container(
                // height: MediaQuery.of(context).size.height / 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Are You Sure you want to unfriend".tr() + " ${anotherUser.name.toUpperCase()}?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 30, right: 30),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          UnFriendController().unFriendUser(currentUserId: currentUser.uid, anotherUserId: anotherUser.uid).catchError((e) {}).then((value) {
                            Navigator.of(context).pop();
                            Fluttertoast.showToast(
                                msg: "Unfriended".tr(),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          });
                        },
                        child: Text(
                          "Unfriend".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: mRed,
                          onPrimary: white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 30, right: 30),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _screenWidth >= miniScreenWidth ? 20 : 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: themeProvider.isDarkMode ? mBlack : white,
                          onPrimary: Colors.blue[700],
                          //  padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.7)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void moreBtn({@required BuildContext context, @required CreateAccountData currentUser, @required CreateAccountData anotherUser}) async {
    showDialog(context: context, builder: (context) => MoreOptionDialog(currentUser: currentUser, anotherUser: anotherUser));
  }
}
