import 'package:firebase_database/firebase_database.dart';
import 'package:geo_attendance_system/src/models/user.dart';

class DataBase {
  final databaseRef = FirebaseDatabase.instance.reference();

  final usersRef = FirebaseDatabase.instance.reference().child("users");
  Employee mUser;

  Future addUser(Employee user, String uid) async {
    try {
      return await usersRef.child(uid).set(user.toJson());
    } catch (e) {
      return e;
    }
  }

  Future getUser(String Uid) async {
    try {
      DataSnapshot dataSnapshot = await usersRef.child(Uid).once();
      if (dataSnapshot != null) {
        mUser = Employee.fromSnapshot(dataSnapshot);
        return dataSnapshot;
      } else
        return null;
    } catch (e) {
      return e;
    }
  }

  void editUserData(String Uid , Employee user) async {
    await usersRef.child(Uid).update({
      'contactNumber' : user.contactNumber ,
      'employeeID' : user.employeeID,
      'fullName' : user.fullName ,
      'officeEmail' : user.officeEmail ,
      'residentialAddress' : user.residentialAddress ,
    });
  }

  Future<Employee> getUserData(String Uid) async {
    try {
      DataSnapshot dataSnapshot = await usersRef.child(Uid).once();
      if (dataSnapshot != null) {
        mUser = Employee.fromSnapshot(dataSnapshot);
        return mUser;
      } else
        return null;
    } catch (e) {
      return e;
    }
  }

  Future getAllLocations() async {
    try {
      DataSnapshot dataSnapshot = await databaseRef.child("location").once();
      return dataSnapshot;
    } catch (e) {
      return e;
    }
  }

  Future getAllUsers() async {
    try {
      var dataSnapshot = (await usersRef.once());
      if (dataSnapshot != null) {
        return dataSnapshot;
      } else
        return null;
    } catch (e) {
      return e;
    }
  }
}
