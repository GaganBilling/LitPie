import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/Screens/BottomNavigation/notifications/notification_provider.dart';
import 'package:litpie/Screens/Information.dart';
import 'package:litpie/Screens/my_post/myPost.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/common/Utils.dart';
import 'package:litpie/constants.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class Notifications extends StatefulWidget {
  final CreateAccountData currentUser;
  final int tabRedirectIndex;

  Notifications({this.currentUser, this.tabRedirectIndex = 0});

  @override
  _NotificationsState createState() => new _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin {
  NotificationProvider notificationProvider;

  @override
  void initState() {
    //  FlutterAppBadger.removeBadge();
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    super.initState();
    notificationProvider.tabController = TabController(
        vsync: this, length: 3, initialIndex: widget.tabRedirectIndex);
    notificationProvider.scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    notificationProvider.tabController.dispose();
    notificationProvider.scrollViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: mRed,
          centerTitle: true,
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("Notifications".tr())),
                dropDownButton()
              ]),
        ),
        body: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: selectedDropDownItem(
                      notificationProvider.dropdownValue, context),
                ),
              )),
        ),
      );
    });
  }

  //Change dropDownValue
  Widget dropDownButton() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            offset: const Offset(0, 0),
            iconEnabledColor: Colors.white,
            itemPadding: EdgeInsets.symmetric(horizontal: 12.0),
            hint: Center(
                child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: (notificationProvider.dropdownValue == "Post" ||
                          notificationProvider.dropdownValue == "LitPie" ||
                          notificationProvider.dropdownValue == "All")
                      ? 50.0
                      : 20.0),
              child: Text(
                notificationProvider.dropdownValue,
                style: TextStyle(color: Colors.white),
              ),
            )),
            style: TextStyle(color: Colors.white),
            selectedItemBuilder: (BuildContext context) {
              return notificationProvider.items.map((String value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Row(
                      children: [
                        Text(
                          notificationProvider.dropdownValue,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            items: notificationProvider.items.map((selectedType) {
              return DropdownMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedType,
                        style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    getUnreadCountString(selectedType),
                  ],
                ),
                value: selectedType,
              );
            }).toList(),
            onChanged: (newValue) async {
              await notificationProvider.changeDropDownValue(newValue);
            },
          ),
        ),
      );
    });
  }

  Widget selectedDropDownItem(String dropdownValue, BuildContext context) {
    switch (dropdownValue) {
      case "Post":
        return notificationProvider.isPostLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.postNotificationList.length > 0
                ? likeNotificationWidgetBuilder()
                : Center(child: Text("No post notifications".tr())));

      case "Comments":
        return notificationProvider.isCommentLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.commentsNotificationList.length > 0
                ? commentNotificationWidgetBuilder()
                : Center(child: Text("No comment notifications".tr())));
      case "Plan Request":
        return notificationProvider.isPlanRequestLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.planRequestNotificationList.length > 0
                ? planRequestNotificationWidgetBuilder()
                : Center(child: Text("No plan request notifications".tr())));

      case "LitPie":
        return notificationProvider.isLitPieLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.litpieNotificationList.length > 0
                ? litpieNotificationWidgetBuilder()
                : Center(child: Text("No LitPie notifications".tr())));

      case "Matches":
        return notificationProvider.isMatchLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.matchesNotificationList.length > 0
                ? matchesNotificationWidgetBuilder(context)
                : Center(child: Text("No matches notifications")));

      default:
        return notificationProvider.isAllLoading
            ? Center(
                child: LinearProgressCustomBar(),
              )
            : (notificationProvider.allNotificationList.length > 0
                ? allNotificationBuilder()
                : Center(child: Text("No notifications")));
    }
  }

  likeNotificationWidgetBuilder() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView.builder(
        shrinkWrap: true,
        itemCount: 2,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var likeNotificationList = notificationProvider.postNotificationList
              .where((element) => element['type'] == "Likes")
              .toList();
          var commentNotificationList = notificationProvider
              .postNotificationList
              .where((element) => element['type'] == "Comments")
              .toList();
          if (index == 0) {
            return likeNotificationList.length > 0
                ? ListView.builder(
                    itemCount: likeNotificationList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                          stream: notificationProvider
                              .firebaseController.userColReference
                              .where("uid",
                                  isEqualTo: likeNotificationList[index]
                                      ["likedBy"])
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData)
                              return Center(
                                child: SizedBox.shrink(),
                              );
                            QuerySnapshot data = snapshot.data;
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (thisContext) {
                                      notificationProvider.dialogContext =
                                          thisContext;
                                      return MyPollScreen();
                                    }).whenComplete(() {});
                                notificationProvider.checkedNotification(
                                    likeNotificationList[index]["type"],
                                    index,
                                    likeNotificationList[index]['postId'],
                                    likeNotificationList[index]['_id']);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 2),
                                            spreadRadius: 2,
                                            blurRadius: 3),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                      color: themeProvider.isDarkMode
                                          ? dRed
                                          : white,
                                    ),
                                    // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: themeProvider.isDarkMode
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: likeNotificationList[index]
                                                      ['is_read']
                                                  ? Colors.black
                                                  : Colors.grey.withOpacity(.5))
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: likeNotificationList[index]
                                                      ['is_read']
                                                  ? Colors.white
                                                  : Colors.grey
                                                      .withOpacity(.5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: lRed,
                                            child: data.docs[0]['profilepic'] !=
                                                        null &&
                                                    data.docs[0]['profilepic']
                                                        .isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      25,
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: data.docs[0]
                                                          ['profilepic'],
                                                      fit: BoxFit.cover,
                                                      useOldImageOnUrlChange:
                                                          true,
                                                      placeholder: (context,
                                                              url) =>
                                                          CupertinoActivityIndicator(
                                                        radius: 20,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      25,
                                                    ),
                                                    child: Container(
                                                      height: 65,
                                                      width: 65,
                                                      child: Image.asset(
                                                          placeholderImage,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: Text(
                                                "${data.docs[0]['name']} " +
                                                    "liked your post".tr(),
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          Text(
                                              Utils().convertToAgoAndDate(
                                                  likeNotificationList[index]
                                                          ["createdAt"] *
                                                      1000),
                                              style: TextStyle(fontSize: 12))
                                        ],
                                      ),
                                    )

                                    //  : Container()
                                    ),
                              ),
                            );
                          });
                    })
                : SizedBox.shrink();
          }
          if (index == 1) {
            return commentNotificationList.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: commentNotificationList.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                          stream: notificationProvider
                              .firebaseController.userColReference
                              .where("uid",
                                  isEqualTo: commentNotificationList[index]
                                      ["commentBy"])
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData)
                              return Center(
                                child: SizedBox.shrink(),
                              );
                            QuerySnapshot data = snapshot.data;

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyPollScreen()));
                                notificationProvider.checkedNotification(
                                    commentNotificationList[index]["type"],
                                    index,
                                    commentNotificationList[index]['postId'],
                                    commentNotificationList[index]['_id']);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 2),
                                            spreadRadius: 2,
                                            blurRadius: 3),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                      color: themeProvider.isDarkMode
                                          ? dRed
                                          : white,
                                    ),
                                    // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: themeProvider.isDarkMode
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color:
                                                  commentNotificationList[index]
                                                          ['is_read']
                                                      ? Colors.black
                                                      : Colors.grey
                                                          .withOpacity(.5))
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color:
                                                  commentNotificationList[index]
                                                          ['is_read']
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: lRed,
                                            child: data.docs[0]['profilepic'] !=
                                                        null &&
                                                    data.docs[0]['profilepic']
                                                        .isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      25,
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: data.docs[0]
                                                          ['profilepic'],
                                                      fit: BoxFit.cover,
                                                      useOldImageOnUrlChange:
                                                          true,
                                                      placeholder: (context,
                                                              url) =>
                                                          CupertinoActivityIndicator(
                                                        radius: 20,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      25,
                                                    ),
                                                    child: Container(
                                                      height: 65,
                                                      width: 65,
                                                      child: Image.asset(
                                                          placeholderImage,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: Text(
                                                "${data.docs[0]['name']} " +
                                                    "commented on your post.",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          Text(
                                              Utils().convertToAgoAndDate(
                                                  commentNotificationList[index]
                                                          ["createdAt"] *
                                                      1000),
                                              style: TextStyle(fontSize: 12))
                                        ],
                                      ),
                                    )

                                    //  : Container()
                                    ),
                              ),
                            );
                          });
                    })
                : SizedBox.shrink();
          }
          return Container();
        });
  }

  allNotificationBuilder() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
      return ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, rootIndex) {
            if (rootIndex == 0) {
              var likesNotificationList = notificationProvider
                  .allNotificationList
                  .where((element) => element['type'] == "Likes")
                  .toList();
              return likesNotificationList.length > 0
                  ? ListView.builder(
                      itemCount: likesNotificationList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: notificationProvider
                                .firebaseController.userColReference
                                .where("uid",
                                    isEqualTo: likesNotificationList[index]
                                        ["likedBy"])
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData)
                                return Center(
                                  child: SizedBox.shrink(),
                                );
                              QuerySnapshot data = snapshot.data;
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (thisContext) {
                                        notificationProvider.dialogContext =
                                            thisContext;
                                        return MyPollScreen();
                                      }).whenComplete(() {});
                                  notificationProvider.checkedNotification(
                                      likesNotificationList[index]["type"],
                                      index,
                                      likesNotificationList[index]['postId'],
                                      likesNotificationList[index]['_id']);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: themeProvider.isDarkMode
                                            ? BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color:
                                                    likesNotificationList[index]
                                                            ['is_read']
                                                        ? Colors.black
                                                        : Colors.grey
                                                            .withOpacity(.5))
                                            : BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color:
                                                    likesNotificationList[index]
                                                            ['is_read']
                                                        ? Colors.white
                                                        : Colors.grey
                                                            .withOpacity(.5)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor: lRed,
                                              child: data.docs[0]
                                                              ['profilepic'] !=
                                                          null &&
                                                      data.docs[0]['profilepic']
                                                          .isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data.docs[0]
                                                            ['profilepic'],
                                                        fit: BoxFit.cover,
                                                        useOldImageOnUrlChange:
                                                            true,
                                                        placeholder: (context,
                                                                url) =>
                                                            CupertinoActivityIndicator(
                                                          radius: 20,
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: Container(
                                                        height: 65,
                                                        width: 65,
                                                        child: Image.asset(
                                                            placeholderImage,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: Text(
                                                  "${data.docs[0]['name']} " +
                                                      "liked your post"
                                                          .tr()
                                                          .tr(),
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            Text(
                                                Utils().convertToAgoAndDate(
                                                    likesNotificationList[index]
                                                            ["createdAt"] *
                                                        1000),
                                                style: TextStyle(fontSize: 12))
                                          ],
                                        ),
                                      )

                                      //  : Container()
                                      ),
                                ),
                              );
                            });
                      })
                  : SizedBox.shrink();
            } else if (rootIndex == 1) {
              var commentNotificationList = notificationProvider
                  .allNotificationList
                  .where((element) =>
                      element['type'] == "Comments" ||
                      element['type'] == "CommentsLikes")
                  .toList();
              return commentNotificationList.length > 0
                  ? ListView.builder(
                      itemCount: commentNotificationList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: notificationProvider
                                .firebaseController.userColReference
                                .where("uid",
                                    isEqualTo: commentNotificationList[index]
                                        ["commentBy"])
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData)
                                return Center(
                                  child: SizedBox.shrink(),
                                );
                              QuerySnapshot data = snapshot.data;

                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyPollScreen()));
                                  notificationProvider.checkedNotification(
                                      commentNotificationList[index]["type"],
                                      index,
                                      commentNotificationList[index]['postId'],
                                      commentNotificationList[index]['_id']);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: themeProvider.isDarkMode
                                            ? BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: commentNotificationList[
                                                        index]['is_read']
                                                    ? Colors.black
                                                    : Colors.grey
                                                        .withOpacity(.5))
                                            : BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: commentNotificationList[
                                                        index]['is_read']
                                                    ? Colors.white
                                                    : Colors.grey
                                                        .withOpacity(.5)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor: lRed,
                                              child: data.docs[0]
                                                              ['profilepic'] !=
                                                          null &&
                                                      data.docs[0]['profilepic']
                                                          .isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data.docs[0]
                                                            ['profilepic'],
                                                        fit: BoxFit.cover,
                                                        useOldImageOnUrlChange:
                                                            true,
                                                        placeholder: (context,
                                                                url) =>
                                                            CupertinoActivityIndicator(
                                                          radius: 20,
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: Container(
                                                        height: 65,
                                                        width: 65,
                                                        child: Image.asset(
                                                            placeholderImage,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: Text(
                                                  "${data.docs[0]['name']} " +
                                                      "commented on your post.",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            Text(
                                                Utils().convertToAgoAndDate(
                                                    commentNotificationList[
                                                                index]
                                                            ["createdAt"] *
                                                        1000),
                                                style: TextStyle(fontSize: 12))
                                          ],
                                        ),
                                      )

                                      //  : Container()
                                      ),
                                ),
                              );
                            });
                      })
                  : SizedBox.shrink();
            } else if (rootIndex == 2) {
              var litPieNotificationList = notificationProvider
                  .allNotificationList
                  .where((element) => element['type'] == "LitPie")
                  .toList();
              return litPieNotificationList.length > 0
                  ? ListView.builder(
                      itemCount: litPieNotificationList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: notificationProvider
                                .firebaseController.userColReference
                                .where("uid",
                                    isEqualTo: litPieNotificationList[index]
                                        ["litPieBy"])
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData)
                                return Center(
                                  child: SizedBox.shrink(),
                                );
                              QuerySnapshot data = snapshot.data;

                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  navigateToLitPieScreen(
                                      litPieNotificationList[index]['litPieTo'],
                                      litPieNotificationList[index]['litPieBy'],
                                      context,
                                      litPieNotificationList[index]['_id']);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                              blurRadius: 3),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: themeProvider.isDarkMode
                                            ? dRed
                                            : white,
                                      ),
                                      // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: themeProvider.isDarkMode
                                            ? BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: litPieNotificationList[
                                                        index]['is_read']
                                                    ? Colors.black
                                                    : Colors.grey
                                                        .withOpacity(.5))
                                            : BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: litPieNotificationList[
                                                        index]['is_read']
                                                    ? Colors.white
                                                    : Colors.grey
                                                        .withOpacity(.5)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor: lRed,
                                              child: data.docs[0]
                                                              ['profilepic'] !=
                                                          null &&
                                                      data.docs[0]['profilepic']
                                                          .isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data.docs[0]
                                                            ['profilepic'],
                                                        fit: BoxFit.cover,
                                                        useOldImageOnUrlChange:
                                                            true,
                                                        placeholder: (context,
                                                                url) =>
                                                            CupertinoActivityIndicator(
                                                          radius: 20,
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                      child: Container(
                                                        height: 65,
                                                        width: 65,
                                                        child: Image.asset(
                                                            placeholderImage,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: Text(
                                                  "${data.docs[0]['name']} sent you a litpie.",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            Text(
                                                Utils().convertToAgoAndDate(
                                                    litPieNotificationList[
                                                                index]
                                                            ['createdAt'] *
                                                        1000),
                                                style: TextStyle(fontSize: 12))
                                          ],
                                        ),
                                      )),
                                ),
                              );
                            });
                      },
                    )
                  : SizedBox.shrink();
            } else if (rootIndex == 3) {
              var planRequestNotificaitonList = notificationProvider
                  .allNotificationList
                  .where((element) => element['type'] == "Plan Request")
                  .toList();
              return planRequestNotificaitonList.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: planRequestNotificaitonList.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: notificationProvider
                                .firebaseController.userColReference
                                .where("uid",
                                    isEqualTo:
                                        planRequestNotificaitonList[index]
                                            ["requestSendBy"])
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData)
                                return Center(
                                  child: SizedBox.shrink(),
                                );
                              QuerySnapshot data = snapshot.data;

                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  navigateToPlanRequestScreenInfo(
                                          planRequestNotificaitonList[index]
                                              ['requestSendBy'],
                                          planRequestNotificaitonList[
                                                  index] //pdataOwnerID
                                              ['pdataOwnerID'],
                                          context,
                                          planRequestNotificaitonList[index]
                                              ['planId'])
                                      .whenComplete(() {
                                    notificationProvider.checkedNotification(
                                        planRequestNotificaitonList[index]
                                            ["type"],
                                        index,
                                        planRequestNotificaitonList[index]
                                            ['planId'],
                                        planRequestNotificaitonList[index]
                                            ['planId'],
                                        requestBy:
                                            planRequestNotificaitonList[index]
                                                [index]['requestSendBy']);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 2),
                                            spreadRadius: 2,
                                            blurRadius: 3),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                      color: themeProvider.isDarkMode
                                          ? dRed
                                          : white,
                                    ),
                                    // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: themeProvider.isDarkMode
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color:
                                                  planRequestNotificaitonList[
                                                          index]['is_read']
                                                      ? Colors.black
                                                      : Colors.grey
                                                          .withOpacity(.5))
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color:
                                                  planRequestNotificaitonList[
                                                          index]['is_read']
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.5)),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(5),
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: lRed,
                                          child: data.docs[0]['profilepic'] !=
                                                      null &&
                                                  data.docs[0]['profilepic']
                                                      .isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: data.docs[0]
                                                        ['profilepic'],
                                                    fit: BoxFit.cover,
                                                    useOldImageOnUrlChange:
                                                        true,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(
                                                      radius: 20,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(
                                                      Icons.error,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25,
                                                  ),
                                                  child: Container(
                                                    height: 65,
                                                    width: 65,
                                                    child: Image.asset(
                                                        placeholderImage,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                        ),
                                        title: Text(
                                            "${data.docs[0]['name']} "
                                                    .toUpperCase() +
                                                " is interested in".tr() +
                                                " ${planRequestNotificaitonList[index]["pName"]} "
                                                    .toUpperCase(),
                                            style: TextStyle(fontSize: 15)),
                                        subtitle: Text(
                                            "Only you can start the CHAT.".tr(),
                                            style: TextStyle(fontSize: 12)),
                                        trailing: Text(
                                            Utils().convertToAgoAndDate(
                                                planRequestNotificaitonList[
                                                        index]["createdAt"] *
                                                    1000),
                                            style: TextStyle(fontSize: 12)),
                                      ),

                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   crossAxisAlignment:
                                      //       CrossAxisAlignment.center,
                                      //   children: [
                                      //     CircleAvatar(
                                      //       radius: 25,
                                      //       backgroundColor: lRed,
                                      //       child: data.docs[0]['profilepic'] !=
                                      //                   null &&
                                      //               data.docs[0]['profilepic']
                                      //                   .isNotEmpty
                                      //           ? ClipRRect(
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                 25,
                                      //               ),
                                      //               child: CachedNetworkImage(
                                      //                 imageUrl: data.docs[0]
                                      //                     ['profilepic'],
                                      //                 fit: BoxFit.cover,
                                      //                 useOldImageOnUrlChange:
                                      //                     true,
                                      //                 placeholder: (context,
                                      //                         url) =>
                                      //                     CupertinoActivityIndicator(
                                      //                   radius: 20,
                                      //                 ),
                                      //                 errorWidget: (context,
                                      //                         url, error) =>
                                      //                     Icon(
                                      //                   Icons.error,
                                      //                   color: Colors.black,
                                      //                 ),
                                      //               ),
                                      //             )
                                      //           : ClipRRect(
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                 25,
                                      //               ),
                                      //               child: Container(
                                      //                 height: 65,
                                      //                 width: 65,
                                      //                 child: Image.asset(
                                      //                     placeholderImage,
                                      //                     fit: BoxFit.cover),
                                      //               ),
                                      //             ),
                                      //     ),
                                      //     Expanded(
                                      //       child: Container(
                                      //         padding: EdgeInsets.symmetric(
                                      //             horizontal: 5.0),
                                      //         child: Column(
                                      //           children: [
                                      //             Text(
                                      //               "${data.docs[0]['name']} " +
                                      //                   "sent you a request.",
                                      //               style:
                                      //                   TextStyle(fontSize: 14),
                                      //             ),
                                      //             Text(
                                      //               "Only you can start the CHAT."
                                      //                   .tr(),
                                      //               style:
                                      //                   TextStyle(fontSize: 14),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Text(
                                      //         Utils().convertToAgoAndDate(
                                      //             planRequestNotificaitonList[
                                      //                     index]["createdAt"] *
                                      //                 1000),
                                      //         style: TextStyle(fontSize: 12))
                                      //   ],
                                      // ),
                                    ),
                                    //  : Container()
                                  ),
                                ),
                              );
                            });
                      })
                  : SizedBox.shrink();
            } else {
              var matchesNotificationList = notificationProvider
                  .allNotificationList
                  .where((element) => element['type'] == "Matches")
                  .toList();
              return matchesNotificationList.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: matchesNotificationList.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (matchesNotificationList[index]["currentUser"] !=
                            notificationProvider.currentUser.uid) {
                          return StreamBuilder(
                              stream: notificationProvider
                                  .firebaseController.userColReference
                                  .where("uid",
                                      isEqualTo: matchesNotificationList[index]
                                          ["currentUser"])
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData)
                                  return Center(
                                    child: SizedBox.shrink(),
                                  );

                                QuerySnapshot data = snapshot.data;
                                notificationProvider.getAnotherData(index);

                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    navigateToNextScreen(
                                        notificationProvider
                                            .matchesAnotherDoc["matches"],
                                        notificationProvider
                                            .matchesAnotherDoc["currentUser"],
                                        context,
                                        notificationProvider.matchesAnotherDoc,
                                        matchesNotificationList[index]['_id']);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.blueGrey,
                                                offset: Offset(2, 2),
                                                spreadRadius: 2,
                                                blurRadius: 3),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: (themeProvider.isDarkMode
                                              ? dRed
                                              : white),
                                        ),
                                        // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: themeProvider.isDarkMode
                                              ? BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color:
                                                      matchesNotificationList[
                                                              index]['is_read']
                                                          ? Colors.black
                                                          : Colors.grey
                                                              .withOpacity(.5))
                                              : BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color:
                                                      matchesNotificationList[
                                                              index]['is_read']
                                                          ? Colors.white
                                                          : Colors.grey
                                                              .withOpacity(.5)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: lRed,
                                                child: data.docs[0][
                                                                'profilepic'] !=
                                                            null &&
                                                        data
                                                            .docs[0]
                                                                ['profilepic']
                                                            .isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          25,
                                                        ),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: data.docs[0]
                                                              ['profilepic'],
                                                          fit: BoxFit.cover,
                                                          useOldImageOnUrlChange:
                                                              true,
                                                          placeholder: (context,
                                                                  url) =>
                                                              CupertinoActivityIndicator(
                                                            radius: 20,
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.error,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          25,
                                                        ),
                                                        child: Container(
                                                          height: 65,
                                                          width: 65,
                                                          child: Image.asset(
                                                              placeholderImage,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Expanded(
                                                child: Text(
                                                    "You are matched with"
                                                            .tr() +
                                                        " ${data.docs[0]['name'] ?? "__"}."
                                                            .toUpperCase(),
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: <Widget>[
                                                        notificationProvider
                                                                    .matchesAnotherDoc ==
                                                                null
                                                            ? SizedBox.shrink()
                                                            : !notificationProvider
                                                                        .matchesAnotherDoc[
                                                                    'is_read']
                                                                ? Container(
                                                                    width: 50.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          mRed,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      "NEW"
                                                                          .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Text(""),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Text(
                                                      Utils().convertToAgoAndDate(
                                                          matchesNotificationList[
                                                                      index][
                                                                  "createdAt"] *
                                                              1000),
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ],
                                              )
                                            ],
                                          ),
                                        )

                                        //  : Container()
                                        ),
                                  ),
                                );
                              });
                        } else {
                          return StreamBuilder(
                              stream: notificationProvider
                                  .firebaseController.userColReference
                                  .where("uid",
                                      isEqualTo: notificationProvider
                                              .matchesNotificationList[index]
                                          ["matches"])
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData)
                                  return Center(
                                    child: SizedBox.shrink(),
                                  );
                                QuerySnapshot data = snapshot.data;
                                notificationProvider.getData(
                                    notificationProvider
                                            .matchesNotificationList[index]
                                        ["currentUser"],
                                    notificationProvider
                                            .matchesNotificationList[index]
                                        ["matches"]);
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    navigateToNextScreen(
                                        notificationProvider
                                            .matchesDoc["matches"],
                                        notificationProvider
                                            .matchesDoc["currentUser"],
                                        context,
                                        notificationProvider.matchesDoc,
                                        notificationProvider
                                                .matchesNotificationList[index]
                                            ['_id']);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.blueGrey,
                                                offset: Offset(2, 2),
                                                spreadRadius: 2,
                                                blurRadius: 3),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: themeProvider.isDarkMode
                                              ? dRed
                                              : white,
                                        ),
                                        // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: themeProvider.isDarkMode
                                              ? BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: notificationProvider
                                                              .matchesNotificationList[index]
                                                          ['is_read']
                                                      ? Colors.black
                                                      : Colors.grey
                                                          .withOpacity(.5))
                                              : BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: notificationProvider
                                                              .matchesNotificationList[
                                                          index]['is_read']
                                                      ? Colors.white
                                                      : Colors.grey.withOpacity(.5)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: lRed,
                                                child: data.docs[0][
                                                                'profilepic'] !=
                                                            null &&
                                                        data
                                                            .docs[0]
                                                                ['profilepic']
                                                            .isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          25,
                                                        ),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: data.docs[0]
                                                              ['profilepic'],
                                                          fit: BoxFit.cover,
                                                          useOldImageOnUrlChange:
                                                              true,
                                                          placeholder: (context,
                                                                  url) =>
                                                              CupertinoActivityIndicator(
                                                            radius: 20,
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.error,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          25,
                                                        ),
                                                        child: Container(
                                                          height: 65,
                                                          width: 65,
                                                          child: Image.asset(
                                                              placeholderImage,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                      "You are matched with"
                                                              .tr() +
                                                          " ${data.docs[0]['name'] ?? "__"}"
                                                              .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 14))),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: <Widget>[
                                                        notificationProvider
                                                                    .matchesDoc ==
                                                                null
                                                            ? SizedBox.shrink()
                                                            : !notificationProvider
                                                                        .matchesDoc[
                                                                    'isRead']
                                                                ? Container(
                                                                    width: 50.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          mRed,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      "NEW"
                                                                          .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12.0,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Text(""),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Text(
                                                      Utils().convertToAgoAndDate(
                                                          notificationProvider
                                                                      .matchesNotificationList[
                                                                  index]
                                                              ["createdAt"]),
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ],
                                              )
                                            ],
                                          ),
                                        )

                                        //  : Container()
                                        ),
                                  ),
                                );
                              });
                        }
                      })
                  : SizedBox.shrink();
            }
          });
    });
  }

  commentNotificationWidgetBuilder() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView.builder(
        shrinkWrap: true,
        itemCount: notificationProvider.commentsNotificationList.length,
        itemBuilder: (context, index) {
          return StreamBuilder(
              stream: notificationProvider.firebaseController.userColReference
                  .where("uid",
                      isEqualTo: notificationProvider
                          .commentsNotificationList[index]["commentBy"])
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: SizedBox.shrink(),
                  );
                QuerySnapshot data = snapshot.data;

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyPollScreen()));
                    notificationProvider.checkedNotification(
                        notificationProvider.commentsNotificationList[index]
                            ["type"],
                        index,
                        notificationProvider.commentsNotificationList[index]
                            ['postId'],
                        notificationProvider.commentsNotificationList[index]
                            ['_id']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blueGrey,
                                offset: Offset(2, 2),
                                spreadRadius: 2,
                                blurRadius: 3),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: themeProvider.isDarkMode ? dRed : white,
                        ),
                        // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: themeProvider.isDarkMode
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .commentsNotificationList[index]
                                          ['is_read']
                                      ? Colors.black
                                      : Colors.grey.withOpacity(.5))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .commentsNotificationList[index]
                                          ['is_read']
                                      ? Colors.white
                                      : Colors.grey.withOpacity(.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: lRed,
                                child: data.docs[0]['profilepic'] != null &&
                                        data.docs[0]['profilepic'].isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          25,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: data.docs[0]['profilepic'],
                                          fit: BoxFit.cover,
                                          useOldImageOnUrlChange: true,
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(
                                            radius: 20,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          25,
                                        ),
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          child: Image.asset(placeholderImage,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    "${data.docs[0]['name']} " +
                                        "commented on your post.".tr(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              Text(
                                  Utils().convertToAgoAndDate(
                                      notificationProvider
                                                  .commentsNotificationList[
                                              index]["createdAt"] *
                                          1000),
                                  style: TextStyle(fontSize: 12))
                            ],
                          ),
                        )

                        //  : Container()
                        ),
                  ),
                );
              });
        });
  }

  planRequestNotificationWidgetBuilder() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: notificationProvider.planRequestNotificationList.length,
          itemBuilder: (context, index) {
            return StreamBuilder(
                stream: notificationProvider.firebaseController.userColReference
                    .where("uid",
                        isEqualTo: notificationProvider
                                .planRequestNotificationList[index]
                            ["requestSendBy"])
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: SizedBox.shrink(),
                    );
                  QuerySnapshot data = snapshot.data;

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      navigateToPlanRequestScreenInfo(
                              notificationProvider
                                      .planRequestNotificationList[index]
                                  ['requestSendBy'],
                              notificationProvider.planRequestNotificationList[
                                      index] //pdataOwnerID
                                  ['pdataOwnerID'],
                              context,
                              notificationProvider
                                  .planRequestNotificationList[index]['planId'])
                          .whenComplete(() {
                        notificationProvider.checkedNotification(
                            notificationProvider
                                .planRequestNotificationList[index]["type"],
                            index,
                            notificationProvider
                                .planRequestNotificationList[index]['planId'],
                            notificationProvider
                                .planRequestNotificationList[index]['planId'],
                            requestBy: notificationProvider
                                    .planRequestNotificationList[index]
                                ['requestSendBy']);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blueGrey,
                                offset: Offset(2, 2),
                                spreadRadius: 2,
                                blurRadius: 3),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: themeProvider.isDarkMode ? dRed : white,
                        ),
                        // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: themeProvider.isDarkMode
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .planRequestNotificationList[
                                          index]['is_read']
                                      ? Colors.black
                                      : Colors.grey.withOpacity(.5))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .planRequestNotificationList[
                                          index]['is_read']
                                      ? Colors.white
                                      : Colors.grey.withOpacity(.5)),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(5),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: lRed,
                              child: data.docs[0]['profilepic'] != null &&
                                      data.docs[0]['profilepic'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        25,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: data.docs[0]['profilepic'],
                                        fit: BoxFit.cover,
                                        useOldImageOnUrlChange: true,
                                        placeholder: (context, url) =>
                                            CupertinoActivityIndicator(
                                          radius: 20,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        25,
                                      ),
                                      child: Container(
                                        height: 65,
                                        width: 65,
                                        child: Image.asset(placeholderImage,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                            ),
                            title: Text(
                                "${data.docs[0]['name']} ".toUpperCase() +
                                    " is interested in".tr() +
                                    " ${notificationProvider.planRequestNotificationList[index]["pName"]} "
                                        .toUpperCase(),
                                style: TextStyle(fontSize: 15)),
                            subtitle: Text("Only you can start the CHAT.".tr(),
                                style: TextStyle(fontSize: 12)),
                            trailing: Text(
                                Utils().convertToAgoAndDate(notificationProvider
                                            .planRequestNotificationList[index]
                                        ["createdAt"] *
                                    1000),
                                style: TextStyle(fontSize: 12)),
                          ),
                          //Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     CircleAvatar(
                          //       radius: 25,
                          //       backgroundColor: lRed,
                          //       child: data.docs[0]['profilepic'] != null &&
                          //               data.docs[0]['profilepic'].isNotEmpty
                          //           ? ClipRRect(
                          //               borderRadius: BorderRadius.circular(
                          //                 25,
                          //               ),
                          //               child: CachedNetworkImage(
                          //                 imageUrl: data.docs[0]['profilepic'],
                          //                 fit: BoxFit.cover,
                          //                 useOldImageOnUrlChange: true,
                          //                 placeholder: (context, url) =>
                          //                     CupertinoActivityIndicator(
                          //                   radius: 20,
                          //                 ),
                          //                 errorWidget: (context, url, error) =>
                          //                     Icon(
                          //                   Icons.error,
                          //                   color: Colors.black,
                          //                 ),
                          //               ),
                          //             )
                          //           : ClipRRect(
                          //               borderRadius: BorderRadius.circular(
                          //                 25,
                          //               ),
                          //               child: Container(
                          //                 height: 65,
                          //                 width: 65,
                          //                 child: Image.asset(placeholderImage,
                          //                     fit: BoxFit.cover),
                          //               ),
                          //             ),
                          //     ),
                          //     Expanded(
                          //       child: Container(
                          //         padding:
                          //             EdgeInsets.symmetric(horizontal: 5.0),
                          //         child: Text(
                          //           "${data.docs[0]['name']} " +
                          //               "sent you a request".tr(),
                          //           style: TextStyle(fontSize: 14),
                          //         ),
                          //       ),
                          //     ),
                          //     Text(
                          //         Utils().convertToAgoAndDate(
                          //             notificationProvider
                          //                         .planRequestNotificationList[
                          //                     index]["createdAt"] *
                          //                 1000),
                          //         style: TextStyle(fontSize: 12))
                          //   ],
                          // ),
                        ),
                        //  : Container()
                      ),
                    ),
                  );
                });
          });
    });
  }

  matchesNotificationWidgetBuilder(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: notificationProvider.matchesNotificationList.length,
          itemBuilder: (context, index) {
            if (notificationProvider.matchesNotificationList[index]
                    ["currentUser"] !=
                notificationProvider.currentUser.uid) {
              return StreamBuilder(
                  stream: notificationProvider
                      .firebaseController.userColReference
                      .where("uid",
                          isEqualTo: notificationProvider
                              .matchesNotificationList[index]["currentUser"])
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: SizedBox.shrink(),
                      );

                    QuerySnapshot data = snapshot.data;
                    notificationProvider.getAnotherData(index);

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        navigateToNextScreen(
                            notificationProvider.matchesAnotherDoc["matches"],
                            notificationProvider
                                .matchesAnotherDoc["currentUser"],
                            context,
                            notificationProvider.matchesAnotherDoc,
                            notificationProvider.matchesNotificationList[index]
                                ['_id']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.blueGrey,
                                    offset: Offset(2, 2),
                                    spreadRadius: 2,
                                    blurRadius: 3),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: (themeProvider.isDarkMode ? dRed : white),
                            ),
                            // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: themeProvider.isDarkMode
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: notificationProvider
                                                  .matchesNotificationList[
                                              index]['is_read']
                                          ? Colors.black
                                          : Colors.grey.withOpacity(.5))
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: notificationProvider
                                                  .matchesNotificationList[
                                              index]['is_read']
                                          ? Colors.white
                                          : Colors.grey.withOpacity(.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: lRed,
                                    child: data.docs[0]['profilepic'] != null &&
                                            data.docs[0]['profilepic']
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: data.docs[0]
                                                  ['profilepic'],
                                              fit: BoxFit.cover,
                                              useOldImageOnUrlChange: true,
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(
                                                radius: 20,
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            child: Container(
                                              height: 65,
                                              width: 65,
                                              child: Image.asset(
                                                  placeholderImage,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                        "You are matched with".tr() +
                                            " ${data.docs[0]['name'] ?? "__"}."
                                                .toUpperCase(),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            notificationProvider
                                                        .matchesAnotherDoc ==
                                                    null
                                                ? SizedBox.shrink()
                                                : !notificationProvider
                                                            .matchesAnotherDoc[
                                                        'isRead']
                                                    ? Container(
                                                        width: 50.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: mRed,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "NEW".tr(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    : Text(""),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                          Utils().convertToAgoAndDate(
                                              notificationProvider
                                                          .matchesNotificationList[
                                                      index]["createdAt"] *
                                                  1000),
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            )

                            //  : Container()
                            ),
                      ),
                    );
                  });
            } else {
              return StreamBuilder(
                  stream: notificationProvider
                      .firebaseController.userColReference
                      .where("uid",
                          isEqualTo: notificationProvider
                              .matchesNotificationList[index]["matches"])
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: SizedBox.shrink(),
                      );
                    QuerySnapshot data = snapshot.data;
                    notificationProvider.getData(
                        notificationProvider.matchesNotificationList[index]
                            ["currentUser"],
                        notificationProvider.matchesNotificationList[index]
                            ["matches"]);
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        navigateToNextScreen(
                            notificationProvider.matchesDoc["matches"],
                            notificationProvider.matchesDoc["currentUser"],
                            context,
                            notificationProvider.matchesDoc,
                            notificationProvider.matchesNotificationList[index]
                                ['_id']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.blueGrey,
                                    offset: Offset(2, 2),
                                    spreadRadius: 2,
                                    blurRadius: 3),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: themeProvider.isDarkMode ? dRed : white,
                            ),
                            // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: themeProvider.isDarkMode
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: notificationProvider
                                                  .matchesNotificationList[
                                              index]['is_read']
                                          ? Colors.black
                                          : Colors.grey.withOpacity(.5))
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: notificationProvider
                                                  .matchesNotificationList[
                                              index]['is_read']
                                          ? Colors.white
                                          : Colors.grey.withOpacity(.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: lRed,
                                    child: data.docs[0]['profilepic'] != null &&
                                            data.docs[0]['profilepic']
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: data.docs[0]
                                                  ['profilepic'],
                                              fit: BoxFit.cover,
                                              useOldImageOnUrlChange: true,
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(
                                                radius: 20,
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            child: Container(
                                              height: 65,
                                              width: 65,
                                              child: Image.asset(
                                                  placeholderImage,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                      child: Text(
                                          "You are matched with".tr() +
                                              " ${data.docs[0]['name'] ?? "__"}"
                                                  .toUpperCase(),
                                          style: TextStyle(fontSize: 14))),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            notificationProvider.matchesDoc ==
                                                    null
                                                ? SizedBox.shrink()
                                                : !notificationProvider
                                                        .matchesDoc['isRead']
                                                    ? Container(
                                                        width: 50.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: mRed,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "NEW".tr(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    : Text(""),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                          Utils().convertToAgoAndDate(
                                              notificationProvider
                                                      .matchesNotificationList[
                                                  index]["createdAt"]),
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            )

                            //  : Container()
                            ),
                      ),
                    );
                  });
            }
          });
    });
  }

