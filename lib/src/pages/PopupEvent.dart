import 'package:agora_flutter_quickstart/src/pages/Second.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class PopupEventPage extends StatefulWidget {
  PopupEventPage({Key? key}) : super(key: key);

  @override
  State<PopupEventPage> createState() => _PopupEventPageState();
}

class _PopupEventPageState extends State<PopupEventPage> {
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      child: Container(
        height: 100,
        width: screen.width - 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.amber,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Hold Your Horse!",style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.bold),),
              TimerCountdown(
                format: CountDownTimerFormat.hoursMinutesSeconds,
                endTime: DateTime.now().add(
                  Duration(
                    hours: (timeList[current] - hour).abs() - 1,
                    minutes: 60 - mins,
                    seconds: sec,
                  ),
                ),
                onEnd: () {
                  print("Timer finished");
                },
                hoursDescription: "Hrs",
                minutesDescription: "Min",
                secondsDescription: "Sec",
                timeTextStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                colonsTextStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                descriptionTextStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
