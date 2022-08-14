import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/controller/blockController.dart';
import 'package:litpie/controller/unfriendController.dart';
import 'package:litpie/models/blockedUserModel.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/widgets/LinearProgressBar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class MoreOptionDialog extends StatefulWidget {
  final CreateAccountData currentUser;
  final CreateAccountData anotherUser;
  final bool isUnfriend;

  const MoreOptionDialog(
      {Key key,
      @required this.currentUser,
      @required this.anotherUser,
      this.isUnfriend = false})
      : super(key: key);

  @override
  _MoreOptionDialogState createState() => _MoreOptionDialogState();
}

class _MoreOptionDialogState extends State<MoreOptionDialog> {
  BlockedUserModel isBlockedModel;
  BlockUserController blockUserController = BlockUserController();
  bool isBlockedModelFetched = false;

  @override
  void initState() {
    kInit();
    super.initState();
  }

  kInit() async {
    isBlockedModel = await blockUserController.blockedExistOrNot(
        currentUserId: widget.currentUser.uid,
        anotherUserId: widget.anotherUser.uid);
    setState(() {
      isBlockedModelFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return AlertDialog(
      backgroundColor: themeProvider.isDarkMode
          ? black.withOpacity(.5)
          : white.withOpacity(.5),
      content: Container(
        child: Stack(
          children: [
            if (isBlockedModelFetched)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "What would you like to do?".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),

                  /// if(widget.isUnfriend)
                  SizedBox(height: 20.0),
                  if (widget.isUnfriend)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 30, right: 30),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          UnFriendController()
                              .unFriendUser(
                                  currentUserId: widget.currentUser.uid,
                                  anotherUserId: widget.anotherUser.uid)
                              .catchError((e) {})
                              .then((value) {
                            Navigator.of(context).pop("unfriend");
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Text(
                            "Unfriend".tr(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: mRed,
                          onPrimary: white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.7)),
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
                      onPressed: isBlockedModel == null
                          ? () async {
                              await blockUserController
                                  .blockUser(
                                      currentUserId: widget.currentUser.uid,
                                      anotherUserId: widget.anotherUser.uid)
                                  .then((value) {
                                Navigator.of(context).pop("block");
                              });
                            }
                          : isBlockedModel.blockedBy == widget.currentUser.uid
                              ? () async {
                                  //unblock
                                  await blockUserController
                                      .unblockUser(
                                          currentUserId: widget.currentUser.uid,
                                          anotherUserId: widget.anotherUser.uid)
                                      .then((value) {
                                    Navigator.of(context).pop("block");
                                  });
                                }
                              : null,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          isBlockedModel == null
                              ? "Block".tr()
                              : isBlockedModel.blockedBy ==
                                      widget.currentUser.uid
                                  ? "Unblock".tr()
                                  : "Blocked".tr(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
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
                      onPressed: () async {
                        try {
                          await showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => ReportUser(
                                    currentUserUID: widget.currentUser.uid,
                                    secondUserUID: widget.anotherUser.uid,
                                    typeOfReport: TypeOfReport.profile,
                                  ));
                        } catch (e) {
                          print(e);
                        }

                        Navigator.of(context).pop("report");
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          "Report".tr(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
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
                        Navigator.of(context).pop("");
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          "Cancel".tr(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: themeProvider.isDarkMode ? mBlack : white,
                        onPrimary: Colors.blue[700],
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.7)),
                      ),
                    ),
                  ),
                ],
              ),
            if (!isBlockedModelFetched)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Center(
                      child: LinearProgressCustomBar(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
