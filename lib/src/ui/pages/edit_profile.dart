import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/src/models/user.dart';
import 'package:geo_attendance_system/src/services/authentication.dart';
import 'package:geo_attendance_system/src/services/database.dart';
import 'package:geo_attendance_system/src/ui/constants/colors.dart';
import 'package:geo_attendance_system/src/ui/widgets/loader_dialog.dart';

import 'homepage.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String _fullName;
  String _contactNumber;
  String _residentialAddress;
  String _email;
  String _nationalId;
  String _errorMessage = "";
  Auth authObject;
  final _formKey = new GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  static String initName;

  static String contactNumber;

  static String residentialAddress;

  static String nationalId;

  Employee mUser;

  DataBase db = new DataBase();
  FirebaseUser fb;

  String _userUid;
  bool formSubmit = false;

  @override
  void initState() {
    super.initState();

    print("enter init");
    setData();
    print("close init");
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _errorMessage = "";
      });
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      FocusScope.of(context).unfocus();
      onLoadingDialog(context);
      try {
        Employee newEmp = new Employee();
        newEmp.employeeID = _nationalId;
        newEmp.fullName = _fullName;
        newEmp.officeEmail = _email;
        newEmp.contactNumber = _contactNumber;
        newEmp.residentialAddress = _residentialAddress;
        await db.editUserData(_userUid, newEmp);
        FirebaseUser firebaseUser = await auth.currentUser();
        ;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: firebaseUser)),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("enter scaffold");

    if (initName == null) {
      return new Container();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarcolor,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Edit profile",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Poppins-Medium",
              fontSize: 22,
              letterSpacing: .6,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0.8,
        centerTitle: true,
        bottomOpacity: 0,
      ),
      body: Stack(children: <Widget>[
        SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 15.0),
                          blurRadius: 15.0),
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, -10.0),
                          blurRadius: 10.0),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          child: TextFormField(
                            initialValue: initName,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dashBoardColor),
                                ),
                                icon: Icon(
                                  Icons.person,
                                  color: dashBoardColor,
                                ),
                                hintText: "Full Name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15.0)),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Full Name can\'t be empty';
                              if (value.length < 14) return 'enter Full Name ';
                              return null;
                            },
                            onSaved: (value) => _fullName = value.trim(),
                          ),
                        ),
                        Divider(color: Colors.black),
                        Container(
                          height: 60,
                          child: TextFormField(
                            initialValue: contactNumber,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dashBoardColor),
                                ),
                                icon: Icon(
                                  Icons.phone_android,
                                  color: dashBoardColor,
                                ),
                                hintText: "Phone Number",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15.0)),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Phone Number can\'t be empty';
                              if (value.length != 11)
                                return 'enter correct Phone Number';
                              return null;
                            },
                            onSaved: (value) => _contactNumber = value.trim(),
                          ),
                        ),
                        Divider(color: Colors.black),
                        Container(
                          height: 60,
                          child: TextFormField(
                            initialValue: nationalId,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dashBoardColor),
                                ),
                                icon: Icon(
                                  Icons.perm_identity,
                                  color: dashBoardColor,
                                ),
                                hintText: "Enter your National Id",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15.0)),
                            onSaved: (value) => _nationalId = value.trim(),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'National Id can\'t be empty';
                              if (value.length != 14)
                                return 'enter correct National Id';
                              return null;
                            },
                          ),
                        ),
                        Divider(color: Colors.black),
                        Container(
                          height: 60,
                          child: TextFormField(
                            initialValue: residentialAddress,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dashBoardColor),
                                ),
                                icon: Icon(
                                  Icons.add_location,
                                  color: dashBoardColor,
                                ),
                                hintText: "Your Address",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15.0)),
                            onSaved: (value) =>
                                _residentialAddress = value.trim(),
                          ),
                        ),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          splashScreenColorBottom,
                          Color(0xFF6078ea)
                        ]),
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xFF6078ea).withOpacity(.3),
                              offset: Offset(0.0, 8.0),
                              blurRadius: 8.0)
                        ]),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: validateAndSubmit,
                        child: Center(
                          child: Text("Save Changes",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 18,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        )),
      ]),
    );
  }

  Future setData() async {
    authObject = new Auth();
    authObject.getCurrentUser().then((value) async {
      _userUid = value.uid;
      await db.getUser(value.uid).then((user) async {
        setState(() {
          initName = user.value['fullName'];
          contactNumber = user.value['contactNumber'];
          residentialAddress = user.value['residentialAddress'];
          nationalId = user.value['employeeID'];
          print("done");
        });
      });
    });
  }
}
