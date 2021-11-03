import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'OnlyCall.dart';
import 'OnlyChat.dart';
import 'VideoCall.dart';

class ThirdPage extends StatefulWidget {
  String displayName;
  String userGender;
  String searchForWhome;
  ThirdPage(this.displayName, this.userGender, this.searchForWhome);
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error

  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  String userNo = "";
  addUserVideoCall(
      String displayName, String usersGender, List searchForWhome) async {
    List temp = ["random", "random"];

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
    await FirebaseFirestore.instance
        .collection("onlyCallsCount")
        .doc("JtAaJIMUxaxjpBfSt6kM")
        .update({"count": count});
  }

  String userNoOnlyChat = "";
  addUserOnlyChat(
      String displayName, String usersGender, List searchForWhome) async {
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
        message.set({ "userName1": displayName,
          "userName2": " ","bothUserConnected": false, "someOneEndsCall": false});
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
        message.update({"userName2": displayName,"bothUserConnected": true});
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
        message.set({"userName1": displayName,
          "userName2": " ","bothUserConnected": false, "someOneEndsCall": false});
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
        message.set({"userName1": displayName,"bothUserConnected": true});
        message
            .collection("chats")
            .doc()
            .set({"userNo": userNoOnlyChat, "text": null});
      }
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OnlyChatPage(joinCode, userNoOnlyChat)));

    FirebaseFirestore.instance
        .collection("onlyChatCount")
        .doc("39uC3A9gR4obTHkkljAU")
        .update({"count": count});
  }

  Future<void> onJoin(String joinCode, String userNo, String mode) async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => mode == "onlyCall"
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
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
            height: screen.height * 0.35,
            width: screen.height * 0.35,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => addUserVideoCall(
                      widget.displayName,
                      widget.userGender,
                      ["${widget.searchForWhome}", "random"]),
                  child: Container(
                    height: screen.width * 0.25,
                    width: screen.width * 0.25,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight),
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_call_outlined,
                          size: 50,
                        ),
                        Text(
                          "Video Call",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => addUserOnlyCall(
                          widget.displayName,
                          widget.userGender,
                          ["${widget.searchForWhome}", "random"]),
                      child: Container(
                        height: screen.width * 0.25,
                        width: screen.width * 0.25,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight),
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.call_outlined,
                              size: 40,
                            ),
                            Text(
                              "Call",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () => addUserOnlyChat(
                          widget.displayName,
                          widget.userGender,
                          ["${widget.searchForWhome}", "random"]),
                      child: Container(
                        height: screen.width * 0.25,
                        width: screen.width * 0.25,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight),
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_outlined,
                              size: 40,
                            ),
                            Text(
                              "Chat",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ))
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
