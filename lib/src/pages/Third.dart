import 'package:agora_flutter_quickstart/src/pages/CoinsPurchase.dart';
import 'package:agora_flutter_quickstart/src/pages/First.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_flutter_quickstart/src/utils/bannerAds.dart';
import 'package:agora_flutter_quickstart/src/utils/customNavigation.dart';
import 'package:agora_flutter_quickstart/src/utils/videoAds.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'OnlyCall.dart';
import 'OnlyChat.dart';
import 'VideoCall.dart';

class ThirdPage extends StatefulWidget {
  String displayName;
  String userGender;
  String searchForWhome;
  int coins;
  ThirdPage(this.displayName, this.userGender, this.searchForWhome, this.coins);
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  CommonMethods cm=new CommonMethods();
  bool showAds = true;

  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error

  ClientRole? _role = ClientRole.Broadcaster;
  VideoAds videoAds = new VideoAds();
  int countForAds = 0;
  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    if (widget.searchForWhome != "random") {
      coinUpdateInDatabase();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    showAds?videoAds.loadRewardedAd1():null;
    willShowAds();
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


  coinUpdateInDatabase() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({"coins": widget.coins});
  }

  String userNo = "";
  addUserVideoCall(
      String displayName, String usersGender, List searchForWhome) async {
    List temp = ["random", "random"];
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                  child: CupertinoActivityIndicator(
                radius: 20,
              )),
            ));

    overlayState?.insert(overlayEntry);
    if (listEquals(searchForWhome, temp) == true) {
      var databaseCount = await FirebaseFirestore.instance
          .collection("videoCallsCount")
          .doc("PkdMgHIERse4HRq2SsUb")
          .get()
          .then((value) => value.get("count"));
      int count = databaseCount + 1;
      String joinCode = "null";
      await FirebaseFirestore.instance
          .collection('videoCallsUsers-online')
          .where("searchForWhome", arrayContains: "random")
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });
      if (joinCode == "null") {
        var ref = FirebaseFirestore.instance
            .collection("videoCallsUsers-online")
            .doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "name": displayName,
          "count": "${count}",
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome),
        });
        setState(() {
          userNo = "1";
        });
        var messag = await FirebaseFirestore.instance
            .collection("videoCallsMessages")
            .doc(joinCode);

        messag.set({
          "userName1": displayName,
          "userName2": " ",
          "someOneEndsCall": false
        });
        messag.collection("chats").doc().set({"userNo": userNo, "text": null});
        onJoin(joinCode, userNo, "videoCall");
        overlayEntry.remove();
      } else {
        setState(() {
          userNo = "2";
        });

        await FirebaseFirestore.instance
            .collection('videoCallsUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("videoCallsUsers-online")
                .doc(doc.id)
                .delete();
          });
        });

        var messag = await FirebaseFirestore.instance
            .collection("videoCallsMessages")
            .doc(joinCode);

        messag.update({"userName2": displayName});
        messag.collection("chats").doc().set({"userNo": userNo, "text": null});
        onJoin(joinCode, userNo, "videoCall");
        overlayEntry.remove();
      }

      await FirebaseFirestore.instance
          .collection("videoCallsCount")
          .doc("PkdMgHIERse4HRq2SsUb")
          .update({"count": count});
    } else {
      var databaseCount = await FirebaseFirestore.instance
          .collection("videoCallsCount")
          .doc("PkdMgHIERse4HRq2SsUb")
          .get()
          .then((value) => value.get("count"));
      int count = databaseCount + 1;
      String joinCode = "null";
      await FirebaseFirestore.instance
          .collection('videoCallsUsers-online')
          .where("gender", whereIn: searchForWhome)
          .where("searchForWhome", arrayContains: usersGender)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });
      if (joinCode == "null") {
        var ref = FirebaseFirestore.instance
            .collection("videoCallsUsers-online")
            .doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "count": "${count}",
          "name": displayName,
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome)
        });
        setState(() {
          userNo = "1";
        });

        var messag = await FirebaseFirestore.instance
            .collection("videoCallsMessages")
            .doc(joinCode);
        messag.set({
          "userName1": displayName,
          "userName2": " ",
          "someOneEndsCall": false
        });
        messag.collection("chats").doc().set({"userNo": userNo, "text": null});
        onJoin(joinCode, userNo, "videoCall");
        overlayEntry.remove();
      } else {
        setState(() {
          userNo = "2";
        });

        var messag = await FirebaseFirestore.instance
            .collection("videoCallsMessages")
            .doc(joinCode);
        messag.update({"userName2": displayName});
        messag.collection("chats").doc().set({"userNo": userNo, "text": null});
        onJoin(joinCode, userNo, "videoCall");
        overlayEntry.remove();
        await FirebaseFirestore.instance
            .collection('videoCallsUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("videoCallsUsers-online")
                .doc(doc.id)
                .delete();
          });
        });
      }

      await FirebaseFirestore.instance
          .collection("videoCallsCount")
          .doc("PkdMgHIERse4HRq2SsUb")
          .update({"count": count});
    }
  }

  String userNoOnlyCall = "";
  addUserOnlyCall(
      String displayName, String usersGender, List searchForWhome) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                  child: CupertinoActivityIndicator(
                radius: 20,
              )),
            ));

    overlayState?.insert(overlayEntry);

    var databaseCount = await FirebaseFirestore.instance
        .collection("onlyCallsCount")
        .doc("JtAaJIMUxaxjpBfSt6kM")
        .get()
        .then((value) => value.get("count"));
    int count = databaseCount + 1;
    String joinCode = "null";
    List temp = ["random", "random"];
    if (listEquals(searchForWhome, temp) == true) {
      await FirebaseFirestore.instance
          .collection('onlyCallsUsers-online')
          .where("searchForWhome", arrayContains: "random")
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });
      if (joinCode == "null") {
        var ref = FirebaseFirestore.instance
            .collection("onlyCallsUsers-online")
            .doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "count": "${count}",
          "name": displayName,
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome),
        });
        setState(() {
          userNoOnlyCall = "1";
        });
      } else {
        setState(() {
          userNoOnlyCall = "2";
        });

        await FirebaseFirestore.instance
            .collection('onlyCallsUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("onlyCallsUsers-online")
                .doc(doc.id)
                .delete();
          });
        });
      }
    } else {
      await FirebaseFirestore.instance
          .collection('onlyCallsUsers-online')
          .where("gender", whereIn: searchForWhome)
          .where("searchForWhome", arrayContains: usersGender)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });
      if (joinCode == "null") {
        var ref = FirebaseFirestore.instance
            .collection("onlyCallsUsers-online")
            .doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "count": "${count}",
          "name": displayName,
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome)
        });
        setState(() {
          userNoOnlyCall = "1";
        });
      } else {
        setState(() {
          userNoOnlyCall = "2";
        });

        await FirebaseFirestore.instance
            .collection('onlyCallsUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("onlyCallsUsers-online")
                .doc(doc.id)
                .delete();
          });
        });
      }
    }

    onJoin(joinCode, userNo, "onlyCall");
    overlayEntry.remove();
    await FirebaseFirestore.instance
        .collection("onlyCallsCount")
        .doc("JtAaJIMUxaxjpBfSt6kM")
        .update({"count": count});
  }

  String userNoOnlyChat = "";
  addUserOnlyChat(
      String displayName, String usersGender, List searchForWhome) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                  child: CupertinoActivityIndicator(
                radius: 20,
              )),
            ));

    overlayState?.insert(overlayEntry);
    var databaseCount = await FirebaseFirestore.instance
        .collection("onlyChatCount")
        .doc("39uC3A9gR4obTHkkljAU")
        .get()
        .then((value) => value.get("count"));
    int count = databaseCount + 1;
    String joinCode = "null";

    List temp = ["random", "random"];
    if (listEquals(searchForWhome, temp) == true) {
      await FirebaseFirestore.instance
          .collection('onlyChatUsers-online')
          .where("searchForWhome", arrayContains: "random")
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });

      if (joinCode == "null") {
        var ref =
            FirebaseFirestore.instance.collection("onlyChatUsers-online").doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "count": "${count}",
          "name": displayName,
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome),
        });
        setState(() {
          userNoOnlyChat = "1";
        });
        var message = await FirebaseFirestore.instance
            .collection("onlyChatMessages")
            .doc(joinCode);
        message.set({
          "userName1": displayName,
          "userName2": " ",
          "bothUserConnected": false,
          "someOneEndsCall": false
        });
        message
            .collection("chats")
            .doc()
            .set({"userNo": userNoOnlyChat, "text": null});
      } else {
        setState(() {
          userNoOnlyChat = "2";
        });

        await FirebaseFirestore.instance
            .collection('onlyChatUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("onlyChatUsers-online")
                .doc(doc.id)
                .delete();
          });
        });

        var message = await FirebaseFirestore.instance
            .collection("onlyChatMessages")
            .doc(joinCode);
        message.update({"userName2": displayName, "bothUserConnected": true});
        message
            .collection("chats")
            .doc()
            .set({"userNo": userNoOnlyChat, "text": null});
      }
    } else {
      await FirebaseFirestore.instance
          .collection('onlyChatUsers-online')
          .where("gender", whereIn: searchForWhome)
          .where("searchForWhome", arrayContains: usersGender)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          joinCode = doc["joinCode"];
        });
      });

      if (joinCode == "null") {
        var ref =
            FirebaseFirestore.instance.collection("onlyChatUsers-online").doc();
        setState(() {
          joinCode = ref.id;
        });
        ref.set({
          "count": "${count}",
          "name": displayName,
          "joinCode": joinCode,
          "gender": usersGender,
          "searchForWhome": FieldValue.arrayUnion(searchForWhome),
        });
        setState(() {
          userNoOnlyChat = "1";
        });
        var message = await FirebaseFirestore.instance
            .collection("onlyChatMessages")
            .doc(joinCode);
        message.set({
          "userName1": displayName,
          "userName2": " ",
          "bothUserConnected": false,
          "someOneEndsCall": false
        });
        message
            .collection("chats")
            .doc()
            .set({"userNo": userNoOnlyChat, "text": null});
      } else {
        setState(() {
          userNoOnlyChat = "2";
        });

        await FirebaseFirestore.instance
            .collection('onlyChatUsers-online')
            .orderBy("count")
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection("onlyChatUsers-online")
                .doc(doc.id)
                .delete();
          });
        });

        var message = await FirebaseFirestore.instance
            .collection("onlyChatMessages")
            .doc(joinCode);
        message.set({"userName1": displayName, "bothUserConnected": true});
        message
            .collection("chats")
            .doc()
            .set({"userNo": userNoOnlyChat, "text": null});
      }
    }
    overlayEntry.remove();

    navigateToChatScreen(joinCode, userNoOnlyChat);

    FirebaseFirestore.instance
        .collection("onlyChatCount")
        .doc("39uC3A9gR4obTHkkljAU")
        .update({"count": count});
  }

  navigateToChatScreen(
    String joinCode,
    String userNoOnlyChat,
  ) async {
    var data = await Navigator.of(context).push(CustomPageRouteAnimation(
        child: OnlyChatPage(joinCode, userNoOnlyChat)));
    updateCoinInfo(data, "chatOnly", widget.searchForWhome);
  }

  Future<void> onJoin(String joinCode, String userNo, String mode) async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    int data = await Navigator.of(context).push(CustomPageRouteAnimation(
      child: mode == "onlyCall"
          ? OnlyCallPage(
              channelName: joinCode,
              role: _role,
              msgDocId: joinCode,
              userNo: userNo,
            )
          : VideoCallPage(
              channelName: joinCode,
              role: _role,
              msgDocId: joinCode,
              userNo: userNo,
            ),
    ));
    if (mode == "onlyCall") {
      updateCoinInfo(data, "audioCall", widget.searchForWhome);
    } else {
      updateCoinInfo(data, "videoCall", widget.searchForWhome);
    }
  }

  updateCoinInfo(int seconds, String callType, String searchForWhome) {
    if (searchForWhome != "random" && callType == "videoCall" && seconds > 10) {
      widget.coins = widget.coins - 6;
      callsHistory(callType, 6, seconds);
    } else if (searchForWhome != "random" &&
        callType == "audioCall" &&
        seconds > 10) {
      widget.coins = widget.coins - 4;
      callsHistory(callType, 4, seconds);
    } else if (searchForWhome != "random" &&
        callType == "chatOnly" &&
        seconds > 30) {
      widget.coins = widget.coins - 3;
      callsHistory(callType, 3, seconds);
    }
  }

  callsHistory(String callType, int coinUsed, int durationInSec) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("callsHistory")
        .doc()
        .set({
      "callType": callType,
      "timestamp": FieldValue.serverTimestamp(),
      "coinUsed": coinUsed,
      "durationInSec": durationInSec,
    });
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
  }

  @override
  Widget build(BuildContext context) {
    final adState = Provider.of<BannerAds>(context);
    var screen = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    if ((countForAds + 3) % 5 == 0) {
      showAds?videoAds.loadRewardedAd1():null;
    }
    if (countForAds % 5 == 0) {
      showAds?videoAds.showRewardedAd1():null;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: MyShape(),
            child: Container(),
          ),
          Container(
            height: screen.width - 70,
            width: screen.width - 70,
            decoration: BoxDecoration(boxShadow: [
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
            ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Stack(alignment: Alignment.topRight, children: [
              Container(
                alignment: Alignment.center,
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                    boxShadow: [
                      //background color of box
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                        offset: Offset(
                          -3.0, // Move to right 10  horizontally
                          3.0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                    color: Colors.lime,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Text(
                  widget.searchForWhome != "random" ? "PRIMIUM" : "FREE",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 30,
                  // ),
                  // Image.asset(name)

                  widget.searchForWhome == "random"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "maleAvatar.png",
                              height: 130,
                              fit: BoxFit.fill,
                            ),
                            Text(
                              "OR",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Image.asset(
                              "femaleAvatar.png",
                              height: 110,
                              fit: BoxFit.fill,
                            )
                          ],
                        )
                      : (widget.searchForWhome == "female"
                          ? Image.asset(
                              "femaleAvatar.png",
                              height: 150,
                              fit: BoxFit.fill,
                            )
                          : Image.asset(
                              "maleAvatar.png",
                              height: 150,
                              fit: BoxFit.fill,
                            )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                            setState(() {
                            countForAds++;
                          });

                          if (countForAds % 5 != 0) {
                          if (widget.coins >= 5 ||
                              widget.searchForWhome == "random") {
                            addUserOnlyCall(
                                widget.displayName,
                                widget.userGender,
                                ["${widget.searchForWhome}", "random"]);
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => CoinPurchasePage());
                          }
                          }
                        },
                        child: Container(
                          height: screen.width * 0.18,
                          width: screen.width * 0.18,
                          decoration: BoxDecoration(
                              boxShadow: [
                                //background color of box
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    -3.0, // Move to right 10  horizontally
                                    3.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    Colors.amber,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight),
                              borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call_outlined,
                                size: 30,
                              ),
                              // Text(
                              //   "Call",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          // showOverlay(context);
                          setState(() {
                            countForAds++;
                          });

                          if (countForAds % 5 != 0) {
                            if (widget.coins >= 5 ||
                                widget.searchForWhome == "random") {
                              addUserVideoCall(
                                  widget.displayName,
                                  widget.userGender,
                                  ["${widget.searchForWhome}", "random"]);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => CoinPurchasePage());
                            }
                          }
                        },
                        child: Container(
                          height: screen.width * 0.24,
                          width: screen.width * 0.24,
                          decoration: BoxDecoration(
                              boxShadow: [
                                //background color of box
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    -3.0, // Move to right 10  horizontally
                                    3.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    Colors.amber,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight),
                              borderRadius: BorderRadius.circular(50)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_call_outlined,
                                size: 60,
                              ),
                              // Text(
                              //   "Video Call",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () { 
                            setState(() {
                            countForAds++;
                          });

                          if (countForAds % 5 != 0) {
                          addUserOnlyChat(
                            widget.displayName,
                            widget.userGender,
                            ["${widget.searchForWhome}", "random"]);
                        }},
                        child: Container(
                          height: screen.width * 0.18,
                          width: screen.width * 0.18,
                          decoration: BoxDecoration(
                              boxShadow: [
                                //background color of box
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    -3.0, // Move to right 10  horizontally
                                    3.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    Colors.amber,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight),
                              borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_outlined,
                                size: 30,
                              ),
                              // Text(
                              //   "Chat",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ]),
          ),
          // Positioned(
          //     right: 40,
          //     top: 260,
          //     child: ),
          Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              )),

          Positioned(
            top: 100,
            child: showAds
                ? Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: screen.width,
                    child: AdWidget(
                      ad: BannerAd(
                          size: AdSize.largeBanner,
                          adUnitId: adState.bannerAdUnit4,
                          listener: adState.adListener,
                          request: AdRequest())
                        ..load(),
                    ),
                  )
                : SizedBox(),
          ),

          Positioned(
            bottom: 0,
            child: showAds
                ? Container(
                    alignment: Alignment.center,
                    height: 250,
                    width: screen.width,
                    child: AdWidget(
                      ad: BannerAd(
                          size: AdSize.mediumRectangle,
                          adUnitId: adState.bannerAdUnit5,
                          listener: adState.adListener,
                          request: AdRequest())
                        ..load(),
                    ),
                  )
                : SizedBox(),
          ),
        ],
      ),
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
