import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:litpie/variables.dart';

class MobileAdsController {
  //Interstitial
  // static InterstitialAd interstitialAd;
  InterstitialAd interstitialAd;

  // RewardedAd rewardedAd;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? testAdInterstitial : testAdInterstitial;

  static String get bannerAdUnitId =>
      Platform.isAndroid ? testAdBanner : testAdBanner;

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this.interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  BannerAd loadBannerAd() {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print("ad Loaded");
        },
        onAdFailedToLoad: (ad, err) {
          print("Ad Failed to Load: $err");
        },
        onAdOpened: (ad) {
          print("Ad Opened");
        },
        onAdClosed: (ad) {
          ad.dispose();
        },
      ),
    );
  }

  BannerAd loadMediumBannerAd() {
    return BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: bannerAdUnitId,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print("ad Loaded");
        },
        onAdFailedToLoad: (ad, err) {
          print("Ad Failed to Load: $err");
        },
        onAdOpened: (ad) {
          print("Ad Opened");
        },
        onAdClosed: (ad) {
          ad.dispose();
        },
      ),
    );
  }
}
