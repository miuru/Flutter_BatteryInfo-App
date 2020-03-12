import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final databaseReference = FirebaseDatabase.instance.reference();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battery Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BatteryLevelPage(),
    );
  }
}

class BatteryLevelPage extends StatefulWidget {
  @override
  _BatteryLevelPageState createState() => _BatteryLevelPageState();
}

class _BatteryLevelPageState extends State<BatteryLevelPage> {
  final Battery _battery = Battery();

  static BatteryState _batteryState;
  static int _batteryLevel;
  String battery = _batteryLevel.toString();
  String batteryState = _batteryState.toString();

  @override
  void initState() {
    super.initState();

    _battery.batteryLevel.then((level) {
      this.setState(() {
        _batteryLevel = level;
      });
    });

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _battery.batteryLevel.then((level) {
        this.setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Battery Level"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25.0,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "My Battery App",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 55.0,
            ),
            SizedBox(
              height: 35.0,
              width: 200.0,
              child: CustomPaint(
                painter: _BatteryLevelPainter(_batteryLevel, _batteryState),
                child: _batteryState == BatteryState.charging
                    ? Icon(
                        Icons.flash_on,
                        color: Colors.white,
                      )
                    : Container(),
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              "Battery Level : $_batteryLevel %", //battery level display
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28.0),
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              printText(_batteryState),
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28.0),
            ),
            SizedBox(
              height: 85.0,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondRoute()),
                );
              },
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: const Text('Battery usage of past 10 days',
                    style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Returns the Battery State
String printText(text) {
  if (text == BatteryState.charging) {
    return "Battery State : Charging";
  } else {
    print(text);
    return "Battery State : Discharging";
  }
}

//Retrieve all data from firebase
getData() {
  databaseReference.once().then((DataSnapshot snapshot) {
    final String data = snapshot.value.toString();
    print(data);

    return data;
  });
}

//Past records Screen // need to  display the data
class SecondRoute extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Second Route"),
        ),
        body: Column(children: <Widget>[]));
  }
}

//Battery level indicator and state monitoring
class _BatteryLevelPainter extends CustomPainter {
  final int _batteryLevel;
  final BatteryState _batteryState;

  _BatteryLevelPainter(this._batteryLevel, this._batteryState);

  @override
  void paint(Canvas canvas, Size size) {
    Paint getPaint(
        {Color color = Colors.white,
        PaintingStyle style = PaintingStyle.stroke}) {
      return Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = style;
    }

    final double batteryRight = size.width - 4.0;
    final RRect batteryOutline = RRect.fromLTRBR(
        0.0, 0.0, batteryRight, size.height, Radius.circular(3.0));

    // Battery body
    canvas.drawRRect(
      batteryOutline,
      getPaint(),
    );

    // Battery nub
    canvas.drawRect(
      Rect.fromLTWH(batteryRight, (size.height / 2.0) - 5.0, 4.0, 10.0),
      getPaint(style: PaintingStyle.fill),
    );

    // Fill rect
    canvas.clipRect(Rect.fromLTWH(
        0.0, 0.0, batteryRight * _batteryLevel / 100.0, size.height));

    Color indicatorColor;

    if (_batteryLevel < 15) {
      indicatorColor = Colors.red;
    } else if (_batteryLevel < 30) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    canvas.drawRRect(
        RRect.fromLTRBR(0.5, 0.5, batteryRight - 0.5, size.height - 0.5,
            Radius.circular(3.0)),
        getPaint(style: PaintingStyle.fill, color: indicatorColor));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final _BatteryLevelPainter old = oldDelegate as _BatteryLevelPainter;
    var now = new DateTime.now();
    var date = new DateFormat("yyyy-MM-dd hh:mm:ss").format(now);

    if (_batteryState == BatteryState.charging) {
      createRecord(_batteryLevel, date);
    }

    return old._batteryLevel != _batteryLevel ||
        old._batteryState != _batteryState;
  }

  void createRecord(batteryLevel, date) {
    databaseReference
        .child(date)
        .set({'date ': date, 'battery %  ': batteryLevel});
  }
}

