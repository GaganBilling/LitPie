import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/models/createAccountData.dart';
import 'package:litpie/variables.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:litpie/Screens/reportUser.dart';
import 'package:litpie/Theme/colors.dart';
import 'package:litpie/Theme/theme_provider.dart';
import 'package:litpie/provider/global_posts/model/pollDataModel.dart';
import 'package:litpie/widgets/PollWidget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../common/Utils.dart';

class MyPollWidget extends StatefulWidget {
  const MyPollWidget(
      {Key key,
      @required this.pollDataModel,
      @required this.currentUserId,
      this.pollType,
      this.otherUser,
      @required this.pollRef,
      this.deletePollPressed,
      this.onVotePressed,
      this.isAnonymous})
      : super(key: key);

  @override
  _MyPollWidgetState createState() => _MyPollWidgetState();
  final CreateAccountData otherUser;
  final PollDataModel pollDataModel;
  final String currentUserId;
  final PollsType pollType;
  final CollectionReference pollRef;
  final VoidCallback deletePollPressed;
  final Function(int) onVotePressed;
  final bool isAnonymous;
}

class _MyPollWidgetState extends State<MyPollWidget> {
  String creator;
  double durationPercentage;
  bool isAlreadyVoted = false;
  int option = 0;

  int createdAt;

  double getDurationPercentage(Timestamp startDate, Timestamp endDate) {
    DateTime start = startDate.toDate();
    DateTime end = endDate.toDate();
    int totalDiff = end.difference(start).inSeconds;
    int currentDiff = DateTime.now().difference(end).inSeconds.abs();
    double percentage = 1.0 - (currentDiff / totalDiff);
    print(percentage);
    if (end.difference(DateTime.now()).inSeconds <= 0) {
      return 1.0;
    }
    return percentage;
  }

  FirebaseController _firebaseController = FirebaseController();
  CreateAccountData currentUser;

  Future<CreateAccountData> getUser() async {
    try {
      currentUser = await _firebaseController.currentUserData;
    } catch (e) {
      print(e.toString());
    }
    return currentUser;
  }

