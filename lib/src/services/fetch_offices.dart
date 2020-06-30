import 'dart:async';
import 'package:geo_attendance_system/src/services/database.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:geo_attendance_system/src/models/office.dart';

class OfficeDatabase {
  final _databaseReference = FirebaseDatabase.instance.reference();
  static final OfficeDatabase _instance = OfficeDatabase._internal();

  factory OfficeDatabase() {
    return _instance;
  }

  OfficeDatabase._internal();

  Future<Office> getOfficeBasedOnUID(String uid) async {
    DataSnapshot dataSnapshot;
    DataSnapshot userInfo = await DataBase().getUser(uid);
    var office = userInfo.value["allotted_office"];

    dataSnapshot = await DataBase().getAllLocations();
    var findOffice = dataSnapshot.value;

    String name;
    double latitude, longitude, radius;
    Map<dynamic, dynamic> values = findOffice;

    values.forEach((k, s) {
      if (s["name"] == office["name"]) {
        name = s["name"];
        latitude = s["latitude"];
        longitude = s["longitude"];
        if (s["radius"] == null) {
          radius = 200.0;
        } else{
          var temp = s["radius"];
          radius = double.tryParse(temp.toString());

        }
      }
    });

    return Office(
        key: office["name"],
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius);
  }

  Future<List<Office>> getOfficeList() async {
    DataSnapshot dataSnapshot = await _databaseReference.once();
    //Completer<List<Office>> completer;
    final officeList = dataSnapshot.value["location"];
    List<Office> result = [];

    var officeMap = officeList;
    officeMap.forEach((key, map) {
      result.add(Office.fromJson(key, map.cast<String, dynamic>()));
    });

    return result;
  }
}