//todo make changes as per old project
  litpieNotificationWidgetBuilder() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView.builder(
        shrinkWrap: true,
        itemCount: notificationProvider.litpieNotificationList.length,
        itemBuilder: (context, index) {
          return StreamBuilder(
              stream: notificationProvider.firebaseController.userColReference
                  .where("uid",
                      isEqualTo: notificationProvider
                          .litpieNotificationList[index]["litPieBy"])
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: SizedBox.shrink(),
                  );
                QuerySnapshot data = snapshot.data;

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    navigateToLitPieScreen(
                        notificationProvider.litpieNotificationList[index]
                            ['litPieTo'],
                        notificationProvider.litpieNotificationList[index]
                            ['litPieBy'],
                        context,
                        notificationProvider.litpieNotificationList[index]
                            ['_id']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blueGrey,
                                offset: Offset(2, 2),
                                spreadRadius: 2,
                                blurRadius: 3),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: themeProvider.isDarkMode ? dRed : white,
                        ),
                        // color: !doc.data()['isRead'] ? mRed.withOpacity(.15) : lRed.withOpacity(.15)),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: themeProvider.isDarkMode
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .litpieNotificationList[index]
                                          ['is_read']
                                      ? Colors.black
                                      : Colors.grey.withOpacity(.5))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: notificationProvider
                                              .litpieNotificationList[index]
                                          ['is_read']
                                      ? Colors.white
                                      : Colors.grey.withOpacity(.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: lRed,
                                child: data.docs[0]['profilepic'] != null &&
                                        data.docs[0]['profilepic'].isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          25,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: data.docs[0]['profilepic'],
                                          fit: BoxFit.cover,
                                          useOldImageOnUrlChange: true,
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(
                                            radius: 20,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          25,
                                        ),
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          child: Image.asset(placeholderImage,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    "${data.docs[0]['name']} sent you a litpie.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              Text(
                                  Utils().convertToAgoAndDate(
                                      notificationProvider
                                                  .litpieNotificationList[index]
                                              ['createdAt'] *
                                          1000),
                                  style: TextStyle(fontSize: 12))
                            ],
                          ),
                        )),
                  ),
                );
              });
        });
  }

  Future<void> navigateToNextScreen(String matchedUser, String currentUser,
      BuildContext context, matchesAnotherDoc, String notificationID) async {
    CreateAccountData _matchedUserData;
    CreateAccountData _currentUserUserData;
    var matchedUserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(matchedUser)
        .get();
    var currentUserUserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get();

    if (matchedUserData != null) {
      _matchedUserData = CreateAccountData.fromDocument(matchedUserData.data());
    }
    if (currentUserUserData != null) {
      _currentUserUserData =
          CreateAccountData.fromDocument(currentUserUserData.data());
    }

    if (_matchedUserData != null && _currentUserUserData != null) {
      _matchedUserData.distanceBW = Constants()
          .calculateDistance(
              currentUser: _currentUserUserData, anotherUser: _matchedUserData)
          .round();

      showDialog(
          context: context,
          builder: (thisContext) {
            notificationProvider.dialogContext = thisContext;
            return Info(
              _matchedUserData,
              _currentUserUserData,
            );
          }).whenComplete(() async {
        await notificationProvider.notRefrenece
            .doc(notificationID)
            .update({"is_read": true}).then((value) {
          print("test");
        }).whenComplete(() async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser)
              .collection("Matches")
              .doc(matchedUser)
              .update({"isRead": true});
          notificationProvider.checkedNotification(
              "Matches", 0, "", notificationID);
        }).catchError((e) {
          print(e.toString());

          setState(() {});
        });
      });
    }
  }

  Future<void> navigateToPlanRequestScreenInfo(String otherUserData,
      String currentUser, BuildContext context, String notificationId) async {
    CreateAccountData _matchedUserData;
    CreateAccountData _currentUserUserData;
    var otherUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserData)
        .get();
    var currentUserUserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get();

    if (otherUser != null) {
      _matchedUserData = CreateAccountData.fromDocument(otherUser.data());
    }
    if (currentUserUserData != null) {
      _currentUserUserData =
          CreateAccountData.fromDocument(currentUserUserData.data());
    }

    if (_matchedUserData != null && _currentUserUserData != null) {
      _matchedUserData.distanceBW = Constants()
          .calculateDistance(
              currentUser: _currentUserUserData, anotherUser: _matchedUserData)
          .round();

      showDialog(
          context: context,
          builder: (thisContext) {
            notificationProvider.dialogContext = thisContext;
            return Info(
              _matchedUserData,
              _currentUserUserData,
            );
          }).whenComplete(() async {
        var ref = await notificationProvider.notRefrenece
            .where("type", isEqualTo: 'Plan Request')
            .where('planId', isEqualTo: notificationId)
            .get();
        if (ref.docs.isNotEmpty) {
          ref.docs[0].reference.update({"is_read": true}).then((value) {
            print("plan read successfully");
          }).whenComplete(() {});
        }
      });
    }
  }

  navigateToLitPieScreen(String otherUserData, String currentUser,
      BuildContext context, String notificationId) async {
    CreateAccountData _matchedUserData;
    CreateAccountData _currentUserUserData;
    var otherUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserData)
        .get();
    var currentUserUserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get();

    if (otherUser != null) {
      _matchedUserData = CreateAccountData.fromDocument(otherUser.data());
    }
    if (currentUserUserData != null) {
      _currentUserUserData =
          CreateAccountData.fromDocument(currentUserUserData.data());
    }

    if (_matchedUserData != null && _currentUserUserData != null) {
      _matchedUserData.distanceBW = Constants()
          .calculateDistance(
              currentUser: _currentUserUserData, anotherUser: _matchedUserData)
          .round();

      showDialog(
          context: context,
          builder: (thisContext) {
            notificationProvider.dialogContext = thisContext;
            return Info(
              _currentUserUserData,
              _matchedUserData,
            );
          }).whenComplete(() async {
        var ref = await notificationProvider.notRefrenece
            .where("type", isEqualTo: 'LitPie')
            .where('_id', isEqualTo: notificationId)
            .get();
        if (ref.docs.isNotEmpty) {
          ref.docs[0].reference.update({"is_read": true}).then((value) {
            print("Lit pie read successfully");
          }).whenComplete(() {
            notificationProvider.checkedNotification(
                "LitPie", 0, "", notificationId);
          });
        }
      });
    }
  }

  getUnreadCountString(String value) {
    switch (value) {
      case "All":
        return notificationProvider.allUnreadCount.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    color: mRed,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    )),
                child: Text(
                  notificationProvider.allUnreadCount.length.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ))
            : SizedBox.shrink();
      case "LitPie":
        return notificationProvider.litpieUnreadCount.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    color: mRed,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    )),
                child: Text(
                    notificationProvider.litpieUnreadCount.length.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.0)))
            : SizedBox.shrink();
      case "Matches":
        return notificationProvider.matchesUnreadCount.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    color: mRed,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    )),
                child: Text(
                    notificationProvider.matchesUnreadCount.length.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.0)))
            : SizedBox.shrink();
      case "Post":
        return notificationProvider.postUnreadCount.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    color: mRed,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    )),
                child: Text(
                    notificationProvider.postUnreadCount.length.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.0)))
            : SizedBox.shrink();
      default:
        return notificationProvider.planRequestUnreadCount.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    color: mRed,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    )),
                child: Text(
                    notificationProvider.planRequestUnreadCount.length
                        .toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12.0)))
            : SizedBox.shrink();
    }
  }
}
