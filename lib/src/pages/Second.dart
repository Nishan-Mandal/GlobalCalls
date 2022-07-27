import 'dart:async';

import 'package:agora_flutter_quickstart/src/pages/CoinsPurchase.dart';
import 'package:agora_flutter_quickstart/src/pages/Drawer.dart';
import 'package:agora_flutter_quickstart/src/pages/Third.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_flutter_quickstart/src/utils/bannerAds.dart';
import 'package:agora_flutter_quickstart/src/utils/customNavigation.dart';
import 'package:agora_flutter_quickstart/src/utils/videoAds.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:intl/intl.dart';

import 'PopupEvent.dart';

List<String> imgList = [];

List<int> timeList = [];
List<String> temp = [];

int current = 0;
int firstIndex = 0;
int secondIndex = 0;
int secondIndexTime = 0;
DateTime now = DateTime.now().toUtc();
String formattedTime = DateFormat.Hm().format(now);
var parts = formattedTime.split(':');
int hour = int.parse(parts[0].trim());
int mins = int.parse(parts[1].trim());
int sec = 0;
bool intestedInEvent = false;
bool isEventRunning = false;

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            color: Colors.black54
          ),
          width: 400,
          margin: EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: Image.network(
              item,
              fit: BoxFit.cover,
              width: 1000.0,
              height: 1000,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                );
              },
            ),
          ),
        ))
    .toList();

