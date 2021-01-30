import 'dart:convert';

import 'package:MyDen/administration/Alerts/alertsHistory.dart';
import 'package:MyDen/administration/Alerts/todayAlert.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/AlertsModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _alertController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime getSelectedStartDate = DateTime.now();

  final formKey = GlobalKey<FormState>();
  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
  bool isCheckedHouse = false;
  bool isCheckedadmin = false;
  bool isLoading = false;
  var selectedIndex = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        key: _scaffoldKey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(10)),
                      color: UniversalVariables.background,
                      boxShadow: [
                        BoxShadow(blurRadius: 7.0, color: Colors.black)
                      ]),
                  height: MediaQuery.of(context).size.height / 1.1,
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Card(
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back_ios),
                                    Text(
                                      " Emergency Alerts",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        RaisedButton(
                          elevation: 10,
                          onPressed: () {
                            _alertHistory();
                          },
                          child: Text('Check History'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RaisedButton(
                          elevation: 10,
                          onPressed: () {
                            Navigator.push(context, CupertinoPageRoute(builder: (context)=> newAlert()));
                          },
                          child: Text('Check Today Emergency'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Card(
                      elevation: 10,
                      color: Colors.red,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Alert Society security, admin & all your added members"
                          " via typed message in one go. This message will go to them all as"
                          " Emergency Alerts use it carefully",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: UniversalVariables.ScaffoldColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Alert Type",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _alertCategory.length,
                        itemBuilder: (BuildContext context, int index) => Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });

                                    _alertController.text =
                                        _alertCategory[index]['name'];
                                    print(_alertController.text);
                                  },
                                  child: Card(
                                      child: Stack(
                                    children: [
                                      Column(children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Container(
                                          child: Image.network(
                                            _alertCategory[index]["image"],
                                            fit: BoxFit.cover,
                                            height: 60,
                                            width: 70,
                                          ),
                                        ),
                                        Expanded(
                                            child: Center(
                                                child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            _alertCategory[index]['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                        ))),
                                      ]),
                                      Positioned(
                                        right: 0,
                                        child: Icon(
                                          Icons.check,
                                          color:
                                              UniversalVariables.nearlyDarkBlue,
                                          size: selectedIndex == index ? 30 : 0,
                                        ),
                                      ),
                                    ],
                                  )),
                                )),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Your Message",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(hintText: "(Optional)"),
                      controller: _descriptionController,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Send this Emergency Message to",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: UniversalVariables.background,
                          value: isCheckedHouse,
                          onChanged: (value) {
                            setState(() {
                              isCheckedHouse = value;
                            });
                          },
                        ),
                        Text("House Members"),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: UniversalVariables.background,
                          value: isCheckedadmin,
                          onChanged: (value) {
                            setState(() {
                              isCheckedadmin = value;
                            });
                          },
                        ),
                        Text("Society security and admin"),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          color: UniversalVariables.background,
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.only(right: 50, left: 50),
                            child: Text("Submit"),
                          ),
                          onPressed: () {
                            SaveInformation();
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  List<Map<String, dynamic>> _alertCategory = [
    {
      'name': 'Stuck in Lift',
      'image':
          "https://cdn.iconscout.com/icon/premium/png-128-thumb/stuck-in-lift-1560887-1322669.png"
    },
    {
      'name': "Fire",
      'image':
          "https://cdn.iconscout.com/icon/premium/png-256-thumb/fire-2096406-1767058.png"
    },
    {
      'name': 'Medical Emergency',
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSERIuXGm7xJfW4e6v3Neg9HzTNskr6C2d8jA&usqp=CAU"
    },
    {
      'name': "Visitors Threat",
      'image':
          "https://cdn2.iconfinder.com/data/icons/insurance-type-coverage/278/insurance-claim-002-512.png"
    },
    {
      'name': 'Animal Threat',
      'image':
          "https://www.grow-trees.com/images/Biodiversity%20Enhancement.png"
    },
  ];

  SaveInformation() async {
    if ((isCheckedHouse || isCheckedadmin) && selectedIndex != null) {
    } else {
      if (selectedIndex == null) {
        return showScaffold("First Select alert Type msg");
      } else {
        return showScaffold("Select send this emergency message to");
      }
    }

    Alerts alerts = Alerts(
      alertsId: Uuid().v1(),
      alertsHeading: _alertController.text,
      startDate: DateTime.now(),
      description: _descriptionController.text,
      enable: true,
      type: "RWA",
      houseMember: isCheckedHouse,
      securityAdmin: isCheckedadmin,
    );
    await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Alerts")
        .document(alerts.alertsId)
        .setData(jsonDecode(jsonEncode(alerts.toJson())))
        .then((data) async {
      setState(() {
        isLoading = false;
      });
      showScaffold(" Alert message Send Successfully");
      if(isCheckedHouse == true && isCheckedadmin == true){
        senNotificationToResidents();
        senNotificationToRWA();
        senNotificationToGuard();
      } else if (isCheckedadmin == true){
        senNotificationToRWA();
        senNotificationToGuard();
      } else {
        senNotificationToResidents();
      }
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }




  Future<void> _alertHistory() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "First Date",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: InkWell(
                            onTap: () => _selectDate(
                                context,
                                DateTime.now().subtract(Duration(days: 365)),
                                DateTime.now().subtract(Duration(days: 1)),
                                DateTime.now().subtract(Duration(days: 31))),
                            child: IgnorePointer(
                              child: constantTextField().InputField(
                                  "Start Date",
                                  "20 - 12 - 2020",
                                  validationKey.date,
                                  _startDateController,
                                  true,
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.calendar_today),
                                  ),
                                  1,1,
                                  TextInputType.emailAddress,false
                                //Icon(Icons.calendar_today)

                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Last Date",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: InkWell(
                            onTap: () {
                              if (isLoading == true) {
                                _selectEndDate(
                                    context,
                                    DateTime.now()
                                        .subtract(Duration(days: 365)),
                                    DateTime.now(),
                                    DateTime.now());
                              }
                            },
                            child: IgnorePointer(
                              child: constantTextField().InputField(
                                  "End Date",
                                  "20 - 12 - 2020",
                                  validationKey.date,
                                  _endDateController,
                                  true,
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.calendar_today),
                                  ),
                                  1,1,
                                  TextInputType.emailAddress,false),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                updateInformation();
              },
            ),
          ],
        );
      },
    );
  }


  Future<Null> _selectDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null)
      setState(() {
        isLoading = true;
        String formatDate = new DateFormat(global.dateFormat).format(picked);
        getSelectedStartDate = picked;
        _startDateController.value = TextEditingValue(text: formatDate);
      });
  }

  Future<Null> _selectEndDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    print(selectedDate);

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: getSelectedStartDate,
        lastDate: lastDate);
    if (picked != null)
      setState(() {
        isLoading = true;

        String formatDate = new DateFormat(global.dateFormat).format(picked);
        _endDateController.value = TextEditingValue(text: formatDate);
      });
  }


  updateInformation() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => alertsHistory(
                  startDate: _startDateController.text,
                  endDate: _endDateController.text,
                 )));
      });
    }
  }


  senNotificationToRWA(){
    Firestore.instance.collection("Society").document(global.societyId).collection("RWA").getDocuments().then((value) {
      value.documents.forEach((element) {
        sendNotification(element["token"],  _alertController.text, );

      });
    });
  }
  senNotificationToResidents(){
    Firestore.instance.collection("Society").document(global.societyId).collection("HouseDevices").getDocuments().then((value) {
      value.documents.forEach((element) {
        sendNotification(element["token"],  _alertController.text, );

      });
    });
  }
  senNotificationToGuard(){
    Firestore.instance.collection("Society").document(global.societyId).collection("GuardDevices").getDocuments().then((value) {
      value.documents.forEach((element) {
        sendNotification(element["token"],  _alertController.text, );

      });
    });
  }

  static Future<void> sendNotification(receiver, msg,) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "notification": {"body": msg, "title": "Alert"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "screen":"AlertsScreen",
        "name":"hhhhh"

      },
      "actionButtons": [
        {
          "key": "REPLY",
          "label": "Reply",
          "autoCancel": true,
          "buttonType":  "InputField",
        },
        {
          "key": "ARCHIVE",
          "label": "Archive",
          "autoCancel": true
        }
      ],
      "apns": {
        "payload": {
          "aps": {
            "mutable-content": 1
          }
        },
        "fcm_options": {
          "image": "https://aubergestjacques.com/wp-content/uploads/2017/04/check-out-1.png"
        }
      },
      "to": "$receiver"
    };


    final headers = {'content-type': 'application/json', 'Authorization': global.notificationKey};
    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    try {
      final response = await Dio(options).post(postUrl, data: jsonEncode(data));
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Request Sent To HouseMember');
      } else {
        print('notification sending failed');
      }
    } catch (e) {
      print('exception $e');
    }
  }

}
