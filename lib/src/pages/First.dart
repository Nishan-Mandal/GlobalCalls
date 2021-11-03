import 'package:agora_flutter_quickstart/src/pages/Second.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController textEditingController = TextEditingController();
  String gender = "male";
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

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
              height: screen.height * 0.4,
              width: screen.height * 0.4,
              decoration: BoxDecoration(
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
                  
                      controller: textEditingController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.black12,
                        filled: true,
                        hintText: "             Enter Display Name",
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
                   
                      if (textEditingController.text.length!=0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SecondPage(
                                    textEditingController.text, gender)));
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: screen.width * 0.73,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "Save",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
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
                  Icons.video_call,
                  color: Colors.black,
                  size: 35,
                ),
              ),
            ),
          ),
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
