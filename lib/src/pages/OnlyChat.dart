import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnlyChatPage extends StatefulWidget {
  String joincode;
  String userNo;

  OnlyChatPage(this.joincode, this.userNo);

  @override
  _OnlyChatPageState createState() => _OnlyChatPageState();
}

class _OnlyChatPageState extends State<OnlyChatPage> {
  TextEditingController textEditingController = TextEditingController();

  sendText(
    String text,
  ) {
    // DateTime now = DateTime.now();
    if (textEditingController.text != "") {
      var ref = FirebaseFirestore.instance
          .collection("onlyChatMessages")
          .doc(widget.joincode)
          .collection("chats")
          .doc();
      ref.set({
        "userNo": widget.userNo,
        "text": text,
        "timestamp": FieldValue.serverTimestamp()
      });
    }
  }

  _onCallEnd(BuildContext context) async {
    Navigator.pop(context);
    FirebaseFirestore.instance
        .collection("onlyChatUsers-online")
        .doc(widget.joincode)
        .delete();
    await FirebaseFirestore.instance
        .collection("onlyChatMessages")
        .doc(widget.joincode)
        .set({"someOneEndsCall": true});
    deleteChats(widget.joincode);
  }

  deleteChats(String msgdDocID) async {
    await FirebaseFirestore.instance
        .collection('onlyChatMessages')
        .doc(msgdDocID)
        .collection("chats")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        await FirebaseFirestore.instance
            .collection('onlyChatMessages')
            .doc(msgdDocID)
            .collection("chats")
            .doc(doc.id)
            .delete();
      });
    });

    await FirebaseFirestore.instance
        .collection('onlyChatMessages')
        .doc(msgdDocID)
        .delete();
  }

  Duration duration = Duration();
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  bool countDown = true;
  void addTime() {
    final addSeconds = countDown ? 1 : -1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      FirebaseFirestore.instance
          .collection("onlyChatMessages")
          .doc(widget.joincode)
          .get()
          .then((value) {
        if (value.get("someOneEndsCall") == true) {
          timer?.cancel();
          _onCallEnd(context);
        }
      });

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return WillPopScope(
      onWillPop: () => _onCallEnd(context),
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("onlyChatMessages")
              .doc(widget.joincode)
              .snapshots(),
          builder: (context, snapshot) {
            var bothUserConnected;
            var OtherUserName;

            try {
              bothUserConnected = snapshot.data?["bothUserConnected"];
              if (widget.userNo == 1) {
                OtherUserName = snapshot.data?["userName2"];
              } else {
                OtherUserName = snapshot.data?["userName1"];
              }

              ;
            } catch (e) {
              print(e);
            }

            return Scaffold(
              body: Container(
                height: screen.height,
                width: screen.width,
                color: Colors.black12,
                child: Column(
                  children: [
                    Container(
                      width: screen.width,
                      height: statusBarHeight + screen.width * 0.13,
                      color: Colors.indigo[200],
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: statusBarHeight),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              bothUserConnected == true
                                  ? "$OtherUserName"
                                  : "Searching...",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.brightness_1,
                              color: bothUserConnected == true
                                  ? Colors.green
                                  : Colors.indigo[200],
                              size: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("onlyChatMessages")
                              .doc(widget.joincode)
                              .collection("chats")
                              .orderBy("timestamp", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data?.docs.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                var userNo =
                                    snapshot.data?.docs[index]["userNo"] ?? "1";
                                String chatText =
                                    snapshot.data?.docs[index]["text"] ?? "";
                                if (!snapshot.hasData) {
                                  print("no data in snapshot of chats");
                                }
                                if (snapshot.hasError) {
                                  print("error in snapshot of chats");
                                }
                                if (chatText != "") {
                                  return userNo != widget.userNo
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                                left: 15,
                                                right: 8),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: screen.width * 0.7,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12,
                                                    right: 10,
                                                    bottom: 10,
                                                    top: 10),
                                                child: Text(
                                                  chatText,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                                left: 8,
                                                right: 15),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: screen.width * 0.7,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Colors.indigo[300],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12,
                                                    right: 10,
                                                    bottom: 10,
                                                    top: 10),
                                                child: Text(
                                                  chatText,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                }
                                return SizedBox();
                              },
                            );
                          }),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "   Type something...",
                                  contentPadding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0, top: 8.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            height: 50,
                            width: 70,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              color: !isKeyboard ? Colors.red : Colors.blue,
                              onPressed: () {
                                !isKeyboard
                                    ? _onCallEnd(context)
                                    : sendText(textEditingController.text);
                                textEditingController.clear();
                              },
                              child: Icon(
                                !isKeyboard ? Icons.call_end : Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
