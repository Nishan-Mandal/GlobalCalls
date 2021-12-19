import 'package:agora_flutter_quickstart/src/pages/CoinsPurchase.dart';
import 'package:agora_flutter_quickstart/src/pages/Second.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_flutter_quickstart/src/utils/bannerAds.dart';
import 'package:agora_flutter_quickstart/src/utils/customNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class FirstPage extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController textEditingController = TextEditingController();
  CommonMethods cm = new CommonMethods();
  String gender = "male";
  bool showAds = true;
  late BannerAd banner;
  @override
  void initState() {
    super.initState();
    cm.checkConnectivity(context);
    willShowAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final adState = Provider.of<BannerAds>(context);
    adState.initialization.then((value) {
      setState(() {
        banner = BannerAd(
            size: AdSize.mediumRectangle,
            adUnitId: adState.bannerAdUnit1,
            listener: adState.adListener,
            request: AdRequest())
          ..load();
      });
    });
  }

  @override
  void dispose() {
    cm.subscription.cancel();
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

  navigateTosecondScreen() async {
  await Navigator.of(context).push(CustomPageRouteAnimation(
        child: SecondPage(textEditingController.text, gender)));
    willShowAds();
  }

  @override
  Widget build(BuildContext context) {
    final adState = Provider.of<BannerAds>(context);

    var screen = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          painter: MyShape(),
          child: Container(),
        ),
        Positioned(
          top: 90,
          child: Container(
              // height: screen.height * 0.4,
              width: screen.height * 0.4,
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Enter Your Name :",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 30, left: 30, right: 30),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: textEditingController,
                      autofocus: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter display name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.black12,
                        filled: true,
                        labelText: "             Enter Display Name",
                        contentPadding: const EdgeInsets.only(
                            left: 8.0, bottom: 8.0, top: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(30),
                        ),

                        
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Text(
                    "Select Your Gender :",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Radio(
                        value: "male",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      Text(
                        "Male",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Radio(
                        value: "female",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      Text(
                        "Female",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Radio(
                        value: "others",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      Text(
                        "Others",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      // if (await Vibration.hasCustomVibrationsSupport()!=null) {
                      //   Vibration.vibrate(duration: 1000);
                      // } else {
                      //   Vibration.vibrate();
                      //   await Future.delayed(Duration(milliseconds: 500));
                      //   Vibration.vibrate();
                      // }
                      FocusScope.of(context).unfocus();
                      if (textEditingController.text.length != 0) {
                        navigateTosecondScreen();
                      }
                      // showDialog(context: context, builder: (context)=>CoinPurchasePage());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 25, right: 25),
                      child: Container(
                        alignment: Alignment.center,
                        // width: screen.width * 0.73,
                        height: 50,
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
                            color: Colors.orange,
                            gradient: LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Go Anonymous",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              "anonymous.png",
                              fit: BoxFit.cover,
                              height: 30,
                              width: 30,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
        Positioned(
          top: 55,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black12),
                child: Icon(
                  Icons.video_camera_front_outlined,
                  color: Colors.black,
                  size: 35,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          child: showAds
              ? Container(
                  height: 250,
                  width: 320,
                  child: AdWidget(
                    ad: BannerAd(
                        size: AdSize.mediumRectangle,
                        adUnitId: adState.bannerAdUnit1,
                        listener: adState.adListener,
                        request: AdRequest())
                      ..load(),
                  ),
                )
              : SizedBox(),
        )
      ]),
    );
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
    // path.quadraticBezierTo(
    //   size.width * 0.45,
    //   size.height * 0.95,
    //   size.width * 0.6,
    //   size.height * 0.85,
    // );
    // path.quadraticBezierTo(
    //   size.width * 0.75,
    //   size.height * 0.75,
    //   size.width * 0.85,
    //   size.height * 0.7,
    // );
    // path.quadraticBezierTo(
    //   size.width * 0.95,
    //   size.height * 0.95,
    //   size.width * 1,
    //   size.height * 0.68,
    // );
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
