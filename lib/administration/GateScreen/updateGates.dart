import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/gate.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MyDen/constants/global.dart' as global;

class updateGateData extends StatefulWidget {
  final Gate gate;
  const updateGateData({Key key, this.gate}) : super(key: key);

  @override
  _EditEventDataState createState() => _EditEventDataState();
}

class _EditEventDataState extends State<updateGateData> {

  var gateOpen = [
    'Close',
    'Open',
  ];
  var gateOperation = [
    'Walking',
    'Vehicle',
  ];
  String dropdownOpen = "Open";
  String dropdownOperation = "Walking";

  TextEditingController _gateNoController = TextEditingController();
  TextEditingController _gateOpenController = TextEditingController();
  TextEditingController _gateOperationController = TextEditingController();
  TextEditingController _entranceModeController = TextEditingController();
  TextEditingController _noOfDevicesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    read();
  }

  void read() {
    _gateOpenController = TextEditingController(text: widget.gate.gateOpen);
    _gateOperationController = TextEditingController(text:widget.gate.gateOperation);
    _gateNoController = TextEditingController(text:widget.gate.gateNo);
    _entranceModeController = TextEditingController(text: widget.gate.gateEntranceMode);
    _noOfDevicesController = TextEditingController(text: widget.gate.noOfDevice);
  }








  bool isLoading = false;




  updateInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Gate gate = Gate(
        gateId: widget.gate.gateId,
        gateOpen: _gateOpenController.text,
        gateOperation:_gateOperationController.text,
        gateNo: _gateNoController.text,
        gateEntranceMode: _entranceModeController.text,
        noOfDevice: _noOfDevicesController.text,
        enable: true,
        tokenNo: widget.gate.tokenNo
      );

      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Gate")
          .document(widget.gate.gateId)
          .updateData(jsonDecode(jsonEncode(gate.toJson())))
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
        title: Text('Edit Gates',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
                          "Gate Name / No",
                          "67",
                          validationKey.gateNo,
                          _gateNoController,
                          false,
                          IconButton(
                            icon: Icon(Icons.access_time),
                          ),
                          1,1,TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      Stack(children: [
                      IgnorePointer(
                        child:     constantTextField().InputField(
                            "Gate Open ",
                            "Open",
                            validationKey.name,
                            _gateOpenController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: () {},
                            ),
                            1,1,TextInputType.name,false),
                      ),
                        Positioned(
                          right: 0,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_downward),
                              onSelected: (String val) {
                                _gateOpenController.text = val;
                              },
                              itemBuilder: (BuildContext context) {
                                return gateOpen
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
                      Stack(children: [
                       IgnorePointer(
                         child:  constantTextField().InputField(
                             "Gate Operation",
                             "Walking / Vech.",
                             validationKey.name,
                             _gateOperationController,
                             false,
                             IconButton(
                               onPressed: () {},
                               icon: Icon(Icons.calendar_today),
                             ),
                             1,1,TextInputType.name,false),
                       ),
                        Positioned(
                            right: 0,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_downward),
                                onSelected: (String val) {
                                  _gateOperationController.text = val;
                                },
                                itemBuilder: (BuildContext context) {
                                  return gateOperation
                                      .map<PopupMenuItem<String>>((String val) {
                                    return new PopupMenuItem(
                                        child: new Text(val), value: val);
                                  }).toList();
                                },
                              ),
                            ))
                      ]),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Entrance Mode",
                          "",
                          validationKey.entrance,
                          _entranceModeController,
                          false,
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.calendar_today),
                          ),
                          1,1,TextInputType.name,false
                        //Icon(Icons.calendar_today)

                      ),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "No. of Devices ",
                          "",
                          validationKey.device,
                          _noOfDevicesController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down),
                            onPressed: () {},
                          ),
                          1,1,TextInputType.number,false),
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
                            "Update ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ])
            ],
          ),
        ),
        Positioned(
          child: isLoading
              ? Container(
            color: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Container(),
        ),
      ]),
    );
  }

  Widget _backButton() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 30, right: 20, bottom: 5),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back_ios,
                    color: UniversalVariables.background),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Update Gate Details',
                    style: TextStyle(
                        color: UniversalVariables.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                isLoading = false;
              });
              Navigator.pop(context);
            },
            child: Text('History',
                style: TextStyle(
                    color: UniversalVariables.background,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
