import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_flutter_quickstart/src/utils/purchaseApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CoinPurchasePage extends StatefulWidget {
  CoinPurchasePage({Key? key}) : super(key: key);

  @override
  _CoinPurchasePageState createState() => _CoinPurchasePageState();
}

class _CoinPurchasePageState extends State<CoinPurchasePage> {
  CommonMethods cm = CommonMethods();
  String? email = FirebaseAuth.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
  }

  Future fetchOffers(List<String> packageId,int numberOfCoins) async {
    final offerings = await PurchaseApi.fetchOffersByIds(packageId);
    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Plans Found")));
    } else {
      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();
      final isSuccess = await PurchaseApi.purchasePackage(packages[0]);
      if(isSuccess){
        buyCoins(numberOfCoins);
      }
      else if(!isSuccess){
              ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Transaction Failed")));
      }
    }
  }

  buyCoins(
    int numberOfCoins,
  ) async {
    var coins;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      coins = value.get("coins") + numberOfCoins;
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({"coins": coins});
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  int noOfCoinsBuying = 0;

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                  top: -40,
                  left: 40,
                  child: Image.asset(
                    "coin.png",
                    width: 70,
                  )),
              Positioned(
                  top: -40,
                  right: 40,
                  child: Image.asset(
                    "coin.png",
                    width: 70,
                  )),
              Positioned(
                  top: -75,
                  child: SizedBox(
                      width: 100,
                      child: Image.asset(
                        "coin.png",
                        fit: BoxFit.fill,
                      ))),
              Container(
                height: screen.height * 0.4,
                width: screen.width,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "SAVE 30%",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: screen.height * 0.08,
                      width: screen.width * 0.7,
                      padding: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "stackCoins.gif",
                            height: 25,
                          ),
                          Text(
                            "100",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹50",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "₹71",
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                fetchOffers(['100_coins'],100);
                              } catch (e) {
                                print(e);
                              }

                           
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screen.height * 0.05,
                              width: screen.width * 0.2,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "Buy",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    Container(
                      height: screen.height * 0.08,
                      width: screen.width * 0.7,
                      padding: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "stackCoins.gif",
                            height: 25,
                          ),
                          Text(
                            "300",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹140",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "₹200",
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          GestureDetector(
                            onTap: () {
                              try {
                                fetchOffers(['300_coins'],300);
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screen.height * 0.05,
                              width: screen.width * 0.2,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "Buy",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
    
                    Container(
                      height: screen.height * 0.08,
                      width: screen.width * 0.7,
                      padding: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "stackCoins.gif",
                            height: 25,
                          ),
                          Text(
                            "800",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹380",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "₹543",
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          GestureDetector(
                            onTap: () {
                              try {
                                fetchOffers(['800_coins'],800);
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screen.height * 0.05,
                              width: screen.width * 0.2,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "Buy",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
           
                    Container(
                      height: screen.height * 0.08,
                      width: screen.width * 0.7,
                      padding: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "stackCoins.gif",
                            height: 25,
                          ),
                          Text(
                            "2500",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹1200",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "₹1715",
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () {
                              try {
                                fetchOffers(['2500_coins'],2500);
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screen.height * 0.05,
                              width: screen.width * 0.2,
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "Buy",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  right: 2,
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.cancel,
                        size: 25,
                        color: Colors.black,
                      ))),
            ]));
  }
}
