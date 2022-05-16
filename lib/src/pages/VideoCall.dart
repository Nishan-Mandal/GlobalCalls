import 'dart:async';
import 'dart:math';

import 'package:agora_flutter_quickstart/src/pages/Drawer.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:vibration/vibration.dart';
import '../utils/settings.dart';
import 'package:audioplayers/audioplayers.dart';

class VideoCallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;

  /// non-modifiable client role of the page
  final ClientRole? role;

  final String? msgDocId;
  final String? userNo;
  final String? dltDoc;

  /// Creates a call page with given channel name.
  const VideoCallPage(
      {Key? key,
      this.channelName,
      this.role,
      this.msgDocId,
      this.userNo,
      this.dltDoc})
      : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

AudioPlayer plr1 = AudioPlayer();
AudioCache player1 = AudioCache(fixedPlayer: plr1);

class _VideoCallPageState extends State<VideoCallPage> {
  CommonMethods cm = CommonMethods();
  bool playNow = true;
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  int tempLengthOfChatListForVibtation = 0;
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timerToEndSearching();
    initialize();
    player1.load("joinCall.mp3");
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  playJoinCallSoundEffect() async {
    if (isSound) {
      await player1.play("joinCall.mp3");
    }
  }

  void vibrateCallConnected() async {
    if (isVibration) {
      if (await Vibration.hasCustomVibrationsSupport() != null) {
        Vibration.vibrate(duration: 600);
      } else {
        Vibration.vibrate();
        await Future.delayed(Duration(milliseconds: 300));
        Vibration.vibrate();
      }
    }
  }

  void vibrateForChat() async {
    if (isVibration) {
      if (await Vibration.hasCustomVibrationsSupport() != null) {
        Vibration.vibrate(duration: 300);
      } else {
        Vibration.vibrate();
        await Future.delayed(Duration(milliseconds: 150));
        Vibration.vibrate();
      }
    }
  }

  bool colorOfGreenDot = false;
  bool isSearching = true;
  bool timerStated = false;

  List callBots = [
    "VcBot1.gif",
    "VcBot2.gif",
    "VcBot3.gif",
    "VcBot4.gif",
    "VcBot5.gif"
  ];

  int getRandomElement() {
    Random rnd;
    int min = 0;
    int max = 4;
    rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    return r;
  }

