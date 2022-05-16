import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class CoinPurchasePage extends StatefulWidget {
  CoinPurchasePage({Key? key}) : super(key: key);

  @override
  _CoinPurchasePageState createState() => _CoinPurchasePageState();
}

class _CoinPurchasePageState extends State<CoinPurchasePage> {

  CommonMethods cm=CommonMethods();
  late Razorpay razorpay;
  String? email=FirebaseAuth.instance.currentUser!.email;


  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
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
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  int noOfCoinsBuying=1;
  void openCheckout(int amount,String email,int coins ){
    setState(() {
      noOfCoinsBuying=coins;
    });
    // rzp_live_XigAfbfQuxHIww 
    var options = {
      "key" : "rzp_test_q2a12YNiSI1fli",
      "amount" : amount*100,
      "name" : "Talks",
      "description" : "Payment for purchasing coins",
      "prefill" : {
        "contact" : "",
        "email" : email
      },
      "external" : {
        "wallets" : ["paytm"]
      }
    };

    try{
      razorpay.open(options);

    }catch(e){
      print(e.toString());
    }

  }

  void handlerPaymentSuccess(PaymentSuccessResponse response){
    cm.addCoinsInDatabase(noOfCoinsBuying);
    print('Success Response: $response');
  }

  void handlerErrorFailure(){
    print("Pament error");
   
  }

  void handlerExternalWallet(){
    print("External Wallet");
    
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
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
                            onTap: (){
                              openCheckout(1, email!,100);
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
                            onTap: (){
                              openCheckout(140, email!,300);
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
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 15, right: 15),
                    //   child: Divider(
                    //     thickness: 0,
                    //   ),
                    // ),
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
                            onTap: (){
                              openCheckout(380, email!,800);
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
                    // Padding(
                    //       padding: const EdgeInsets.only(left: 15, right: 15),
                    //       child: Divider(
                    //         thickness: 0,
                    //       ),
                    //     ),
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
                            onTap: (){
                              openCheckout(1200, email!,2500);
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
