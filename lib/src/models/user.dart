import 'package:firebase_database/firebase_database.dart';

import 'office.dart';

enum EmployeeType { supervisor, Manager, worker }

enum Role { Cooling_agent, Mechanic, electrician }

class Employee {
  String uID;
  String UUID;
  String employeeID;
  String fullName;
  String officeEmail;
  String contactNumber;
  String residentialAddress;

  Office joiningUnit;
  String designation;

  String employeeType;
  Employee reviewPerson;
  String  role;

  Employee(
      {this.employeeID,
      this.fullName,
      this.residentialAddress,
      this.contactNumber,
      this.officeEmail,
      this.joiningUnit,
      this.designation,
      this.employeeType,
      this.reviewPerson,
      this.UUID,
      this.role});

  Employee.fromSnapshot(DataSnapshot snapshot)
      : uID = snapshot.value["UID"],
        employeeID = snapshot.value["employeeID"],
        fullName = snapshot.value["fullName"],
        UUID = snapshot.value["UUID"],
        officeEmail = snapshot.value["officeEmail"],
        joiningUnit = snapshot.value["joiningUnit"],
        designation = snapshot.value["designation"],
        employeeType = snapshot.value["employeeType"],
        reviewPerson = snapshot.value["reviewPerson"],
        contactNumber = snapshot.value["contactNumber"],
        residentialAddress = snapshot.value["residentialAddress"],
        role = snapshot.value["role"];

  toJson() {
    return {
      "employeeID": employeeID,
      "fullName": fullName,
      "officeEmail": officeEmail,
      "joiningUnit": joiningUnit,
      "designation": designation,
      "employeeType": employeeType,
      "reviewPerson": reviewPerson,
      "role": role,
      "UUID": UUID,
      "contactNumber":contactNumber,
      "residentialAddress":residentialAddress
    };
  }
}
