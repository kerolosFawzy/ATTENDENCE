import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geo_attendance_system/src/models/AttendaceList.dart';
import 'package:geo_attendance_system/src/models/user.dart';
import 'package:geo_attendance_system/src/services/database.dart';
import 'package:geo_attendance_system/src/services/fetch_attendance.dart';
import 'package:geo_attendance_system/src/ui/constants/colors.dart';
import 'package:geo_attendance_system/src/ui/widgets/Info_dialog_box.dart';
import 'package:geo_attendance_system/src/ui/widgets/loader_dialog.dart';

import 'leave_application.dart';

class EmployeeAttendance extends StatefulWidget {
  EmployeeAttendance({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final FirebaseUser user;

  @override
  _EmployeeAttendance createState() => new _EmployeeAttendance();
}

class _EmployeeAttendance extends State<EmployeeAttendance> {
  String _fromdate = "Select";
  DateTime _fromDateInt;
  String _todate = "Select";
  DateTime _toDateInt;
  Map<dynamic, dynamic> list = new Map();
  List<Map> newList = new List<Map>();

  var date = DateTime.now();
  static final _databaseReference = DataBase().databaseRef;

  String leavesCount = "-";

  @override
  void initState() {
    super.initState();
  }

  void fetchAttendanceList() async {
    await getAttendance().then((value) {
      setState(() {
        list != null ? list.clear() : true;
        list = value.value;
      });
    });

    await list.forEach((key, user) async {
      Employee emp = await DataBase().getUserData(key);
      setState(() {
        list[emp.fullName.toString()] = user;
        list.remove(key);
      });

      Map<dynamic, dynamic> map = user;
      Map<dynamic, dynamic> newMap = new Map();

      map.forEach((key, user) {
        String d = key.toString().split("-").reversed.join();

        DateTime date = DateTime.tryParse(d);
        if (!(_fromDateInt.isAfter(date) || _toDateInt.isBefore(date))) {
          newMap[key] = user;
        }
      });

      String newKey = emp.fullName.toString();
      if (newMap != null && newMap.isNotEmpty) {
        list.update(newKey, (value) => newMap);
      } else
        list.remove(newKey);
    });
  }


  Future<DataSnapshot> getAttendance() async {
    DataSnapshot dataSnapshot =
        await _databaseReference.child("Attendance").once();
    return dataSnapshot;
  }

  void showList() {
    print(list);
  }

  String getDoubleDigit(String value) {
    if (value.length >= 2) return value;
    return "0" + value;
  }

  String getFormattedDate(DateTime day) {
    String formattedDate = getDoubleDigit(day.day.toString()) +
        "-" +
        getDoubleDigit(day.month.toString()) +
        "-" +
        getDoubleDigit(day.year.toString());
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: appbarcolor,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Employees Attendance",
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('From'),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      elevation: 4.0,
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            theme: DatePickerTheme(
                              containerHeight: 250.0,
                            ),
                            showTitleActions: true,
                            minTime: DateTime(2020, 6, 1),
                            maxTime: DateTime(date.year, date.month, date.day),
                            onConfirm: (date) {
                          print('confirm $date');
                          _fromdate = getFormattedDate(date);
                          setState(() {
                            _fromDateInt = date;

                            if (_todate != null && _todate != "Select") {
                              setState(() {

                                int _difference =
                                    _toDateInt.difference(_fromDateInt).inDays;
                                _difference += 1;
                                if (_difference <= 0 || _toDateInt.isBefore(_fromDateInt))
                                  showDialogTemplate(
                                      context,
                                      "Mistake",
                                      "you Entered Invalid date",
                                      "assets/gif/no_entry.gif",
                                      Color.fromRGBO(51, 205, 187, 1.0),
                                      "Try Again");
                                else
                                  leavesCount = _difference.toString();
                              });
                              fetchAttendanceList();
                              showList();
                            }
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "$_fromdate",
                                        style: TextStyle(
                                          color: dashBoardColor,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )),
              ),
              Text('To'),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      elevation: 4.0,
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            theme: DatePickerTheme(
                              containerHeight: 250.0,
                            ),
                            showTitleActions: true,
                            minTime: DateTime(2020, 6, 1),
                            maxTime: DateTime(date.year, date.month, date.day),
                            onConfirm: (date) {
                          print('confirm $date');
                          _todate = getFormattedDate(date);
                          setState(() {
                            _toDateInt = date;

                            if (_fromDateInt != null) {
                              setState(() {
                                int _difference =
                                    _toDateInt.difference(_fromDateInt).inDays;
                                _difference += 1;
                                if (_difference <= 0 || _fromDateInt.isAfter(_toDateInt))
                                  showDialogTemplate(
                                      context,
                                      "Mistake",
                                      "you Entered Invalid date",
                                      "assets/gif/no_entry.gif",
                                      Color.fromRGBO(51, 205, 187, 1.0),
                                      "Try Again");
                                else
                                  leavesCount = _difference.toString();
                              });
                              fetchAttendanceList();
                              showList();
                            }
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "$_todate",
                                        style: TextStyle(
                                            color: dashBoardColor,
                                            fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          ),
          Divider(color: Colors.black),
          list != null
              ? list.isNotEmpty
                  ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only( bottom: 20.0),
                      child: new ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String key = list.keys.elementAt(index);
                          Map secondMap = list[key];
                          return (new Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top:12.0),
                                child: new Center(
                                  child: Text(
                                    "$key",
                                    style: TextStyle(
                                        fontFamily: "Poppins-Bold",
                                        color: appbarcolor,
                                        fontSize: 20,
                                        letterSpacing: .6,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              new ListView.builder(
                                shrinkWrap: true,
                                itemCount: secondMap.length,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  String key2 = secondMap.keys.elementAt(index);
                                  Map lastMap = secondMap[key2];
                                  return Column(textDirection: TextDirection.ltr,
                                    children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromRGBO(29, 209, 161, 1.0),
                                      ),
                                      height: 46 ,
                                      width: 126 ,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12.0 , top: 12.0 , bottom: 10.0),
                                        child: Text(
                                          key2,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 18,
                                            letterSpacing: .6,
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Colors.red[600]
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: lastMap.length,
                                      itemBuilder: (context, index) {
                                        String key3 = lastMap.keys.elementAt(index);
                                        String state , time , place ;
                                        state = key3.split("-").first;
                                        time = key3.split("-").last;
                                        place = lastMap.values.elementAt(index)["office"];
                                        return(
                                           Padding(
                                             padding: const EdgeInsets.only(left: 16.0 , top: 10.0),
                                             child: Text(
                                               "Signed $state At $time in $place",
                                               style: TextStyle(
                                                 fontSize: 16,
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             ),
                                           )
                                        );
                                      },
                                    )
                                  ],);
                                },
                              ),
                            ],
                          ));
                        },
                      ),
                    ),
                  )
                  : new Text("there No record for this date ")
              : new Text("Nothing to show Yet"),
        ],
      ),
    );
  }
}
