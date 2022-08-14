import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:litpie/controller/FirebaseController.dart';
import 'package:litpie/variables.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class RewardCollectController extends ChangeNotifier {
  int roseRec = 0;
  int roseColl = 0;
  DocumentSnapshot likeCountDoc;
  Timestamp roseTimestamp;
  DateTime serverDatetime;
  Duration adBtnTimerDuration;
  Duration freeBtnTimerDuration;
  FirebaseController _firebaseController = FirebaseController();
  int roseCollectByAdTimeInterval = 30;
  SharedPreferences pref;
  bool freeCollectBtnEnabled = false;
  bool adCollectBtnEnabled = false;

  Future<DateTime> get getServerDateTime async {
    return await NTP.now();
  }

  Timer watchAdCountdownTimer;
  Timer dailyCollectCountdownTimer;

  RewardedAd rewardedAd;

  RewardCollectController() {
    kInit();
  }

  kInit() async {
    pref = await SharedPreferences.getInstance();
    getRoseCount();
  }

  Future getRoseCount() async {
    serverDatetime = await getServerDateTime;
    // likeCountDoc = await _firebaseController.notificationColReference.doc(_firebaseController.firebaseAuth.currentUser.uid).collection('R').doc('count').get();
    likeCountDoc = await _firebaseController.userColReference
        .doc(_firebaseController.firebaseAuth.currentUser.uid)
        .collection("R")
        .doc('count')
        .get();

    if (likeCountDoc.data() != null) {
      roseTimestamp = likeCountDoc["Rosetimestamp"] ?? null;
      roseRec = likeCountDoc["roseRec"];
      roseColl = likeCountDoc["roseColl"];
      if (roseTimestamp != null) {
        freeBtnTimerDuration = Duration(
            seconds: DateTime.fromMillisecondsSinceEpoch(
                        roseTimestamp.millisecondsSinceEpoch)
                    .difference(serverDatetime)
                    .inSeconds +
                (Duration(hours: 24).inSeconds));
        if (Timestamp.fromDate(serverDatetime.subtract(Duration(hours: 24)))
                .millisecondsSinceEpoch >=
            roseTimestamp.millisecondsSinceEpoch) {
          freeCollectBtnEnabled = true;
        } else {
          //start timer
          if (dailyCollectCountdownTimer != null)
            dailyCollectCountdownTimer.cancel();
          startDailyCollectTimer();
        }
      } else {
        freeCollectBtnEnabled = true;
      }
    }

    int lastRewardEarnedTimestamp = pref.getInt("lastRewardEarnedTimestamp");
    if (lastRewardEarnedTimestamp == null) {
      pref.setInt(
          "lastRewardEarnedTimestamp",
          DateTime.now()
              .subtract(Duration(minutes: 30))
              .millisecondsSinceEpoch);
      lastRewardEarnedTimestamp =
          DateTime.now().subtract(Duration(minutes: 30)).millisecondsSinceEpoch;
    }
    adBtnTimerDuration = Duration(
        seconds: DateTime.fromMillisecondsSinceEpoch(lastRewardEarnedTimestamp)
                .difference(serverDatetime)
                .inSeconds +
            (roseCollectByAdTimeInterval * 60));
    print(roseCollectByAdTimeInterval);
    if (lastRewardEarnedTimestamp != null) {
      if (serverDatetime
              .subtract(Duration(minutes: roseCollectByAdTimeInterval))
              .millisecondsSinceEpoch >=
          lastRewardEarnedTimestamp) {
        this.loadRewardedAd();
      } else {
        if (watchAdCountdownTimer != null) watchAdCountdownTimer.cancel();
        startWatchAdTimer();
      }
    } else {
      adCollectBtnEnabled = true;
    }
    notifyListeners();
  }

  void deductTimeForTimer() {
    // timeForTimer--;
    adBtnTimerDuration = Duration(seconds: adBtnTimerDuration.inSeconds - 1);
    notifyListeners();
  }

  void updateRewardByFree() async {
    await _firebaseController.userColReference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .collection('R')
        .doc('count')
        .update({
      // await _firebaseController.rColReference.doc('count').update({
      "roseColl": FieldValue.increment(roseCollCollectionLimit),
      // "roseColl": userCountDoc.data()['roseColl'] + 13,
      "Rosetimestamp": DateTime.now()
    }).then((value) {
      freeCollectBtnEnabled = false;
      roseColl += roseCollCollectionLimit;
      getRoseCount();
      Fluttertoast.showToast(
          msg: "Collected!!".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((err) {
      print("Error At reward Collection: $err");
    });

    notifyListeners();
  }

  void collectRewardByAd() async {
    // MobileAdsController().showRewardedAd();
    this.showRewardedAd();
    if (adCollectBtnEnabled) {
      int currentTimestamp =
          await getServerDateTime.then((value) => value.millisecondsSinceEpoch);
      pref.setInt("lastRewardEarnedTimestamp", currentTimestamp);
    }
    adCollectBtnEnabled = !adCollectBtnEnabled;
    this.roseColl += roseCollCollectionLimitByAd;
    this.roseRec += 5;
    getRoseCount();
  }

  Future<void> onRewardEarned() async {
    await _firebaseController.userColReference
        .doc(_firebaseController.currentFirebaseUser.uid)
        .collection('R')
        .doc('count')
        .update({
      // await _firebaseController.rColReference.doc('count').update({
      "roseColl": FieldValue.increment(roseCollCollectionLimitByAd),
      "roseRec": FieldValue.increment(5),
      // "roseColl": userCountDoc.data()['roseColl'] + 1,
      // "roseRec": userCountDoc.data()['roseRec'] + 1,
    }).then((value) {
      //You Earned Reward Successfully!!

      notifyListeners();
    }).catchError((err) {
      print("Error At reward Collection: $err");
    });
  }

  //button enable hoga ad load hone ke baad

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: testAdRewarded,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("Rewarded Ad Loaded!");
          this.rewardedAd = ad;
          adCollectBtnEnabled = true;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          //Something Went Wrong, Try Again Toast
          print('RewardedAd failed to load: $err');
        },
      ),
    );
  }

  void showRewardedAd() async {
    this.rewardedAd.show(onUserEarnedReward: (ad, reward) {
      print("Reward Earned");
      this.onRewardEarned();
    }).then((value) {
      this.rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            print('$ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          this.rewardedAd = null;
          getRoseCount();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          this.rewardedAd = null;
          getRoseCount();
        },
        onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
      );
    });
  }

  void startWatchAdTimer() {
    final oneSec = const Duration(seconds: 1);
    watchAdCountdownTimer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (this.adBtnTimerDuration.inSeconds == 0) {
          // timeForTimer = 0;
          adBtnTimerDuration = Duration(seconds: 0);
          timer.cancel();
          this.loadRewardedAd();
          notifyListeners();
        } else {
          this.deductTimeForTimer();
        }
      },
    );
  }

  void startDailyCollectTimer() {
    final oneSec = const Duration(seconds: 1);
    dailyCollectCountdownTimer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (this.freeBtnTimerDuration.inSeconds == 0) {
          // timeForTimer = 0;
          freeBtnTimerDuration = Duration(seconds: 0);
          timer.cancel();
          notifyListeners();
        } else {
          freeBtnTimerDuration =
              Duration(seconds: freeBtnTimerDuration.inSeconds - 1);
          notifyListeners();
        }
      },
    );
  }
}
