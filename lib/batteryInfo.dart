import 'package:cloud_firestore/cloud_firestore.dart';

class Battery {
  String date;
  String battery;
  DocumentReference reference;

  Battery({this.date,this.battery});

  Battery.fromMap(Map<String, dynamic> map, {this.reference}) {
    date = map["date"];
    battery = map["battery"];
  }

  Battery.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  toJson() {
    return {'date': date, 'battery':battery};
  }
}
