import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/provider/global_posts/model/textPostModel.dart';
import 'package:litpie/widgets/PollWidget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../variables.dart';

class MyTextPostWidget extends StatefulWidget {
  const MyTextPostWidget({
    Key key,
    @required this.currentUserId,
    this.otherUser,
    this.pollType,
    @required this.textpostRef,
    this.deletePollPressed,
    this.onVotePressed,
    this.textPostModel,
  }) : super(key: key);

  @override
  _MyTextPostWidgetState createState() => _MyTextPostWidgetState();
  final CreateAccountData otherUser;
  final TextPostModel textPostModel;
  final String currentUserId;
  final PollsType pollType;
  final CollectionReference textpostRef;
  final VoidCallback deletePollPressed;
  final Function(int) onVotePressed;
}

class _MyTextPostWidgetState extends State<MyTextPostWidget> {
  String creator;
  int createdAt;
  FirebaseController _firebaseController = FirebaseController();
  CreateAccountData currentUser;

  Future<CreateAccountData> getUser() async {
    currentUser = await _firebaseController.currentUserData;
    return currentUser;
  }

  @override
  void initState() {
    creator = widget.textPostModel.createdBy;
    createdAt = widget.textPostModel.createdAt;
    getUser().then((cUser) async {
      currentUser = cUser;
      if (mounted) setState(() {});
    });

    super.initState();
  }

  void reportPost() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => ReportUser(
              currentUserUID: widget.currentUserId,
              secondUserUID: widget.textPostModel.createdBy,
              typeOfReport: TypeOfReport.post,
              mediaID: widget.textPostModel.postId,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return widget.textPostModel.type == 'post'
        ? Card(
            elevation: 2.0,
            color: themeProvider.isDarkMode ? Colors.black : null,
            shadowColor: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                children: [
                  widget.textPostModel.anonymously == true
                      ? Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 9,
                                  child: widget.textPostModel.textPost != null
                                      ? Text(
                                          widget.textPostModel.textPost,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        )
                                      : Container(),
                                ),
                                widget.textPostModel.createdBy !=
                                        FirebaseAuth.instance.currentUser.uid
                                    ? Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            reportPost();
                                          },
                                          child: Container(
                                            child: Icon(
                                              CupertinoIcons.flag,
                                              size: 26.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Flexible(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            child: Icon(
                                              CupertinoIcons.delete,
                                              size: 26.0,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        )
                      : currentUser != null
                          ? Column(
                              children: [
                                widget.textPostModel.createdBy ==
                                        currentUser.uid
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          currentUser.profilepic.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    80,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    height: 45,
                                                    width: 45,
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        currentUser.profilepic,
                                                    useOldImageOnUrlChange:
                                                        true,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(
                                                      radius: 1,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.error,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 1,
                                                        ),
                                                        Text(
                                                          "Error".tr(),
                                                          style: TextStyle(
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    80,
                                                  ),
                                                  child: Container(
                                                    height: 45,
                                                    width: 45,
                                                    child: Image.asset(
                                                        placeholderImage,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text(currentUser.name)),
                                        ],
                                      )
                                    : Text(""),
                                Stack(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 9,
                                          child: widget
                                                      .textPostModel.textPost !=
                                                  null
                                              ? Text(
                                                  widget.textPostModel.textPost,
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        widget.textPostModel.createdBy !=
                                                FirebaseAuth
                                                    .instance.currentUser.uid
                                            ? Flexible(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    reportPost();
                                                  },
                                                  child: Container(
                                                    child: Icon(
                                                      CupertinoIcons.flag,
                                                      size: 26.0,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Flexible(
                                                child: GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    child: Icon(
                                                      CupertinoIcons.delete,
                                                      size: 26.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.heart),
                        SizedBox(
                          width: 5,
                        ),
                        Text('data'),
                        SizedBox(
                          width: 60,
                        ),
                        Icon(CupertinoIcons.chat_bubble_text),
                        SizedBox(
                          width: 5,
                        ),
                        Text('data'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
