import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geo_attendance_system/src/models/user.dart';
import 'package:geo_attendance_system/src/services/database.dart';
import 'package:geo_attendance_system/src/services/fetch_IMEI.dart';
import 'package:geo_attendance_system/src/ui/constants/colors.dart';
import 'package:geo_attendance_system/src/ui/pages/homepage.dart';
import 'package:geo_attendance_system/src/ui/pages/login.dart';
import 'package:geo_attendance_system/src/ui/widgets/loader_dialog.dart';

import '../../services/authentication.dart';

class SignUp extends StatefulWidget {
  SignUp({this.auth});

  final BaseAuth auth;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = new GlobalKey<FormState>();
  FirebaseDatabase db = new FirebaseDatabase();

  String _fullName;
  String _email;
  String _password;
  String _contactNumber;
  String _residentialAddress;
  String _employeeType;
  String _role;
  String _nationalId;
  String _errorMessage = "";
  List<String> _roleValues = [];

  String _userUid;
  bool formSubmit = false;
  Auth authObject;

  @override
  void initState() {
    authObject = new Auth();

    super.initState();
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
        signUpUser(_email);
      } catch (e) {
        print(e);
      }
    }
  }

  void signUpUser(String email) async {
    if (email != null) {
      try {
        _userUid = await authObject.signUp(email, _password);
        Employee emp = new Employee();
        emp.fullName = _fullName;
        emp.role = _role;
        emp.employeeType = _employeeType;
        emp.officeEmail = _email;
        emp.contactNumber = _contactNumber;
        emp.employeeID = _nationalId;
        emp.residentialAddress = _residentialAddress;
        List listOfDetails = await getDeviceDetails();
        emp.UUID = listOfDetails[2];

        DataBase().addUser(emp, _userUid);
        FirebaseUser mUser = await authObject.signIn(email, _password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: mUser)),
        );
      } catch (e) {
        Navigator.of(context).pop();
        print("Error" + e.toString());
        setState(() {
          _errorMessage = e.message.toString();
          _formKey.currentState.reset();
        });
      }
    } else {
      setState(() {
        _errorMessage = "Invalid Login Details";
        _formKey.currentState.reset();
        Navigator.of(context).pop();
      });
    }
  }

  Widget horizontalLine() =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    ScreenUtil.instance = ScreenUtil.getInstance()
      ..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage('assets/back.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 28.0, right: 28.0, top: 60.0, bottom: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          "assets/logo/logo.png",
                          width: ScreenUtil.getInstance().setWidth(220),
                          height: ScreenUtil.getInstance().setHeight(220),
                        ),
                        SizedBox(
                          width: ScreenUtil.getInstance().setWidth(40),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("ZACKS",
                                  style: TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      color: appbarcolor,
                                      fontSize:
                                      ScreenUtil.getInstance().setSp(90),
                                      letterSpacing: .6,
                                      fontWeight: FontWeight.bold)),
                              Text("Attendance and HR Management System",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      color: Colors.black54,
                                      fontSize:
                                      ScreenUtil.getInstance().setSp(25),
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(90),
                    ),
                    formCard(),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            width: ScreenUtil.getInstance().setWidth(330),
                            height: ScreenUtil.getInstance().setHeight(100),
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
                                  child: Text("Sign Up",
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
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(40),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        horizontalLine(),
                        Text("Other Options",
                            style: TextStyle(
                                fontSize: 12.0, fontFamily: "Poppins-Medium")),
                        horizontalLine()
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(40),
                    ),
//                    SizedBox(
//                      height: ScreenUtil.getInstance().setHeight(30),
//                    ),
                    InkWell(
                      child: Container(
                        width: ScreenUtil.getInstance().setWidth(330),
                        height: ScreenUtil.getInstance().setHeight(100),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            child: Center(
                              child: Text("Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Poppins-Bold",
                                      fontSize: 18,
                                      letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(40),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget formCard() {
    return new Container(
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
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("sign Up",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(45),
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .6)),
          SizedBox(
            height: ScreenUtil.getInstance().setHeight(30),
          ),
          Container(
            height: 60,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.person,
                    color: dashBoardColor,
                  ),
                  hintText: "Full Name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              validator: (value) =>
              value.isEmpty ? 'Full Name can\'t be empty' : null,
              onSaved: (value) => _fullName = value.trim(),
            ),
          ),
          Container(
            height: 60,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.email,
                    color: dashBoardColor,
                  ),
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              validator: (value) =>
              value.isEmpty ? 'Email can\'t be empty' : null,
              onSaved: (value) => _email = value.trim(),
            ),
          ),
          Container(
            height: 60,
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.lock,
                    color: dashBoardColor,
                  ),
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
              onSaved: (value) => _password = value,
            ),
          ),
          Container(
            height: 60,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.phone_android,
                    color: dashBoardColor,
                  ),
                  hintText: "Phone Number",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              validator: (value) =>
              value.isEmpty ? 'Phone Number can\'t be empty' : null,
              onSaved: (value) => _contactNumber = value.trim(),
            ),
          ),
          Container(
            height: 60,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.perm_identity,
                    color: dashBoardColor,
                  ),
                  hintText: "Enter your National Id",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              onSaved: (value) => _nationalId = value.trim(),
              validator:(value){
               if(value.isEmpty ) return 'National Id can\'t be empty' ;
                if(value.length != 14 ) return 'enter correct National Id' ;
                return null ;
              }
              ,
            ),

          ),
          Container(
            height: 60,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: dashBoardColor),
                  ),
                  icon: Icon(
                    Icons.add_location,
                    color: dashBoardColor,
                  ),
                  hintText: "Your Address",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0)),
              onSaved: (value) => _residentialAddress = value.trim(),
            ),
          ),
          Container(
            height: 60,
            child: DropdownButtonFormField<String>(
              items: <String>['supervisor', 'Manager', 'worker']
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
              onChanged: employeeTypeChange,
              value: _employeeType,
              hint: Text("enter your job type"),
              validator: (value) =>
              value.isEmpty ? 'job type can\'t be empty' : null,
            ),
          ),
          Container(
            height: 60,
            child: DropdownButtonFormField<String>(
              items: _roleValues.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
              onChanged: employeeRoleChange,
              value: _role,
              hint: Text("Enter Your Job Role"),
              validator: (value) =>
              _employeeType == "worker" ? (value.isEmpty
                  ? 'Job Role can\'t be empty'
                  : null) : null,
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
    );
  }

  void employeeTypeChange(String value) {
    setState(() {
      _employeeType = value;
      if (value == 'worker') {
        _roleValues = ['Cooling agent', 'Mechanic', 'electrician'];
      } else {
        _roleValues = [];
        _role = null;
      }
    });
  }

  void employeeRoleChange(String value) {
    setState(() {
      _role = value;
    });
  }
}
