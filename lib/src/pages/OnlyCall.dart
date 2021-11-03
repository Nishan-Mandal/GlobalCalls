import 'dart:async';

import 'package:agora_flutter_quickstart/src/utils/settings.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class OnlyCallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;

  /// non-modifiable client role of the page
  final ClientRole? role;

  final String? msgDocId;
  final String? userNo;

  /// Creates a call page with given channel name.
  const OnlyCallPage(
      {Key? key, this.channelName, this.role, this.msgDocId, this.userNo})
      : super(key: key);

  @override
  _OnlyCallPageState createState() => _OnlyCallPageState();
}

class _OnlyCallPageState extends State<OnlyCallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

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

    initialize();
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
    // await _engine.enableVideo();
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

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  bool timerStated = false;
 

  /// Video layout wrapper
  Widget _viewRows() {
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
                Container(
                  height: screen.height,
                  width: screen.width,
                  color: Colors.white,
                  child: AvatarGlow(
                    glowColor: Colors.blue,
                    endRadius: 130.0,
                    duration: Duration(milliseconds: 2000),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 100),
                    child: Material(
                        // Replace this child with your own
                        elevation: 8.0,
                        shape: CircleBorder(),
                        child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.black,
                            size: 50,
                          ),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Searching...",
                      style: TextStyle(
                        fontSize: 27,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: endCall(),
                  ),
                )
              ],
            ));
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Connected",
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
                SizedBox(width: 10,),
                Icon(Icons.brightness_1,color: Colors.green,size: 10,)
              ],
            ),
            buildTime(),
            SizedBox(
              height: 180,
            ),
            toolsButtons()
          ],
        );
      default:
    }
    return Container();
  }

  //  static const countdownDuration = Duration(minutes: 10);
  Duration duration = Duration();
  Timer? timer;
  bool countDown = true;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final views = _getRenderViews();
    final addSeconds = countDown ? 1 : -1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
     
      if (views.length == 1 || seconds==600) {
        timer?.cancel();
        _onCallEnd(context);
      }
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  _onCallEnd(BuildContext context) async {
    Navigator.pop(context);
    FirebaseFirestore.instance
        .collection("onlyCallsUsers-online")
        .doc(widget.channelName)
        .delete();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
            onWillPop: () => _onCallEnd(context),
            child: Center(child: _viewRows())),
      );

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hours,
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          Text(
            " : ",
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          Text(
            minutes,
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          Text(
            " : ",
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          Text(
            seconds,
            style: TextStyle(fontSize: 30, color: Colors.black),
          )
        ]);
  }

  Widget toolsButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _onToggleMute,
          child: Container(
            height: 60,
            width: 60,
            decoration:
                BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 30.0,
            ),
          ),
        ),
        SizedBox(
          width: 40,
        ),
        endCall(),
      ],
    );
  }

  Widget endCall() {
    return GestureDetector(
      onTap: () => _onCallEnd(context),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: Icon(
          Icons.call_end,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
