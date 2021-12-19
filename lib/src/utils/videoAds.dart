import 'package:google_mobile_ads/google_mobile_ads.dart';

class VideoAds {
  String get rewardedAdUnitID1 => 'ca-app-pub-3940256099942544/5224354917';
  RewardedAd? _rewardedAd;
  void loadRewardedAd1() {
    RewardedAd.load(
        adUnitId: rewardedAdUnitID1,
        request: AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          print("Ad loaded====================");
          _rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load rewardedAd");
        }));
  }

    showRewardedAd1() {
      try{
    _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
      print("User saw the full video!");
    });
    
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
    }catch(e){
        print("falil to load videoAd ---");
      }
  }
}
