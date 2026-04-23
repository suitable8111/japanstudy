import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // TODO: AdMob 콘솔에서 실제 광고 단위 ID로 교체하세요
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-9185470230877087/3335733677' // 실제 Android 배너 ID
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // 실제 iOS 배너 ID
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-9185470230877087/7424834102' // 실제 Android 전면 ID
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // 실제 iOS 전면 ID
  }

  InterstitialAd? _interstitialAd;
  bool _interstitialLoaded = false;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoaded = false;
          debugPrint('전면 광고 로드 실패: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }
}
