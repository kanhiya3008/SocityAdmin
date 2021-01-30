import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/event.dart';
import 'package:MyDen/model/sharedperef.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;


class EditEventData extends StatefulWidget {
  final Event event;

  const EditEventData({Key key, this.event}) : super(key: key);

  @override
  _EditEventDataState createState() => _EditEventDataState();
}

class _EditEventDataState extends State<EditEventData> {
  final formKey = GlobalKey<FormState>();

  DateTime getSelectedStartDate =  DateTime.now();
  TextEditingController _eventController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _eventTimingsController = TextEditingController();
  TextEditingController _eventFeesController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;
  @override
  void initState() {

      read();
  }

  void read() {
    _eventController = TextEditingController(text: widget.event.eventName);
    _venueController = TextEditingController(text: widget.event.venue);
    _startDateController = TextEditingController(text: DateFormat(global.dateFormat).format(widget.event.startDate));
    _endDateController = TextEditingController(
        text: DateFormat(global.dateFormat).format(widget.event.endDate));
    _eventTimingsController =
        TextEditingController(text: widget.event.eventTiming);
    _eventFeesController = TextEditingController(text: widget.event.eventFee);
    _descriptionController =
        TextEditingController(text: widget.event.description);
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


        String formatDate =
        new DateFormat(global.dateFormat).format(picked);
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

        String formatDate =
        new DateFormat(global.dateFormat).format(picked);
        _endDateController.value = TextEditingValue(text: formatDate);
      });
  }






  updateInformation() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Event event = Event(
       eventId: widget.event.eventId,
        eventName: _eventController.text,
        venue: _venueController.text,
        startDate: DateFormat(global.dateFormat).parse(_startDateController.text),
        endDate: DateFormat(global.dateFormat).parse(_endDateController.text),
        eventTiming: _eventTimingsController.text,
        eventFee: _eventFeesController.text,
        description: _descriptionController.text,
        enable: true,
      );
      print(event.toJson());
      print(jsonEncode(event.toJson()));
      print(jsonDecode(jsonEncode(event.toJson())));
      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Events")
          .document(widget.event.eventId)
          .updateData(jsonDecode(jsonEncode(event.toJson())))
          .then((data) async {
         setState(() {
          isLoading = false;
        });
         _showDialog();
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        print(err.toString());
        Fluttertoast.showToast(msg: err.toString());
      });
    }
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
                  "Update Success ",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
                          IconButton(icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Venue",
                          "Club House",
                          validationKey.name,
                          _venueController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
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
                                onPressed: ()
                                {},
                                icon: Icon(Icons.calendar_today),
                              ),
                              1,1,TextInputType.name,false
                              //Icon(Icons.calendar_today)

                              ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () =>   {

                              _selectEndDate(
                                  context,
                                  DateTime.now().subtract(Duration(days: 365)),
                                  DateTime.now(),
                                  DateTime.now())


                        },
                          child: IgnorePointer(
                          child: constantTextField().InputField(
                              "End Dater",
                              "31 - 12 - 2020",
                              validationKey.date,
                              _endDateController,
                              true,
                              IconButton(
                                onPressed: ()
                               {},
                                icon: Icon(Icons.calendar_today),
                              ),
                              1,1,TextInputType.name,false),
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
                      updateInformation();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Update Event",
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


}
