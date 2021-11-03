import 'dart:async';

import 'package:agora_flutter_quickstart/src/pages/OnlyCall.dart';
import 'package:agora_flutter_quickstart/src/pages/OnlyChat.dart';
import 'package:agora_flutter_quickstart/src/pages/First.dart';
import 'package:agora_flutter_quickstart/src/pages/Third.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'VideoCall.dart';

class SecondPage extends StatefulWidget {
  String displayName;
  String userGender;
  SecondPage(this.displayName, this.userGender);
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<SecondPage> {
  navigateToNextScreen(String searchForWhome) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ThirdPage(widget.displayName,widget.userGender,searchForWhome)));
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

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
              height: screen.height *0.55,
              width: screen.width * 0.8,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_call_outlined,
                        size: 45,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Icon(
                        Icons.call_outlined,
                        size: 30,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Icon(
                        Icons.message_outlined,
                        size: 32,
                      ),
                    ],
                  ),
                  Text(
                    "with",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => navigateToNextScreen("random"),
                    child: Container(
                      height: screen.width * 0.23,
                      width: screen.width * 0.7,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("femaleAvatar.png"),
                          Text(
                            "Random",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                           Image.asset("maleAvatar.png"),
                         
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => navigateToNextScreen("male"),
                    child: Container(
                      height: screen.width * 0.23,
                      width: screen.width * 0.7,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("maleAvatar.png"),
                          Text(
                            "Stranger Male",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => navigateToNextScreen("female"),
                    child: Container(
                      height: screen.width * 0.23,
                      width: screen.width * 0.7,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("femaleAvatar.png"),
                          Text(
                            "Stranger Female",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        ));
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