  /// Video layout wrapper
  Widget _viewRows() {
    var isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    var screen = MediaQuery.of(context).size;
    final views = _getRenderViews();
    if (views.length == 2 && !timerStated) {
      startTimer();
      timerStated = true;
    }

    switch (views.length) {
      case 1:
        return Container(
            height: screen.height,
            width: screen.width,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                seconds2 >= 0
                    ? Container(
                        height: screen.height,
                        width: screen.width,
                        color: Colors.amber,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "searching.gif",
                            ),
                            // seconds2 >= 0
                            //     ? Text(widget.channelName??"",
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             fontSize: 15,
                            //             color: Colors.black))
                            //     : Text("")
                          ],
                        ),
                      )
                    : Center(
                        child: Container(
                            height: screen.height,
                            width: screen.width,
                            child: Image.asset(
                              callBots[randomBot],
                              fit: BoxFit.cover,
                            ))),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Container(
                    height: 110,
                    width: 90,
                    child: views[0],
                  ),
                ),
                Positioned(
                  top: 290,
                  left: screen.width / 2 - 10,
                  child: Text(
                    "$seconds2",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                seconds2 >= 0
                    ? Positioned(
                        bottom: 20,
                        // left: MediaQuery.of(context).size.width/2-35,
                        left: 140,
                        right: 140,
                        child: GestureDetector(
                          onTap: () => _onCallEnd(context, seconds ?? 0),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                      fillColor: Colors.white24,
                                      filled: true,
                                      hintText: "   Type a message...",
                                      contentPadding: const EdgeInsets.only(
                                          left: 8.0, bottom: 8.0, top: 8.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white24),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white24),
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
                                  color:
                                      !isKeyboard ? Colors.red : Colors.green,
                                  onPressed: () {},
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
                      ),
              ],
            ));
      case 2:
        colorOfGreenDot = true;
        isSearching = false;
        if (playNow) {
          playJoinCallSoundEffect();
          vibrateCallConnected();
          playNow = false;
        }
        FirebaseFirestore.instance
            .collection("videoCallsUsers-online")
            .doc(widget.dltDoc)
            .delete();

        return Container(
            height: screen.height,
            width: screen.width,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: screen.height,
                  width: screen.width,
                  child: views[1],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Container(
                    height: 110,
                    width: 90,
                    child: views[0],
                  ),
                )
              ],
            ));
    }
    return SizedBox();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context, seconds),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  TextEditingController textEditingController = TextEditingController();

  sendText(
    String text,
  ) {
    // DateTime now = DateTime.now();
    if (textEditingController.text != "") {
      var ref = FirebaseFirestore.instance
          .collection("videoCallsMessages")
          .doc(widget.channelName)
          .collection("chats")
          .doc();
      ref.set({
        "userNo": widget.userNo,
        "text": text,
        "timestamp": FieldValue.serverTimestamp()
      });
    }
  }

  Widget chatRoom(String docId) {
    var isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var screen = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
            child: SizedBox(
          height: 50,
        )),
        Container(
          height: screen.height * 0.33,
          padding: const EdgeInsets.symmetric(vertical: 30),
          // alignment: Alignment.bottomCenter,

          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("videoCallsMessages")
                  .doc(docId)
                  .collection("chats")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    int itemCount = snapshot.data?.docs.length ?? 0;
                    var userNo = snapshot.data?.docs[index]["userNo"] ?? "1";
                    String chatText = snapshot.data?.docs[index]["text"] ?? "";
                    var userNoForVibration =
                        snapshot.data?.docs.first.get("userNo") ?? "1";

                    if (!snapshot.hasData) {
                      print("no data in snapshot of chats");
                    }
                    if (snapshot.hasError) {
                      print("error in snapshot of chats");
                    }
                    if (chatText != "") {
                      if (itemCount > tempLengthOfChatListForVibtation &&
                          userNoForVibration != widget.userNo) {
                        vibrateForChat();
                        tempLengthOfChatListForVibtation = itemCount;
                      }
                      return userNo != widget.userNo
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, bottom: 4, left: 8, right: 8),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: screen.width * 0.7),
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 5, top: 5),
                                    child: Text(
                                      chatText,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, bottom: 4, left: 8, right: 8),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: screen.width * 0.7),
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 5, top: 5),
                                    child: Text(
                                      chatText,
                                      style: TextStyle(color: Colors.white),
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
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
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
                      fillColor: Colors.white24,
                      filled: true,
                      hintText: "   Type a message...",
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
                  color: !isKeyboard ? Colors.red : Colors.green,
                  onPressed: () {
                    !isKeyboard
                        ? _onCallEnd(context, seconds)
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
        SizedBox(
          height: keyboardHeight == 0 ? 10 : keyboardHeight,
        )
      ],
    );
  }

  backAlert() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Do you want to exit?"),
        actions: [
          TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.pop(context);

                _onCallEnd(context, seconds ?? 0);
              }),
          TextButton(
            child: Text("No"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  _onCallEnd(BuildContext context, int totalConversationTimeInSec) async {
    Navigator.pop(context, totalConversationTimeInSec);
    FirebaseFirestore.instance
        .collection("videoCallsUsers-online")
        .doc(widget.channelName)
        .delete();
    await FirebaseFirestore.instance
        .collection("videoCallsMessages")
        .doc(widget.msgDocId)
        .set({"someOneEndsCall": true});
    deleteChats(widget.msgDocId!);
  }

  deleteChats(String msgdDocID) async {
    await FirebaseFirestore.instance
        .collection('videoCallsMessages')
        .doc(msgdDocID)
        .collection("chats")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        await FirebaseFirestore.instance
            .collection('videoCallsMessages')
            .doc(msgdDocID)
            .collection("chats")
            .doc(doc.id)
            .delete();
      });
    });

    await FirebaseFirestore.instance
        .collection('videoCallsMessages')
        .doc(msgdDocID)
        .delete();
  }

  var randomBot;
  Duration duration = Duration();
  Timer? timer;
  var seconds;

  bool countDown = true;
  void startTimer() {
    timer2?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final views = _getRenderViews();
    final addSeconds = countDown ? 1 : -1;
    setState(() {
      seconds = duration.inSeconds + addSeconds;

      if (views.length == 1 || seconds == 300) {
        timer?.cancel();

        _onCallEnd(context, seconds);
      }

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Duration duration2 = Duration(seconds: 60);
  Timer? timer2;
  var seconds2 = 60;
  bool countDown2 = true;
  void timerToEndSearching() {
    timer2 = Timer.periodic(Duration(seconds: 1), (_) => addTime2());
  }

  void addTime2() {
    final addSeconds = countDown2 ? -1 : 1;
    setState(() {
      seconds2 = duration2.inSeconds + addSeconds;
      if (seconds2 == 5) {
        randomBot = getRandomElement();
      }
      if (seconds2 <= -3) {
        _onCallEnd(context, seconds ?? 0);
        timer2?.cancel();
      } else {
        duration2 = Duration(seconds: seconds2);
      }
    });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    // var screen = MediaQuery.of(context).size;
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return WillPopScope(
        onWillPop: () => backAlert(),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("videoCallsMessages")
                .doc(widget.msgDocId)
                .snapshots(),
            builder: (context, snapshot) {
              var userName1;
              var userName2;
              var otherUserEmail;
              try {
                userName1 = snapshot.data?["userName1"];
                userName2 = snapshot.data?["userName2"];
                if (widget.userNo == "1") {
                  otherUserEmail = snapshot.data?["userEmail2"];
                } else {
                  otherUserEmail = snapshot.data?["userEmail1"];
                }
              } catch (e) {}

              return SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        _viewRows(),
                        Positioned(
                          top: 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.userNo == "1"
                                    ? userName2 == null
                                        ? ""
                                        : "$userName2"
                                    : userName1 == null
                                        ? ""
                                        : "$userName1",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              seconds2 >= 0
                                  ? PopupMenuButton(
                                      icon: Icon(Icons.more_vert,
                                          color: colorOfGreenDot
                                              ? Colors.white
                                              : Colors.amber), // add this line
                                      itemBuilder: (_) =>
                                          <PopupMenuItem<String>>[
                                            new PopupMenuItem<String>(
                                                height: 20,
                                                child: Container(
                                                    width: 50,
                                                    child: Text(
                                                      "Report",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    )),
                                                value: 'Report'),
                                          ],
                                      onSelected: (index) async {
                                        switch (index) {
                                          case 'Report':
                                            {
                                              print(
                                                  "object=========================================");
                                              cm.reportUser(otherUserEmail);
                                              break;
                                            }
                                        }
                                      })
                                  : SizedBox()
                            ],
                          ),
                        ),
                        Positioned(
                            top: 5,
                            left: 15,
                            child: IconButton(
                              icon: Icon(
                                Icons.flip_camera_ios_outlined,
                                color:
                                    isSearching ? Colors.black : Colors.white,
                              ),
                              onPressed: () => _onSwitchCamera(),
                            )),
                        !isSearching ? chatRoom(widget.msgDocId!) : SizedBox()
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}
