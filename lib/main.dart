import 'package:agora_flutter_quickstart/src/pages/First.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/pages/Second.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
        print("${snapshot.error}");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}
