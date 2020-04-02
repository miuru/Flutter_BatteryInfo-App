import 'package:battery_info/models/batteryInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/batteryInfo.dart';
import '../models/user.dart';

class Api {
  String collectionName = "Battery";
  String userCollectionName = 'User';

  getBatteryData() {
//    var before24Hour = new DateTime(year).getTime() - (24 * 3600 * 1000);
    DateTime today = new DateTime.now();
    DateTime tenDaysAgo = today.subtract(new Duration(days: 10));
    print(tenDaysAgo);
    return Firestore.instance
        .collection(collectionName)
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots();
  }

  addBattery(date, battery) {
    Battery user = Battery(date: date, battery: battery);
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

  getUsers() {
    var data = Firestore.instance
        .collection(userCollectionName)
        .where('name', isEqualTo: 'miurus')
        .limit(1)
        .snapshots();
    return Firestore.instance.collection(userCollectionName).snapshots();
  }

  addUsers(name) {
    User user = User(name: name);
    try {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await Firestore.instance
            .collection(userCollectionName)
            .document()
            .setData(user.toJson());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  update(User user, String newName) {
    try {
      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(user.reference, {'name': newName});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  delete(User user) {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(user.reference);
    });
  }
}
