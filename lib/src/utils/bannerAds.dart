import 'package:google_mobile_ads/google_mobile_ads.dart';
class BannerAds {
  Future<InitializationStatus> initialization;
  BannerAds(this.initialization);

  String get bannerAdUnit1 => 'ca-app-pub-3940256099942544/6300978111';
  String get bannerAdUnit2 => 'ca-app-pub-3940256099942544/6300978111';
  String get bannerAdUnit3 => 'ca-app-pub-3940256099942544/6300978111';
  String get bannerAdUnit4 => 'ca-app-pub-3940256099942544/6300978111';
  String get bannerAdUnit5 => 'ca-app-pub-3940256099942544/6300978111';


// Real Ad units ----------
  //   String get bannerAdUnit1 => 'ca-app-pub-1317304154938617/5915945236';
  // String get bannerAdUnit2 => 'ca-app-pub-1317304154938617/6323139344';
  // String get bannerAdUnit3 => 'ca-app-pub-1317304154938617/4818485987';
  // String get bannerAdUnit4 => 'ca-app-pub-1317304154938617/6109023834';
  // String get bannerAdUnit5 => 'ca-app-pub-1317304154938617/2169778821';




  BannerAdListener get adListener => _adListener;
  BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load: $error');
    },
    onAdOpened: (Ad ad) => print('Ad opened.'),
    onAdClosed: (Ad ad) => print('Ad closed.'),
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );
}