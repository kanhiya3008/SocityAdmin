import 'dart:convert';
import 'dart:ui';

import 'package:MyDen/administration/EventsScreen/EventsScreen.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/event.dart';
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

class AddEvents extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  DateTime getSelectedStartDate = DateTime.now();
  var items = ['Club House', 'Society', 'RWA Members'];


  TextEditingController _eventController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _eventTimingsController = TextEditingController();
  TextEditingController _eventFeesController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
      read();
    super.initState();
  }

  void read() {
    _venueController = TextEditingController(text: dropdownValue);
  }

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
    String _formattedate = new DateFormat(global.dateFormat).format(selectedDate);
    getSelectedStartDate = selectedDate;

    setState(() {
      _startDateController.value = TextEditingValue(text: _formattedate);
    });
  }

  Future<Null> _selectEndDate(
      BuildContext context, DateTime firstDate, DateTime lastDate, DateTime selectedDate) async {

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: getSelectedStartDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      selectedDate = picked;
    String _formattedate =
    new DateFormat(global.dateFormat).format(selectedDate);
    setState(() {
      _endDateController.value = TextEditingValue(text: _formattedate);
    });
  }


  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  SaveInformation() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Event event = Event(
        eventId: Uuid().v1(),
        eventName: _eventController.text,
        venue: _venueController.text,
        startDate:
            DateFormat(global.dateFormat).parse(_startDateController.text),
        endDate: DateFormat(global.dateFormat).parse(_endDateController.text),
        eventTiming: _eventTimingsController.text,
        eventFee: _eventFeesController.text,
        description: _descriptionController.text,
        enable: true,
      );
      print(event.toJson());

      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Events")
          .document(event.eventId)
          .setData(jsonDecode(jsonEncode(event.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        _showDialog();
        senNotificationToResidents();
        _eventController.clear();
        _endDateController.clear();
        _startDateController.clear();
        _descriptionController.clear();
        //  Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }
  }

  List<String> options = <String>[
    'Club ouse',
    'Society',
    'RWA Members',
  ];
  String dropdownValue = 'Club House';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Events',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter Event Name",
                          "Durga Pooja",
                          validationKey.name,
                          _eventController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      Stack(children: [
                        constantTextField().InputField(
                            "Venue",
                            "Club House",
                            validationKey.venue,
                            _venueController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: () {},
                            ),
                            1,1,TextInputType.name,false),
                        Positioned(
                          right: 0,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_downward),
                              onSelected: (String val) {
                                _venueController.text = val;
                              },
                              itemBuilder: (BuildContext context) {
                                return items
                                    .map<PopupMenuItem<String>>((String val) {
                                  return new PopupMenuItem(
                                      child: new Text(val), value: val);
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ]),
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
                                onPressed: () {},
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
                        onTap: () => {

                              _selectEndDate(
                                  context,
                                  DateTime.now().subtract(Duration(days: 365)),
                                  DateTime.now().add(Duration(days: 31)),
                                  DateTime.now()

                              ),


                        },
                        child: IgnorePointer(
                          child: constantTextField().InputField(
                              "End Date",
                              "20 - 12 - 2020",
                              validationKey.date,
                              _endDateController,
                              true,
                              IconButton(
                                onPressed: () {
                                  // //  _selectEndDate(
                                  //       context,
                                  //       DateTime.now()
                                  //           .subtract(Duration(days: 0)),
                                  //       DateTime.now().add(Duration(days: 365)));
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
                        onTap: () {
                          showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: DateTime.now().hour,
                                  minute: DateTime.now().minute)).then((TimeOfDay value ) {

                            if(value != null){
                              _eventTimingsController.text = value.format(context);
                            }
                          });
                        },
                        child:IgnorePointer(
                          child:  constantTextField().InputField(
                              "Event Timing",
                              "6:00 am to 9:00 am ",
                              validationKey.time,
                              _eventTimingsController,
                              true,
                              IconButton(
                                icon: Icon(Icons.access_time),
                              ),
                              1,1,TextInputType.emailAddress,false),
                        )
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "End Fees",
                          "Free/ 50",
                          validationKey.payment,
                          _eventFeesController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.number,false),
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
                          5,1,TextInputType.name,false),
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
                            "Add Event",
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



  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Event is Added ",
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
        sendNotification(element["token"],  _eventController.text, );

      });
    });
  }

  static Future<void> sendNotification(receiver, msg,) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';


    final data = {
      "notification": {"body": msg, "title": "Events"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "screen":"Events",
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
