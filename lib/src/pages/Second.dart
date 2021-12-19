import 'dart:async';

import 'package:agora_flutter_quickstart/src/pages/CoinsPurchase.dart';
import 'package:agora_flutter_quickstart/src/pages/Drawer.dart';
import 'package:agora_flutter_quickstart/src/pages/OnlyCall.dart';
import 'package:agora_flutter_quickstart/src/pages/OnlyChat.dart';
import 'package:agora_flutter_quickstart/src/pages/First.dart';
import 'package:agora_flutter_quickstart/src/pages/Third.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_flutter_quickstart/src/utils/bannerAds.dart';
import 'package:agora_flutter_quickstart/src/utils/customNavigation.dart';
import 'package:agora_flutter_quickstart/src/utils/videoAds.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'VideoCall.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SecondPage extends StatefulWidget {
  String displayName;
  String userGender;
  SecondPage(this.displayName, this.userGender);
  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  CommonMethods cm=new CommonMethods();
  VideoAds videoAds = new VideoAds();
  RewardedAd? rewardedAd;
  bool showAds = true;
  var isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
   willShowAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showAds?videoAds.loadRewardedAd1():null;
  }

  @override
  void dispose() {
    showAds?videoAds.loadRewardedAd1():null;

    super.dispose();
  }


    willShowAds() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((value) {
        if (value.get("removeAds") == cm.getCurrentDate()) {
          setState(() {
            showAds = false;
          });
        }
      });
    }
  }


  navigateToNextScreen(String searchForWhome, int coins) {
    showAds?videoAds.showRewardedAd1():null;
    Navigator.of(context).push(CustomPageRouteAnimation(
        child: ThirdPage(
            widget.displayName, widget.userGender, searchForWhome, coins)));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    var credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // widget.userName = "${googleUser!.displayName}";
    // widget.userEmail = googleUser.email;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(googleUser!.email)
        .get()
        .then((value) async {
      var tempData;
      try {
        tempData = value.get("coins");
      } catch (e) {
        tempData = null;
      }

      if (tempData == null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(googleUser.email)
            .set({
          "name": "${googleUser.displayName}",
          "email": "${googleUser.email}",
          "photo": "${googleUser.photoUrl}",
          "coins": 0,
          "removeAds":false
        });
      }
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    final adState = Provider.of<BannerAds>(context);
    var screen = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          var userName;
          var userEmail;
          int coins;
          try {
            userName = snapshot.data?["name"];
            userEmail = snapshot.data?["email"];
            coins = snapshot.data?["coins"];
          } catch (e) {
            userName = "Anonymous";
            userEmail = " ";
            coins = 0;
          }

          return Scaffold(
              backgroundColor: Colors.black,
              key: _scaffoldKey,
              drawer: drawer("$userName", "$userEmail"),
              onDrawerChanged: (isOpen) {
                if (!isOpen ) {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .get()
                      .then((value) {
                    setState(() {
                      coins = value.get("coins");
                    });
                      
                   
                  });
              willShowAds();
                }
                  
              },
              body: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: MyShape(),
                    child: Container(),
                  ),
                  Positioned(
                      top: 40,
                      right: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 35,
                            child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => CoinPurchasePage());
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.greenAccent,
                                      
                                  size: 27,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: Image.asset(
                              "shineCoin.gif",
                              height: 22,
                              width: 22,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Text(
                            "$coins",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
                  Container(
                    height: screen.height * 0.55,
                    width: screen.width * 0.8,
                    decoration: BoxDecoration(
                        boxShadow: [
                          //background color of box
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10.0, // soften the shadow
                            spreadRadius: 5.0, //extend the shadow
                            offset: Offset(
                              -3.0, // Move to right 10  horizontally
                              3.0, // Move to bottom 10 Vertically
                            ),
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     Icon(
                        //       Icons.video_call_outlined,
                        //       size: 45,
                        //     ),
                        //     SizedBox(
                        //       width: 15,
                        //     ),
                        //     Icon(
                        //       Icons.call_outlined,
                        //       size: 30,
                        //     ),
                        //     SizedBox(
                        //       width: 15,
                        //     ),
                        //     Icon(
                        //       Icons.message_outlined,
                        //       size: 32,
                        //     ),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Connect with",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Text(
                        //   "with",
                        //   style: TextStyle(
                        //       fontSize: 20, fontWeight: FontWeight.bold),
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () => navigateToNextScreen("random", coins),
                          child: Container(
                            height: screen.width * 0.23,
                            width: screen.width * 0.7,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  //background color of box
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      -3.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "femaleAvatar.png",
                                  height: 70,
                                  width: 70,
                                ),
                                Text(
                                  "Random",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Image.asset(
                                  "maleAvatar.png",
                                  height: 70,
                                  width: 70,
                                ),
                                Spacer(),
                                Container(
                                  height: screen.width * 0.23,
                                  width: screen.width * 0.121,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.video_call,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      Icon(
                                        Icons.call,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Icon(
                                        Icons.chat,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (FirebaseAuth.instance.currentUser != null &&
                                coins > 0) {
                              navigateToNextScreen("male", coins);
                            } else if (FirebaseAuth.instance.currentUser ==
                                null) {
                              await signInWithGoogle();
                              setState(() {});
                            } else {
                              // Fluttertoast.showToast(
                              //     msg: "Insufficient coins",
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.CENTER,
                              //     timeInSecForIosWeb: 1,
                              //     backgroundColor: Colors.red,
                              //     textColor: Colors.white,
                              //     fontSize: 16.0);
                              showDialog(
                                  context: context,
                                  builder: (context) => CoinPurchasePage());
                            }
                          },
                          child: Container(
                            height: screen.width * 0.23,
                            width: screen.width * 0.7,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  //background color of box
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      -3.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20)),
                            child: Stack(
                                alignment: Alignment.topRight,
                                overflow: Overflow.clip,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "maleAvatar.png",
                                        height: 70,
                                        width: 70,
                                      ),
                                      Text(
                                        "Stranger Male",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: screen.width * 0.23,
                                        width: screen.width * 0.121,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.video_call,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            Icon(
                                              Icons.call,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Icon(
                                              Icons.chat,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (FirebaseAuth.instance.currentUser != null &&
                                coins > 0) {
                              navigateToNextScreen("female", coins);
                            } else if (FirebaseAuth.instance.currentUser ==
                                null) {
                              await signInWithGoogle();
                              setState(() {});
                            } else {
                              // Fluttertoast.showToast(
                              //     msg: "Insufficient coins",
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.CENTER,
                              //     timeInSecForIosWeb: 1,
                              //     backgroundColor: Colors.red,
                              //     textColor: Colors.white,
                              //     fontSize: 16.0);
                              showDialog(
                                  context: context,
                                  builder: (context) => CoinPurchasePage());
                            }
                          },
                          child: Container(
                            height: screen.width * 0.23,
                            width: screen.width * 0.7,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  //background color of box
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      -3.0, // Move to right 10  horizontally
                                      3.0, // Move to bottom 10 Vertically
                                    ),
                                  )
                                ],
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                Stack(alignment: Alignment.topRight, children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "femaleAvatar.png",
                                    height: 70,
                                    width: 70,
                                  ),
                                  Text(
                                    "Stranger Female",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: screen.width * 0.23,
                                    width: screen.width * 0.121,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.video_call,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        Icon(
                                          Icons.call,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Icon(
                                          Icons.chat,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "Learn more",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 110,
                    child: showAds
                        ? Container(
                            alignment: Alignment.center,
                            height: 60,
                            width: screen.width,
                            child: AdWidget(
                              ad: BannerAd(
                                  size: AdSize.banner,
                                  adUnitId: adState.bannerAdUnit3,
                                  listener: adState.adListener,
                                  request: AdRequest())
                                ..load(),
                            ),
                          )
                        : SizedBox(),
                  ),
                  Positioned(
                      top: 40,
                      left: 20,
                      child: IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: Icon(Icons.menu),
                        color: Colors.white,
                      )),
                  Positioned(
                    bottom: 20,
                    child: showAds
                        ? Container(
                            alignment: Alignment.center,
                            height: 100,
                            width: screen.width,
                            child: AdWidget(
                              ad: BannerAd(
                                  size: AdSize.largeBanner,
                                  adUnitId: adState.bannerAdUnit2,
                                  listener: adState.adListener,
                                  request: AdRequest())
                                ..load(),
                            ),
                          )
                        : SizedBox(),
                  ),
                ],
              ));
        });
  }
}

class MyShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final paint = Paint();
    final path = Path();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 15;
    paint.color = Colors.blueAccent;
    path.moveTo(0, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 1,
      size.height * 0.5,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height * 0.8);
    // canvas.drawPath(path, paint);
    final paint1 = Paint();
    paint1.style = PaintingStyle.fill;
    paint1.color = Colors.amber;
    canvas.drawPath(path, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
