import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'main.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        navigateAfterSeconds: new BatteryLevelPage(),
        seconds: 3,
        title: new Text(
          'Welcome to My Battery App',
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
            fontSize: 25.0,
          ),
        ),
        image: Image.asset("images/batterysplash.jpg"),
        backgroundColor: Colors.black,
        styleTextUnderTheLoader: new TextStyle(
          fontSize: 45.0,
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.bold,
        ),
        photoSize: 120.0,
        onClick: () => print("Flutter Battery"),
        loaderColor: Colors.deepPurpleAccent);
  }
}
