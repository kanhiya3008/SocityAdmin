import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';

import 'package:MyDen/model/notice.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:uuid/uuid.dart';

class EditNoticeData extends StatefulWidget {
  final Notice notice;

  const EditNoticeData({Key key, this.notice}) : super(key: key);

  @override
  _EditEventDataState createState() => _EditEventDataState();
}

class _EditEventDataState extends State<EditNoticeData> {
  TextEditingController _noticeController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
   super.initState();

      read();
  }

  void read() {
    _noticeController = TextEditingController(text: widget.notice.noticeHeading);
    _startDateController = TextEditingController(text: DateFormat(global.dateFormat).format(widget.notice.startDate));
    _endDateController = TextEditingController(text: DateFormat(global.dateFormat).format(widget.notice.endDate));
    _descriptionController = TextEditingController(text: widget.notice.description);
  }


  Future<Null> _selectDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    //DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String _formattedate =
        new DateFormat(global.dateFormat).format(selectedDate);
        _startDateController.value = TextEditingValue(text: _formattedate);
      });
  }

  Future<Null> _selectEndDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    //DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String _formattedate =
        new DateFormat(global.dateFormat).format(selectedDate);
        _endDateController.value = TextEditingValue(text: _formattedate);
      });
  }
  bool isLoading = false;




  updateInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Notice notice = Notice(
        noticeId: widget.notice.noticeId,
        noticeHeading: _noticeController.text,
        startDate: DateFormat(global.dateFormat).parse(_startDateController.text),
        endDate: DateFormat(global.dateFormat).parse(_endDateController.text),
        description: _descriptionController.text,
        enable: true,
      );

      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Notice")
          .document(widget.notice.noticeId)
          .updateData(jsonDecode(jsonEncode(notice.toJson())))
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
        title: Text('Edit Notice',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
                          "Enter Event Name",
                          "Durga Pooja",
                          validationKey.name,
                          _noticeController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.name,false),
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
                      InkWell(
                        onTap: () => _selectDate(
                            context,
                            DateTime.now().subtract(Duration(days: 0)),
                            DateTime.now().add(Duration(days: 365)),
                            widget.notice.endDate),
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
                                      DateTime.now().add(Duration(days: 365)),
                                      widget.notice.startDate);
                                },
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
                        onTap: () => _selectEndDate(
                            context,
                            DateTime.now().subtract(Duration(days: 0)),
                            DateTime.now().add(Duration(days: 365)),
                            widget.notice.endDate),
                        child: IgnorePointer(
                          child: constantTextField().InputField(
                              "End Dater",
                              "31 - 12 - 2020",
                              validationKey.date,
                              _endDateController,
                              true,
                              IconButton(
                                onPressed: () {
                                  _selectEndDate(
                                      context,
                                      DateTime.now()
                                          .subtract(Duration(days: 0)),
                                      DateTime.now().add(Duration(days: 365)),
                                      widget.notice.endDate);
                                },
                                icon: Icon(Icons.calendar_today),
                              ),
                              1,1,TextInputType.name,false),
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                      updateInformation();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Update Notice",
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
