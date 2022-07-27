import 'package:google_mobile_ads/google_mobile_ads.dart';
class BannerAds {
  Future<InitializationStatus> initialization;
  BannerAds(this.initialization);

  // Test Ad units ----------
  // String get bannerAdUnit1 => 'ca-app-pub-3940256099942544/6300978111';
  // String get bannerAdUnit2 => 'ca-app-pub-3940256099942544/6300978111';
  // String get bannerAdUnit3 => 'ca-app-pub-3940256099942544/6300978111';
  // String get bannerAdUnit4 => 'ca-app-pub-3940256099942544/6300978111';
  // String get bannerAdUnit5 => 'ca-app-pub-3940256099942544/6300978111';


//  Real Ad units ----------
  String get bannerAdUnit1 => 'ca-app-pub-1317304154938617/5349966152';
  String get bannerAdUnit2 => 'ca-app-pub-1317304154938617/1556677912';
  String get bannerAdUnit3 => 'ca-app-pub-1317304154938617/2723802815';
  String get bannerAdUnit4 => 'ca-app-pub-1317304154938617/6425861216';
  String get bannerAdUnit5 => 'ca-app-pub-1317304154938617/1527089459';




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