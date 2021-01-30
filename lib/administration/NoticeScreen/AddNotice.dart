import 'dart:convert';

import 'package:MyDen/administration/EventsScreen/EventsScreen.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/event.dart';
import 'package:MyDen/model/notice.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class AddNotice extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<AddNotice> {

  bool isLoading = false;


  TextEditingController _noticeController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();




  Future<Null> _selectDate(
      BuildContext context, DateTime firstDate, DateTime lastDate) async {
    DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      selectedDate = picked;
    String _formattedate =
    new DateFormat(global.dateFormat).format(selectedDate);
    setState(() {
      _startDateController.value = TextEditingValue(text: _formattedate);
    });
  }

  Future<Null> _selectEndDate(
      BuildContext context, DateTime firstDate, DateTime lastDate) async {
    DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      selectedDate = picked;
    String _formattedate =
    new DateFormat(global.dateFormat).format(selectedDate);
    setState(() {
      _endDateController.value = TextEditingValue(text: _formattedate);
    });
  }


  SaveInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Notice notice = Notice(
        noticeId: Uuid().v1(),
        noticeHeading: _noticeController.text,
        startDate: DateFormat(global.dateFormat).parse(_startDateController.text),
        endDate: DateFormat(global.dateFormat).parse(_endDateController.text),
        description: _descriptionController.text,
        enable: true,
      );
      print(notice.toJson());

      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Notice")
          .document(notice.noticeId)
          .setData(jsonDecode(jsonEncode(notice.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        _showDialog();
        senNotificationToResidents();
        _startDateController.clear();
        _descriptionController.clear();
        _endDateController.clear();
        _noticeController.clear();
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Notice',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: [
        Positioned(
          bottom: -MediaQuery.of(context).size.height * .100,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainerThree(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Form(
                  key: global.formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Notice Heading",
                          "Society Notice",
                          validationKey.name,
                          _noticeController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.emailAddress,false),
                      SizedBox(
                        height: 10,
                      ),

                      constantTextField().InputField(
                          "Description",
                          "Enter description here",
                          validationKey.Description,
                          _descriptionController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down),
                            onPressed: () {},
                          ),
                          5,1,TextInputType.emailAddress,false),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () => _selectDate(
                            context,
                            DateTime.now().subtract(Duration(days: 0)),
                            DateTime.now().add(Duration(days: 365))
                        ),
                        child: IgnorePointer(
                          child: constantTextField().InputField(
                              "Start Date",
                              "20 - 12 - 2020",
                              validationKey.date,
                              _startDateController,
                              true,
                              IconButton(
                                onPressed: () {
                                  _selectDate(
                                      context,
                                      DateTime.now()
                                          .subtract(Duration(days: 0)),
                                      DateTime.now().add(Duration(days: 365)));
                                },
                                icon: Icon(Icons.calendar_today),
                              ),
                              1,1,TextInputType.emailAddress,false
                            //Icon(Icons.calendar_today)

                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () => _selectEndDate(
                            context,
                            DateTime.now().subtract(Duration(days: 0)),
                            DateTime.now().add(Duration(days: 365))),
                        child: IgnorePointer(
                          child: constantTextField().InputField(
                              "End Date",
                              "20 - 12 - 2020",
                              validationKey.date,
                              _endDateController,
                              true,
                              IconButton(
                                onPressed: () {
                                },
                                icon: Icon(Icons.calendar_today),
                              ),
                              1,1,TextInputType.emailAddress,false
                            //Icon(Icons.calendar_today)

                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 2,
                ),
                GestureDetector(
                    onTap: () {
                      SaveInformation();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add Notice",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ])
            ],
          ),
        ),
      ]),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(top: 25),
        child: Row(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back_ios,
                    color: UniversalVariables.background),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Add Notice',
                    style: TextStyle(
                        color: UniversalVariables.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Notice is Added ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  senNotificationToResidents(){
    Firestore.instance.collection("Society").document(global.societyId).collection("HouseDevices").getDocuments().then((value) {
      value.documents.forEach((element) {
        sendNotification(element["token"],  _noticeController.text, );

      });
    });
  }

  static Future<void> sendNotification(receiver, msg,) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';


    final data = {
      "notification": {"body": msg, "title": "Notice"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "screen":"Notices",
        "name":"hhhhh"

      },
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
