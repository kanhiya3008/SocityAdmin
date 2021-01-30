import 'dart:convert';
import 'dart:core';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/OTP.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/ActivationModel.dart';
import 'package:MyDen/model/gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class addGate extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<addGate> {

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

  bool isLoading = false;

  TextEditingController _gateNoController = TextEditingController();
  TextEditingController _gateOpenController = TextEditingController();
  TextEditingController _gateOperationController = TextEditingController();
  TextEditingController _entranceModeController = TextEditingController();
  TextEditingController _noOfDevicesController = TextEditingController();
  TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
      read();
    super.initState();
  }

  void read(){
    _gateOpenController = TextEditingController(text: dropdownOpen);
    _gateOperationController  = TextEditingController (text: dropdownOperation);
  }



  SaveInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Gate gate = Gate(
          gateId: global.uuid,
          gateOpen: _gateOpenController.text,
          gateNo: _gateNoController.text,
          gateEntranceMode: _entranceModeController.text,
          gateOperation: _gateOperationController.text,
          enable: true,
          tokenNo: _tokenController.text,
          noOfDevice: _noOfDevicesController.text);
      print(gate.toJson());
      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Gate")
          .document(gate.gateId)
          .setData(jsonDecode(jsonEncode(gate.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        _showDialog();
        //  Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }
  }

  SaveActivation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      ActivationCode activationCode = ActivationCode(
          iD: global.uuid,
          type: "Gate",
          society: global.societyId,
          creationDate:DateTime.now(),
          societyId: _tokenController.text,
          enable: true
      );


      await Firestore.instance
          .collection('ActivationCode')
          .document(activationCode.iD)
          .setData(jsonDecode(jsonEncode(activationCode.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
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
        title: Text('Add Gate Details',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
                          child: constantTextField().InputField(
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
                          child: constantTextField().InputField(
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

                      _tokenController.text = RandomString(10);
                      global.uuid = Uuid().v1();
                      SaveInformation();
                      SaveActivation();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add Gate",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ]),
              
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
                  "Gate is Added ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('share Code'),
              onPressed: () async {
                var response = await FlutterShareMe().shareToSystem(msg: global.RWATokenMsg + _tokenController.text,);
                if (response == 'success') {
                  print('navigate success');
                }
                setState(() {
                  isLoading = false;
                });
                Navigator.pop(context);
              },

            ),
          ],
        );
      },
    );
  }
}
