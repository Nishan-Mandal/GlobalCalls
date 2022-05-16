import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class CommonMethods {
  late StreamSubscription subscription;
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off_rounded),
        SizedBox(
          width: 10,
        ),
        Text("No Internet connection")
      ],
    ),
    duration: Duration(hours: 5),
    backgroundColor: Colors.redAccent,
  );
  void checkConnectivity(BuildContext context) {
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (!hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  String getCurrentDate() {
    var date = new DateTime.now().toString();

    var dateParse = DateTime.parse(date);

    var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    return formattedDate.toString();
  }

  Future<void> reportUser(String userEmail) async {
    var reportCount = await FirebaseFirestore.instance
        .collection("users")
        .doc(userEmail)
        .get()
        .then((value) => value.get("reports"));
    FirebaseFirestore.instance
        .collection("users")
        .doc(userEmail)
        .update({"reports": reportCount + 1});
  }

  addCoinsInDatabase(int noOfcoins) async {
    String? email=FirebaseAuth.instance.currentUser!.email;
    var databaseCoins = await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .get()
        .then((value) => value.get("coins"));
    int coins = databaseCoins + noOfcoins;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .update({"coins": coins});
  }
}
