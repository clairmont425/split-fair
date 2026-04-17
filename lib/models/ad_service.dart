import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  static String get bannerAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-1238536439375279/3739766193';
    }
    return 'ca-app-pub-1238536439375279/1085894726';
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static BannerAd createBanner({required void Function(Ad, LoadAdError) onFailed}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: onFailed,
      ),
    );
  }
}