class SecondPage extends StatefulWidget {
  String displayName;
  String userGender;
  String uid;
  SecondPage(this.displayName, this.userGender, this.uid);
  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  final CarouselController _controller = CarouselController();
  int slideImgIndex = 0;
  CommonMethods cm = new CommonMethods();
  VideoAds videoAds = new VideoAds();
  RewardedAd? rewardedAd;
  bool showAds = true;
  var isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
    eventToShowNow();
    willShowAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showAds ? videoAds.loadRewardedAd1() : null;
  }

  @override
  void dispose() {
    showAds ? videoAds.loadRewardedAd1() : null;
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
    showAds ? videoAds.showRewardedAd1() : null;
    Navigator.of(context).push(CustomPageRouteAnimation(
        child: ThirdPage(widget.displayName, widget.userGender, searchForWhome,
            coins, widget.uid)));
  }

  launchUrl(String urlLink) async {
    final url = urlLink;

    if (await canLaunch(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
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
          "removeAds": false,
          "reports": 0
        });
      }
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void animateToSlide(int index) => _controller.animateToPage(index);
  Widget buildSlideIndicator() => AnimatedSmoothIndicator(
        activeIndex: current,
        count: imageSliders.length,
        onDotClicked: animateToSlide,
        effect: SlideEffect(
            dotHeight: 7, dotWidth: 7, activeDotColor: Colors.white),
      );

  interestCount() async {
    var databaseCount = await FirebaseFirestore.instance
        .collection("events")
        .doc(temp[0])
        .get()
        .then((value) => value.get("interested"));
    int count = databaseCount + 1;
    await FirebaseFirestore.instance
        .collection("events")
        .doc(temp[0])
        .update({"interested": count});
  }

  eventToShowNow() {
    bool foundAny = false;
    try {
      for (int i = 0; i < timeList.length; i++) {
        if (timeList[i] > hour && i != 0) {
          setState(() {
            current = i;
            firstIndex = i;
            secondIndex = firstIndex - 1;
            secondIndexTime = timeList[secondIndex];
            if ((hour - secondIndexTime).abs() <= 1) {
              isEventRunning = true;
            }
            foundAny = true;
          });
          break;
        } else if (timeList[i] > hour && i == 0) {
          setState(() {
            current = i;
            firstIndex = i;
            secondIndex = timeList.length - 1;
            secondIndexTime = timeList[secondIndex];
            if ((hour - secondIndexTime).abs() < 1) {
              isEventRunning = true;
            }
            foundAny = true;
          });
          break;
        }
      }
      if (!foundAny) {
        setState(() {
          current = 0;
          firstIndex = 0;
          secondIndex = timeList.length - 1;
          secondIndexTime = timeList[secondIndex];
          if (hour - secondIndexTime < 1) {
            isEventRunning = true;
          }
        });
      }
    } catch (e) {
      print("Exception: $e");
    }
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 35,
                                child: IconButton(
                                    onPressed: () async {
                                      // cm.addCoinsInDatabase(100);
                                      // showDialog(
                                      //     context: context,
                                      //     builder: (context) => CoinPurchasePage());

                                      if (FirebaseAuth.instance.currentUser ==
                                          null) {
                                        await signInWithGoogle();
                                        setState(() {});
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                CoinPurchasePage());
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.greenAccent,
                                      size: 27,
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 4),
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
                          ),
                        ],
                      )),

                  Positioned(
                    top: 90,
                    child: Stack(
                        overflow: Overflow.visible,
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 250,
                            width: screen.width - 20,
                            child: CarouselSlider(
                              items: imageSliders,
                              carouselController: _controller,
                              options: CarouselOptions(
                                  initialPage: current,
                                  height: 250,
                                  // autoPlay: true,
                                  enlargeCenterPage: true,
                                  // aspectRatio: 2.0,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.height,
                                  // autoPlayAnimationDuration: Duration(seconds: 1),
                                  viewportFraction: 1,
                                  autoPlayInterval: Duration(seconds: 2),
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      current = index;
                                      slideImgIndex = index;
                                      DateTime now = DateTime.now().toUtc();
                                      formattedTime =
                                          DateFormat.Hm().format(now);
                                      parts = formattedTime.split(':');
                                      hour = int.parse(parts[0].trim());
                                      mins = int.parse(parts[1].trim());
                                      sec = 0;
                                    });
                                  }),
                            ),
                          ),
                          Positioned(
                              bottom: 20,
                              right: 30,
                              child: Center(child: buildSlideIndicator())),
                          Positioned(
                              bottom: 40,
                              child: Container(
                                height: 40,
                                width: screen.width - 40,
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                ),
                              )),
                          current == firstIndex
                              ? Positioned(
                                  bottom: 42,
                                  right: 20,
                                  child: TimerCountdown(
                                    format: CountDownTimerFormat
                                        .hoursMinutesSeconds,
                                    endTime: DateTime.now().add(
                                      Duration(
                                        hours:
                                            (timeList[current] - hour).abs() -
                                                1,
                                        minutes: 60 - mins,
                                        seconds: sec,
                                      ),
                                    ),
                                    onEnd: () {
                                      print("Timer finished");
                                      setState(() {});
                                    },
                                    hoursDescription: "Hrs",
                                    minutesDescription: "Min",
                                    secondsDescription: "Sec",
                                    timeTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    colonsTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    descriptionTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          current == firstIndex
                              ? Positioned(
                                  top: 20,
                                  left: 66,
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Colors.black,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.male,
                                        size: 24,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ))
                              : SizedBox(),
                          current == firstIndex
                              ? Positioned(
                                  top: 20,
                                  left: 42,
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Colors.black,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.amber,
                                      child: Icon(
                                        Icons.female,
                                        size: 24,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ))
                              : SizedBox(),
                          current == firstIndex
                              ? Positioned(
                                  top: 20,
                                  left: 20,
                                  child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Colors.black,
                                      child: Text(
                                        "100+",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )))
                              : SizedBox(),
                          current == firstIndex
                              ? Positioned(
                                  bottom: 44,
                                  left: 40,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        interestCount();
                                        intestedInEvent = true;
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius:
                                                BorderRadiusDirectional
                                                    .circular(10)),
                                        height: 32,
                                        width: 95,
                                        alignment: Alignment.center,
                                        child: !intestedInEvent
                                            ? Text(
                                                "Interested",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              )
                                            : Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Joining",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  ),
                                                ],
                                              )),
                                  ),
                                )
                              : SizedBox(),
                          Positioned(
                              bottom: 45,
                              child: (current != firstIndex &&
                                      current != secondIndex)
                                  ? Text(
                                      "UPCOMMING",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    )
                                  : SizedBox()),
                          Positioned(
                              bottom: 45,
                              child: (hour - secondIndexTime < 1 &&
                                      current == secondIndex)
                                  ? InkWell(
                                      onTap: () =>
                                          navigateToNextScreen("random", coins),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(5)),
                                          height: 32,
                                          width: 75,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "LIVE ⚪️",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    )
                                  : (current == secondIndex &&
                                          current != firstIndex)
                                      ? Text(
                                          "UPCOMMING",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        )
                                      : SizedBox()),
                        ]),
                  ),

                  Positioned(
                    bottom: screen.width - screen.width * 0.9,
                    child: Container(
                      height: screen.height * 0.5,
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
                            onTap: () => isEventRunning
                                ? navigateToNextScreen("random", coins)
                                : showDialog(
                                    context: context,
                                    builder: (context) => PopupEventPage()),
                            child: Stack(
                                overflow: Overflow.visible,
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    height: screen.width * 0.23,
                                    width: screen.width * 0.7,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          //background color of box
                                          BoxShadow(
                                            color: Colors.black38,
                                            blurRadius:
                                                5.0, // soften the shadow
                                            spreadRadius:
                                                1.0, //extend the shadow
                                            offset: Offset(
                                              -3.0, // Move to right 10  horizontally
                                              3.0, // Move to bottom 10 Vertically
                                            ),
                                          )
                                        ],
                                        color: Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "femaleAvatar.png",
                                          height: 70,
                                          width: 70,
                                        ),
                                        Spacer(),
                                        Text(
                                          "Random",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
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
                                  ),
                                  Positioned(
                                      top: -20,
                                      left: -20,
                                      child: SizedBox(
                                          height: 55,
                                          width: 55,
                                          child: Image(
                                              image: AssetImage("free.png")))),
                                  Positioned(
                                    top: 0,
                                    left: screen.width * 0.25,
                                    child: isEventRunning
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: isEventRunning
                                                    ? Colors.red
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadiusDirectional
                                                        .circular(5)),
                                            height: 20,
                                            width: 45,
                                            alignment: Alignment.center,
                                            child: Text(
                                              "LIVE ⚪️",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                        : SizedBox(),
                                  ),
                                  !isEventRunning
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            height: screen.width * 0.1,
                                            width: screen.width * 0.7,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20))),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                isEventRunning
                                                    ? SizedBox()
                                                    : Text(
                                                        "STARTS IN",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                isEventRunning
                                                    ? SizedBox()
                                                    : TimerCountdown(
                                                        format: CountDownTimerFormat
                                                            .hoursMinutesSeconds,
                                                        endTime:
                                                            DateTime.now().add(
                                                          Duration(
                                                            hours:
                                                                (timeList[firstIndex] -
                                                                            hour)
                                                                        .abs() -
                                                                    1,
                                                            minutes: 60 - mins,
                                                            seconds: sec,
                                                          ),
                                                        ),
                                                        onEnd: () {
                                                          print(
                                                              "Timer finished");
                                                        },
                                                        timeTextStyle:
                                                            TextStyle(
                                                          color:
                                                              Colors.red[400],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                        colonsTextStyle:
                                                            TextStyle(
                                                          color:
                                                              Colors.red[400],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                        descriptionTextStyle:
                                                            TextStyle(
                                                          color:
                                                              Colors.red[400],
                                                          fontSize: 5,
                                                        ),
                                                        spacerWidth: 1,
                                                        enableDescriptions:
                                                            false,
                                                      ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox()
                                ]),
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
                                  Stack(overflow: Overflow.visible, children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                Positioned(
                                    top: -14,
                                    left: -14,
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Image.asset(
                                        "shineCoin.gif",
                                      ),
                                    )),
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
                                  overflow: Overflow.visible,
                                  alignment: Alignment.topRight,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                    Positioned(
                                        top: -14,
                                        left: -14,
                                        child: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Image.asset(
                                            "shineCoin.gif",
                                          ),
                                        )),
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () => launch(
                                "https://ultimaterocker1994.blogspot.com/p/learn-more-talks.html"),
                            child: Text(
                              "Learn more",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Positioned(
                  //   top: 80,
                  //   child: showAds
                  //       ? Container(

                  //           alignment: Alignment.center,
                  //           height: 60,
                  //           width: screen.width,
                  //           child: AdWidget(
                  //             ad: BannerAd(
                  //                 size: AdSize.banner,
                  //                 adUnitId: adState.bannerAdUnit3,
                  //                 listener: adState.adListener,
                  //                 request: AdRequest())
                  //               ..load(),
                  //           ),
                  //         )
                  //       : SizedBox(),
                  // ),
                  Positioned(
                      top: 40,
                      left: 20,
                      child: IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: Icon(Icons.menu),
                        color: Colors.white,
                      )),
                  // Positioned(
                  //   bottom: 20,
                  //   child: showAds
                  //       ? Container(
                  //           alignment: Alignment.center,
                  //           height: 100,
                  //           width: screen.width,
                  //           child: AdWidget(
                  //             ad: BannerAd(
                  //                 size: AdSize.largeBanner,
                  //                 adUnitId: adState.bannerAdUnit2,
                  //                 listener: adState.adListener,
                  //                 request: AdRequest())
                  //               ..load(),
                  //           ),
                  //         )
                  //       : SizedBox(),
                  // ),
                ],
              ));
        });
  }
}

class MyShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
    return true;
  }
}
