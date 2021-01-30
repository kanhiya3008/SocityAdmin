import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/polls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:uuid/uuid.dart';

class addPolles extends StatefulWidget {
  @override
  _addPollesState createState() => _addPollesState();
}

class _addPollesState extends State<addPolles> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _options = TextEditingController();
  TextEditingController _PollController = TextEditingController();
  bool isLoading = false;

  final formKeyoption = GlobalKey<FormState>();
  DateTime getSelectedStartDate = DateTime.now();



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
    if (picked != null) selectedDate = picked;
    String _formattedate =
        new DateFormat(global.dateFormat).format(selectedDate);

    setState(() {
      _endDateController.value = TextEditingValue(text: _formattedate);
    });
  }

 // List<Map<String, dynamic>> _allOptions = [];
  List<String> _allOptions = [];


  void _addTodoItem() {
    setState(() {
      _allOptions.add(_options.text);
    });
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return ListView.builder(
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < _allOptions.length) {
          return _buildTodoItem(_allOptions[index],index);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(String todoText,int index) {
    return new ListTile(title:
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Container(

        child: Text(todoText,style: TextStyle(color: Colors.black),overflow: TextOverflow.ellipsis,maxLines: 2,),),

        RaisedButton(onPressed: (){
          _allOptions.removeAt(index);
          setState(() {
            _buildTodoList();
          });
        },
       child: Text("Delete"),
      )

    ],)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        body: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(10)),
                  color: UniversalVariables.background,
                  boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black)]),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width / 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: ListView(
              children: [
                Row(
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
                                  " Add Polls",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
               SizedBox(height: 5,),
               Form(
                 key: formKeyoption,
                 child: Column(
                   children: [
                     Row(
                       children: [
                         Text(" Start Date"),
                         SizedBox(
                           width: 20,
                         ),
                         Expanded(
                           child: InkWell(
                             onTap: () => _selectDate(
                                 context,
                                 DateTime.now().subtract(Duration(days: 0)),
                                 DateTime.now().add(Duration(days: 365))),
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
                         )
                       ],
                     ),
                     SizedBox(
                       height: 10,
                     ),
                     Row(
                       children: [
                         Text(" End Date  "),
                         SizedBox(
                           width: 20,
                         ),
                         Expanded(
                           child: InkWell(
                             onTap: () => {
                               _selectEndDate(
                                   context,
                                   DateTime.now().subtract(Duration(days: 0)),
                                   DateTime.now().add(Duration(days: 365)),

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
                                     onPressed: () {},
                                     icon: Icon(Icons.calendar_today),
                                   ),
                                   1,1,
                                   TextInputType.emailAddress,false),
                             ),
                           ),
                         )
                       ],
                     ),
                     SizedBox(
                       height: 10,
                     ),
                     constantTextField().InputField(
                         "Please enter the topic for the poll",
                         "Please enter the topic for the poll",
                         validationKey.date,
                         _PollController,
                         false,
                         IconButton(
                           onPressed: () {},
                           icon: Icon(Icons.calendar_today),
                         ),
                         5,1,
                         TextInputType.emailAddress,false),
                   ],
                 ),
               ),

                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Form(
                          key: global.formKey,
                         child: constantTextField().InputField(
                          "Enter your option",
                          "yes/No",
                          validationKey.option,
                          _options,
                          false,
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.calendar_today),
                          ),
                          1,1,
                          TextInputType.emailAddress,false),
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (global.formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          if(_allOptions.length < 8 ){
                            _addTodoItem();
                          } else{
                            showScaffold("You Can't add more then 8 option");
                          }

                          _options.clear();
                        }
                      }, tooltip: 'Add task',

                      child: Text("Add"),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                    child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Column(
                    children: [
                      Container(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Text(
                              'Options',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                      )),
                      _buildTodoList(),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  onPressed: () {
                    SaveInformation();
                  },
                  child: Text("Publish Poll"),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  SaveInformation() async {
    print(_allOptions);
    if (formKeyoption.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      // Poll _pollModel = Poll(
      //     options: _options.text,
      //     ans: ""
      // );
      // List<Poll> MCQ = [];
      // MCQ.add(_pollModel);
      // PollsModel _pollsModel = PollsModel(
      //     polls: MCQ
      // );
      if(  _allOptions.length > 0 ){
        Polls polls = Polls(
            pollsId: Uuid().v1(),
            pollName: _PollController.text,
            startDate: DateFormat(global.dateFormat).parse(_startDateController.text),
            enable: true,
            endDate: DateFormat(global.dateFormat).parse(_endDateController.text),
            options: _allOptions
        );

        await Firestore.instance
            .collection('Society')
            .document(global.societyId)
            .collection("Polls")
            .document(polls.pollsId)
            .setData(jsonDecode(jsonEncode(polls.toJson())))
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          _showDialog();
          votePoll(polls.pollsId);
          //  Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            isLoading = false;
          });

          print(err.toString());
          Fluttertoast.showToast(msg: err.toString());
        });
      }else{
        showScaffold("Choose poll options");
      }

    }
  }

  votePoll(String poolId){
    print("sssss");
    print(global.societyId);
    print(poolId);
    Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Polls")
        .document(poolId)
        .collection("ResidentPolls").document().setData({"VoteAns":""});

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
                  "Added Successfully ",
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


}
