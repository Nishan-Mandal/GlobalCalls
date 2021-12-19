import 'package:agora_flutter_quickstart/src/pages/CoinsPurchase.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:agora_flutter_quickstart/src/utils/CommonMethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class drawer extends StatefulWidget {
  String userName;
  String userEmail;
  drawer(this.userName, this.userEmail);
  @override
  _drawerState createState() => _drawerState();
}

bool isSound = true;
bool isVibration = true;

class _drawerState extends State<drawer> {
  CommonMethods cm = new CommonMethods();

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
    widget.userName = "${googleUser!.displayName}";
    widget.userEmail = googleUser.email;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(googleUser.email)
        .get()
        .then((value) async {
      var tempData;
      try {
        tempData = value.get("coins");
      } catch (e) {
        tempData = await null;
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
          "removeAds": false
        });
      }
    });
    // FirebaseFirestore.instance.collection("users").doc(googleUser.email).update({
    //   "name": "${googleUser.displayName}",
    //   "email": "${googleUser.email}",
    //   "photo": "${googleUser.photoUrl}",
    // });

    setState(() {});
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  removeAdsPopup(var removeAds, var coinData) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Text(
              "All Ads will be removed till 12:00 AM today at cost of 100 coins.",
              style: TextStyle(color: Colors.amber, fontSize: 16),
            ),
            Text(
              "\nDo you want to continue?",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          TextButton(
              child: Text("Yes"),
              onPressed: () async {
                if (coinData >= 100) {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .get()
                      .then((value) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .update({
                      "coins": value.get("coins") - 100,
                      "removeAds": cm.getCurrentDate()
                    });
                  });
                  Navigator.pop(context);
                } else if (removeAds != cm.getCurrentDate()) {
                  showDialog(
                      context: context,
                      builder: (context) => CoinPurchasePage());
                }
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

  rateUs() {
    double ratingStars = 0;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Container(
          height: 300,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // image: DecorationImage(
                      //     image: AssetImage("appLogo.png"),
                      //     fit: BoxFit.fill)
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Enjoying Sleep Relax Sounds?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                  Text("Tap a star to rate it on the"),
                  Text("Play Store."),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    thickness: 1,
                    height: 6,
                  ),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 0,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        ratingStars = rating;
                      });
                    },
                  ),
                  Divider(
                    thickness: 1,
                    height: 6,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    child: Text(
                      "SUBMIT",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber),
                    ),
                    onTap: () {
                      if (ratingStars > 2) {
                        StoreRedirect.redirect(
                          androidAppId: "com.ultimateRocker.sleepsound2021",
                        );
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.orange,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  feedback_HelpSupportByEmail(
      String toEmail, String subject, String body) async {
    final url =
        'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchUrl(String urlLink) async {
    final url = urlLink;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(35), bottomRight: Radius.circular(35)),
        child: Drawer(
            child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.amber,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.lime[200]),
                    child: Text(
                      widget.userName.substring(0, 1),
                      style:
                          TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  widget.userName != "Anonymous"
                      ? Text(
                          widget.userEmail,
                          style: TextStyle(color: Colors.black),
                        )
                      : InkWell(
                          onTap: () async {
                            await signInWithGoogle();
                            // Navigator.pop(context);
                            //  Navigator.pop(context);
                          },
                          child: Text(
                            "Register/login",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  widget.userName != "Anonymous"
                      ? Text(
                          "Premium user",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        )
                      : SizedBox(),
                  widget.userName != "Anonymous"
                      ? StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.userEmail)
                              .snapshots(),
                          builder: (context, snapshot) {
                            var coinData = snapshot.data?["coins"];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "coin.png",
                                  height: 25,
                                  width: 25,
                                ),
                                Text(
                                  "$coinData",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  width: 15,
                                  child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                CoinPurchasePage());
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.black,
                                        size: 22,
                                      )),
                                ),
                              ],
                            );
                          })
                      : SizedBox(),
                ],
              ),
            ),
            
           
            ListTile(
              leading: Icon(
                Icons.volume_down_outlined,
                size: 30,
              ),
              title: Text(
                "Sound effects",
                style: TextStyle(fontSize: 17),
              ),
              trailing: Switch(
                value: isSound,
                onChanged: (value) {
                  setState(() {
                    isSound = value;
                    print(isSound);
                  });
                },
                activeTrackColor: Colors.amber,
                activeColor: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.vibration_sharp),
              title: Text(
                "Vibrations",
                style: TextStyle(fontSize: 17),
              ),
              trailing: Switch(
                value: isVibration,
                onChanged: (value) {
                  setState(() {
                    isVibration = value;
                    print(isVibration);
                  });
                },
                activeTrackColor: Colors.amber,
                activeColor: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text(
                "Feedback",
                style: TextStyle(fontSize: 17),
              ),
              trailing: Icon(Icons.send),
              onTap: () => feedback_HelpSupportByEmail(
                  'ultimaterocker1994@gmail.com', 'Feedback', ""),
            ),
            ListTile(
              leading: Icon(
                Icons.star,
              ),
              title: Text(
                "Rate Us",
                style: TextStyle(fontSize: 17),
              ),
              onTap: () => rateUs(),
            ),
             ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 17),
              ),
              onTap: ()=>launchUrl("https://ultimaterocker1994.blogspot.com/p/privacy-policytalks.html"),
            ),
               ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text(
                "Terms & Conditions",
                style: TextStyle(fontSize: 17),
              ),
              onTap: ()=>launchUrl("https://ultimaterocker1994.blogspot.com/p/terms-conditionstalks.html"),
            ),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  var removeAds;
                  var coinData;
                  try {
                    removeAds = snapshot.data?["removeAds"];
                    coinData = snapshot.data?["coins"];
                  } catch (e) {}

                  return ListTile(
                      onTap: () async {
                        if (FirebaseAuth.instance.currentUser == null) {
                          await signInWithGoogle();
                          setState(() {});
                        } else if (removeAds != cm.getCurrentDate()) {
                          removeAdsPopup(removeAds, coinData);
                        }
                      },
                      leading: Icon(
                        Icons.block,
                        color: Colors.red,
                      ),
                      title: Text(
                        "Remove Ads",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: removeAds != cm.getCurrentDate()
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "coin.png",
                                  height: 20,
                                  width: 20,
                                ),
                                Text(
                                  "100/D",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.check,
                              color: Colors.green,
                            ));
                }),
            Spacer(),
            widget.userName != "Anonymous"
                ? ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 17),
                    ),
                    onTap: () {
                      GoogleSignIn().signOut();
                      FirebaseAuth.instance.signOut();
                      // widget.userName = "Guest user";
                      // widget.userEmail = " ";
                      // setState(() {});
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
                : SizedBox()
          ],
        )));
  }
}