  @override
  void initState() {
    creator =
        widget.pollDataModel.pollQuestion.createdBy; //poll creator user-id
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkWhetherAlreadyVoted();
    });

    try {
      durationPercentage = getDurationPercentage(
          widget.pollDataModel.pollQuestion.createdAt,
          widget.pollDataModel.pollQuestion.duration);
    } catch (e) {
      print(e.toString());
    }

    creator = widget.pollDataModel.createdBy;
    createdAt = widget.pollDataModel.createdAt;
    try {
      getUser().then((cUser) async {
        currentUser = cUser;
        if (mounted) setState(() {});
      });
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  void deleteMyPoll(
      {@required ThemeProvider themeProvider, PollDataModel pollModel}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: themeProvider.isDarkMode
                  ? black.withOpacity(.5)
                  : white.withOpacity(.5),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Are You Sure?".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
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
                          widget.deletePollPressed();
                          Navigator.of(context).pop();
                        },
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              "Delete".tr(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            )),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              "Cancel".tr(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            )),
                        style: ElevatedButton.styleFrom(
                          primary: themeProvider.isDarkMode ? mBlack : white,
                          onPrimary: Colors.blue[700],
                          // padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 10.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.7)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void reportPoll() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => ReportUser(
              currentUserUID: widget.currentUserId,
              secondUserUID: widget.pollDataModel.pollQuestion.createdBy,
              typeOfReport: TypeOfReport.poll,
              mediaID: widget.pollDataModel.pollId,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return widget.pollType == PollsType.creator ||
            widget.pollType == PollsType.readOnly
        ? Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blueGrey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4.0,
            shadowColor: getDurationPercentage(
                        widget.pollDataModel.pollQuestion.createdAt,
                        widget.pollDataModel.pollQuestion.duration) ==
                    1.0
                ? themeProvider.isDarkMode
                    ? Colors.white38
                    : null
                : themeProvider.isDarkMode
                    ? Colors.white
                    : null,
            color: getDurationPercentage(
                        widget.pollDataModel.pollQuestion.createdAt,
                        widget.pollDataModel.pollQuestion.duration) ==
                    1.0
                ? themeProvider.isDarkMode
                    ? Colors.grey[850]
                    : Colors.grey[300]
                : themeProvider.isDarkMode
                    ? Colors.black
                    : null,
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.isAnonymous != null && widget.isAnonymous
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    80,
                                  ),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    child: Image.asset(placeholderImage,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Text("Unknown".tr(),
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      Utils().convertToAgoAndDate(
                                          widget.pollDataModel.createdAt),
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      PollWidget.creator(
                        children: widget.pollDataModel.pollOption
                            .map((option) => PollWidget.options(
                                title: option.option,
                                value: option.voteCount.toDouble()))
                            .toList(),
                        question: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 9,
                              child: Text(
                                widget.pollDataModel.pollQuestion.question,
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            widget.pollDataModel.createdBy ==
                                    widget.currentUserId
                                ? Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        deleteMyPoll(
                                            themeProvider: themeProvider);
                                      },
                                      child: Container(
                                        child: Icon(
                                          CupertinoIcons.delete,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                        onVoteBackgroundColor: mRed,
                        leadingBackgroundColor: mRed,
                        backgroundColor: Colors.white,
                        leadingPollStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        pollStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      LinearPercentIndicator(
                        key: new UniqueKey(),
                        backgroundColor: Colors.blueGrey,
                        progressColor: getDurationPercentage(
                                    widget.pollDataModel.pollQuestion.createdAt,
                                    widget
                                        .pollDataModel.pollQuestion.duration) <=
                                0.90
                            ? Colors.green
                            : Colors.red,
                        lineHeight: 8.0,
                        percent: getDurationPercentage(
                            widget.pollDataModel.pollQuestion.createdAt,
                            widget.pollDataModel.pollQuestion.duration),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              getDurationPercentage(
                                          widget.pollDataModel.pollQuestion
                                              .createdAt,
                                          widget.pollDataModel.pollQuestion
                                              .duration) ==
                                      1.0
                                  ? "Poll Ended".tr()
                                  : "Poll Ends".tr(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blueGrey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2.0,
            color: themeProvider.isDarkMode ? Colors.black : null,
            shadowColor: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isAnonymous != null && widget.isAnonymous
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    80,
                                  ),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    child: Image.asset(placeholderImage,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Text("Unknown".tr(),
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      Utils().convertToAgoAndDate(
                                          widget.pollDataModel.createdAt),
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  reportPoll();
                                },
                                child: Container(
                                  child: Icon(
                                    CupertinoIcons.flag,
                                    size: 26.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : SizedBox.shrink(),
                  Stack(
                    children: [
                      PollWidget(
                        children: widget.pollDataModel.pollOption
                            .map((option) => PollWidget.options(
                                title: option.option,
                                value: option.voteCount.toDouble()))
                            .toList(),
                        question: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 9,
                              child: Text(
                                widget.pollDataModel.pollQuestion.question,
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        currentUser: widget.currentUserId,
                        creatorID: this.creator,
                        voteData: widget.pollDataModel.userWhoVoted,
                        userChoice: widget.pollDataModel
                            .userWhoVoted[this.widget.currentUserId],
                        onVoteBackgroundColor: mRed,
                        leadingBackgroundColor: mRed,
                        backgroundColor:
                            themeProvider.isDarkMode ? mBlack : Colors.white,
                        outlineColor: themeProvider.isDarkMode
                            ? Colors.blueGrey
                            : Colors.blueGrey,
                        leadingPollStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        pollStyle: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : widget.pollDataModel.userWhoVoted
                                      .containsKey(this.widget.currentUserId)
                                  ? Colors.white
                                  : Colors.blueGrey,
                          fontSize: 18.0,
                        ),
                        viewType: (isAlreadyVoted || getDurationPercentage(
                            widget.pollDataModel.pollQuestion.createdAt,
                            widget
                                .pollDataModel.pollQuestion.duration) ==
                            1.0)
                            ? PollsType.readOnly
                            : PollsType.voter,
                        onVote: widget.onVotePressed,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  LinearPercentIndicator(
                    key: new UniqueKey(),
                    backgroundColor: Colors.blueGrey[200],
                    progressColor: getDurationPercentage(
                                widget.pollDataModel.pollQuestion.createdAt,
                                widget.pollDataModel.pollQuestion.duration) <=
                            0.90
                        ? Colors.green
                        : Colors.red,
                    lineHeight: 8.0,
                    percent: durationPercentage = getDurationPercentage(
                        widget.pollDataModel.pollQuestion.createdAt,
                        widget.pollDataModel.pollQuestion.duration),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(getDurationPercentage(
                                    widget.pollDataModel.pollQuestion.createdAt,
                                    widget
                                        .pollDataModel.pollQuestion.duration) ==
                                1.0
                            ? "Poll Ended".tr()
                            : "Poll Ends2".tr())
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future checkWhetherAlreadyVoted() async {
    var listOfVotedUsers = [];
    try {
      QuerySnapshot document = await FirebaseFirestore.instance
          .collection("Post")
          .doc(widget.pollDataModel.id)
          .collection("VotedBy")
          .get();
      if (document.docs.isEmpty) {
        print("docs are empty");
      } else {
        document.docs.forEach((element) {
          Map<String, dynamic> elementData = element.data();
          elementData['voteBy'] == widget.currentUserId;
          setState(() {
            isAlreadyVoted = true;
          });
          if (isAlreadyVoted) {
            option = elementData['answerOption'];
            setState(() {});
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
