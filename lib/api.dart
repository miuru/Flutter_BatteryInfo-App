import 'package:battery_info/batteryInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batteryInfo.dart';

class Api {
  String collectionName = "Battery";

  getUsers() {
    return Firestore.instance.collection(collectionName).snapshots();
  }

  addBattery(date,battery) {
    Battery user = Battery(date: date , battery: battery);
    try {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await Firestore.instance
            .collection(collectionName)
            .document()
            .setData(user.toJson());
      });
    } catch (e) {
      print(e.toString());
    }
  }

}
