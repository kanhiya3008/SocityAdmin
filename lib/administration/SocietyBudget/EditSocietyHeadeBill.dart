import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/SocietyBillHeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:uuid/uuid.dart';
class SocietyHeadreBill extends StatefulWidget {
  final SocietyBillHeader societyBillHeader;

  const SocietyHeadreBill({Key key, this.societyBillHeader}) : super(key: key);
  @override
  _SocietyHeadreBillState createState() => _SocietyHeadreBillState();
}

class _SocietyHeadreBillState extends State<SocietyHeadreBill> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController _header = TextEditingController();
  TextEditingController _salaryModeController = TextEditingController();
  TextEditingController paySalaryMode = TextEditingController();
  TextEditingController _sqFitController = TextEditingController();
  TextEditingController _perUnitController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  readData(){
    _header = TextEditingController(text: widget.societyBillHeader.headerName);
    _salaryModeController = TextEditingController(text: widget.societyBillHeader.area);
    paySalaryMode = TextEditingController(text: widget.societyBillHeader.timePeriod);
    _sqFitController = TextEditingController(text: widget.societyBillHeader.sqFit);
    _perUnitController = TextEditingController(text: widget.societyBillHeader.perUnit);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit SocietyBill"),
      ),
      body:Container(
        child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    children: [
                      IgnorePointer(
                        child: constantTextField().InputField(
                            "Select Header",
                            "",
                            validationKey.BillHeader,
                            _header,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_downward),
                            onSelected: (String val) {
                              _header.text = val;
                              setState(() {
                                global.changeValidation =
                                global.documentData[val];
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return global.societyBillHeader
                                  .map<PopupMenuItem<String>>((String val) {
                                return new PopupMenuItem(
                                    child: new Text(val), value: val);
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    children: [
                      IgnorePointer(
                        child: constantTextField().InputField(
                            "Salary Mode",
                            "",
                            validationKey.mode,
                            _salaryModeController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_downward),
                            onSelected: (String val) {

                              setState(() {
                                _salaryModeController.text = val;
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return global.salaryMode
                                  .map<PopupMenuItem<String>>((String val) {
                                return new PopupMenuItem(
                                    child: new Text(val), value: val);
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _salaryModeController.text == "Sq.fit" ?
                  Column(
                    children: [
                      constantTextField().InputField(
                          "Enter sqFit ",
                          "",
                          validationKey.sqArea,
                          _sqFitController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,
                          1,
                          TextInputType.name,
                          false),
                      SizedBox(height: 10,)
                    ],
                  )
                      : _salaryModeController.text == "perUnit" ?

                  Column(
                    children: [
                      constantTextField().InputField(
                          "perUnit ",
                          "",
                          validationKey.perUnit,
                          _perUnitController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,
                          1,
                          TextInputType.name,
                          false),
                      SizedBox(height: 10,)
                    ],
                  )
                      :
                  Container(),


                  Stack(
                    children: [
                      IgnorePointer(
                        child: constantTextField().InputField(
                            "Salary",
                            "",
                            validationKey.TimePeriod,
                            paySalaryMode,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_downward),
                            onSelected: (String val) {
                              paySalaryMode.text = val;
                            },
                            itemBuilder: (BuildContext context) {
                              return global.timeList
                                  .map<PopupMenuItem<String>>((String val) {
                                return new PopupMenuItem(
                                    child: new Text(val), value: val);
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),


                  Padding(
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      onPressed: () {
                        saveHeader();
                      },
                      child: Text("Submit"),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
  saveHeader() {
    if (formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      SocietyBillHeader societyBillHeader = SocietyBillHeader(
        headerName: _header.text,
        timePeriod: paySalaryMode.text,
        area: _salaryModeController.text,
        headerId: widget.societyBillHeader.headerId,
        enable:  true,
        perUnit: _perUnitController.text,
        sqFit: _sqFitController.text,
      );
      Firestore.instance.collection(global.SOCIETY)
          .document(global.societyId)
          .collection("SocietySalaryHeader")
          .document(societyBillHeader.headerId).setData(jsonDecode(jsonEncode(societyBillHeader.toJson())),merge: true);}
    _showDialog();
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
                  "Header is Updated ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('ok'),
              onPressed: () {
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
