

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
class Coins{
  static const idCoin100='100_coins';
  static const idCoin300='300_coins';
  static const idCoin800='800_coins';
  static const idCoin2500='2500_coins';

  static const allIds=[idCoin100,idCoin300,idCoin800,idCoin2500];
}
class PurchaseApi{
  // goog_qJXSsZDjLabFcaMVsMgVaKDZyUN
  static const _apiKey='goog_qJXSsZDjLabFcaMVsMgVaKDZyUN';
  static Future init()async{
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apiKey);
  }

  static Future<List<Offering>> fetchOffersByIds(List<String> ids) async{
    final offers=await fetchOffers();
    return offers.where((offer) => ids.contains(offer.identifier)).toList();
  }


  static Future<List<Offering>> fetchOffers({bool all=true}) async{
    try{
          final offerings=await Purchases.getOfferings();
          if(!all){
            final current=offerings.current;
            return current==null?[]:[current];
          }
          else{
            return offerings.all.values.toList();
          }
          
    }on PlatformException catch(e){
      return [];
    }

  }

  static Future<bool> purchasePackage(Package package) async{
    try{
      await Purchases.purchasePackage(package);
      return true;
    }catch(e){
      return false;
    }
  }
}