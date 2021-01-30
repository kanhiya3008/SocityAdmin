import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/SocietyBillHeader.dart';
import 'package:MyDen/model/SocietySalary.dart';
import 'package:MyDen/model/guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:uuid/uuid.dart';

import 'SocietyHeaderSalary.dart';

class AddSocietySalary extends StatefulWidget {
  @override
  _AddSocietySalaryState createState() => _AddSocietySalaryState();
}

class _AddSocietySalaryState extends State<AddSocietySalary> {
  List<SocietyBillHeader> societyBillHeaderList = List<SocietyBillHeader>();
  List<Guard> guardListList = List<Guard>();
  TextEditingController _header = TextEditingController();

  TextEditingController _areaController = TextEditingController();
  TextEditingController _semiAmountController = TextEditingController();
  TextEditingController _semiUnitPriceController = TextEditingController();
  TextEditingController _semiUnitController = TextEditingController();
  bool _checkbox = false;
  double totalBill = 0;
  bool _checkboxListTile = false;
  List<bool> _checkbox1;
  var area;
  var fixAmount;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHeaderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Salary"),
      ),
      body: Container(
        child: Form(
            key: global.formKey,
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

                              getFixCharge(_header.text);
                            },
                            itemBuilder: (BuildContext context) {
                              return societyBillHeaderList
                                  .map<PopupMenuItem<String>>((val) {
                                return new PopupMenuItem(
                                    child: new Text(val.headerName),
                                    value: val.headerName);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Salary"),
                      Text(totalBill.toString())
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  area == null ? Text("Loading......") : Text(area),
                  SizedBox(
                    height: 10,
                  ),
                  area == "Semi Fix"
                      ? Column(
                          children: [
                            IgnorePointer(
                              child: constantTextField().InputField(
                                  "Enter Fix Amount",
                                  "",
                                  validationKey.fixPrice,
                                  _semiAmountController,
                                  false,
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed: () {},
                                  ),
                                  1,
                                  1,
                                  TextInputType.number,
                                  false),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: constantTextField().InputField(
                                      "Unit Price ",
                                      "",
                                      validationKey.perUnit,
                                      _semiUnitPriceController,
                                      false,
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios),
                                        onPressed: () {},
                                      ),
                                      1,
                                      1,
                                      TextInputType.number,
                                      false),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: constantTextField().InputField(
                                      "Unit ",
                                      "",
                                      validationKey.unit,
                                      _semiUnitController,
                                      false,
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios),
                                        onPressed: () {},
                                      ),
                                      1,
                                      1,
                                      TextInputType.number,
                                      false),
                                )
                              ],
                            ),
                          ],
                        )
                      : area == "PerUnit" || area == "Sq.fit"
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: constantTextField().InputField(
                                          "Unit Price ",
                                          "",
                                          validationKey.perUnit,
                                          _semiUnitPriceController,
                                          false,
                                          IconButton(
                                            icon: Icon(Icons.arrow_back_ios),
                                            onPressed: () {},
                                          ),
                                          1,
                                          1,
                                          TextInputType.number,
                                          false),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: constantTextField().InputField(
                                          "Unit ",
                                          "",
                                          validationKey.unit,
                                          _semiUnitController,
                                          false,
                                          IconButton(
                                            icon: Icon(Icons.arrow_back_ios),
                                            onPressed: () {},
                                          ),
                                          1,
                                          1,
                                          TextInputType.number,
                                          false),
                                    )
                                  ],
                                ),
                              ],
                            )
                          : area == "fixed"
                              ? constantTextField().InputField(
                                  "Unit Price ",
                                  "",
                                  validationKey.perUnit,
                                  _semiUnitPriceController,
                                  false,
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed: () {},
                                  ),
                                  1,
                                  1,
                                  TextInputType.number,
                                  false)
                              : Container(),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      onPressed: () {
                        saveSocietyBill();
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

  getHeaderDetails() {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("SocietySalaryHeader")
        .where("enable",isEqualTo: true)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          var societyHeader = SocietyBillHeader();
          societyHeader = SocietyBillHeader.fromJson(element.data);
          societyBillHeaderList.add(societyHeader);
        });
      });
    });
  }

  getFixCharge(String header) {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("SocietySalaryHeader")
        .where("headerName", isEqualTo: header)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          area = element['area'];
          _semiAmountController.text = element['semiAmount'];

          print(area);
          print(fixAmount);
        });
      });
    });
  }

  double addBill() {
    if (area == "Semi Fix") {
      totalBill = double.parse(_semiUnitPriceController.text) *
              double.parse(_semiUnitController.text) +
          double.parse(_semiAmountController.text);
      print(totalBill);
    } else if (area == "PerUnit" || area == "Sq.fit") {
      totalBill = double.parse(_semiUnitPriceController.text) *
          double.parse(_semiUnitController.text);
      print(totalBill);
    } else {
      totalBill = double.parse(_semiUnitPriceController.text);
      print(totalBill);
    }

    setState(() {});

    return totalBill;
  }

  saveSocietyBill() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      addBill();
      SocietyTotalSalary societyTotalSalary = SocietyTotalSalary(
          societySalaryId: Uuid().v1(),
          headerName: _header.text,
          fixAmount: _semiAmountController.text,
          unitPrice: _semiUnitPriceController.text,
          unit: _semiUnitController.text,
          totalAmount: addBill().toString(),
          enable: true,
          salaryMode: area,
          billGenerateDate: DateTime.now());
      Firestore.instance
          .collection("Society")
          .document(global.societyId)
          .collection("SocietySalary")
          .document(societyTotalSalary.societySalaryId)
          .setData(jsonDecode(jsonEncode(societyTotalSalary.toJson())));
      _showDialog();
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
                  "Bill is Added ",
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

//
//
// Container(
// width: MediaQuery.of(context).size.width,
// height: MediaQuery.of(context).size.width,
// child: ListView.builder(
// shrinkWrap: true,
// itemCount: guardListList.length,
// itemBuilder: (context, index) {
// return Column(
// children: [
// SizedBox(
// height: 10,
// ),
// GestureDetector(
// onTap: () {
// setState(() {
// _checkbox = !_checkbox;
// });
// },
// child: Container(
// decoration: BoxDecoration(
// borderRadius:
// BorderRadius.circular(20),
// color: Colors.grey[300]),
// child: Padding(
// padding: EdgeInsets.all(10),
// child: Row(
// mainAxisAlignment:
// MainAxisAlignment
//     .spaceBetween,
// children: [
// Text(guardListList[index]
//     .guardName),
// Text(guardListList[index]
//     .guardSalary),
// Checkbox(
// value: _checkbox,
// ),
// ],
// ))),
// ),
// ],
// );
// })),
