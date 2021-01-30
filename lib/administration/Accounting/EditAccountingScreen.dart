import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/AccountingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
class EditAccountingScreen extends StatefulWidget {
  final AccountingModel accountingModel;

  const EditAccountingScreen({Key key, this.accountingModel}) : super(key: key);
  @override
  _EditAccountingScreenState createState() => _EditAccountingScreenState();
}

class _EditAccountingScreenState extends State<EditAccountingScreen> {
  List<String> list = ["Mandatory", "Non-Mandatory"];

  bool isLoading = false;
  DateTime getSelectedStartDate = DateTime.now();

  String operation = '';

  final formKey = GlobalKey<FormState>();
  TextEditingController _headerController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _payment = TextEditingController();
  TextEditingController _timePeriodController = TextEditingController();
  TextEditingController _firstDateController = TextEditingController();
  TextEditingController _secondDateController = TextEditingController();
  TextEditingController enterValidDay = TextEditingController();
  TextEditingController _enterInterestCharge = TextEditingController();
  TextEditingController _enterFixCharge = TextEditingController();
  TextEditingController _mandatoryController = TextEditingController();


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
      _firstDateController.value = TextEditingValue(text: _formattedate);
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
      _secondDateController.value = TextEditingValue(text: _formattedate);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    redData();
  }


  redData(){
    _headerController = TextEditingController(text: widget.accountingModel.accountHeader);
    _areaController = TextEditingController(text: widget.accountingModel.area);
    _payment = TextEditingController(text: widget.accountingModel.payment);
    _firstDateController = TextEditingController(text: DateFormat(global.dateFormat).format(widget.accountingModel.startDate));
    _secondDateController = TextEditingController(text: DateFormat(global.dateFormat).format(widget.accountingModel.endDate));
    _timePeriodController = TextEditingController(text: widget.accountingModel.timePeriod);
    enterValidDay = TextEditingController(text: widget.accountingModel.day);
   _enterInterestCharge = TextEditingController(text: widget.accountingModel.interestAmount ?? "");
   _enterFixCharge = TextEditingController(text: widget.accountingModel.fixedCharge ?? "");
    _mandatoryController = TextEditingController(text: widget.accountingModel.mandatory);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Detail"),
      ),
      body: Container(
          child: Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all( 20),
                child: ListView(
                  children: [
                    constantTextField().InputField(
                        "Select Header",
                        "",
                        validationKey.BillHeader,
                        _headerController,
                        false,
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        1,
                        1,
                        TextInputType.name,
                        false),
                    SizedBox(height: 10,),
                    Stack(
                      children: [
                        IgnorePointer(
                          child: constantTextField().InputField(
                              "Select",
                              "",
                              validationKey.mandatory,
                              _mandatoryController,
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
                                _mandatoryController.text = val;
                                setState(() {
                                  global.changeValidation = global.documentData[val];
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return list.map<PopupMenuItem<String>>((String val) {
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
                              "Select Mode",
                              "",
                              validationKey.mode,
                              _areaController,
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
                                _areaController.text = val;
                                setState(() {
                                  global.changeValidation = global.documentData[val];
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return global.perList.map<PopupMenuItem<String>>((String val) {
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
                              "Select Time Period",
                              "",
                              validationKey.TimePeriod,
                              _timePeriodController,
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
                                _timePeriodController.text = val;
                                setState(() {
                                  global.changeValidation = global.documentData[val];
                                });
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
                    SizedBox(
                      height: 10,
                    ),

                    constantTextField().InputField(
                        "Enter Payment",
                        "",
                        validationKey.payment,
                        _payment,
                        false,
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        1,
                        1,
                        TextInputType.name,
                        false),
                    SizedBox(
                      height: 10,
                    ),
                    Text("BIL Generated"),
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
                            "Enter bill Generated Date",
                            "20 - 12 - 2020",
                            validationKey.date,
                            _firstDateController,
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
                            "Enter Valid Date",
                            "20 - 12 - 2020",
                            validationKey.date,
                            _secondDateController,
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
                    constantTextField().InputField(
                        "Enter Day Limit",
                        "",
                        validationKey.validDocumentType,
                        enterValidDay,
                        false,
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        1,
                        1,
                        TextInputType.name,
                        false),
                    SizedBox(
                      height: 10,
                    ),

                    Text("Late Charges"),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                            groupValue: operation,
                            title: Text('Fix Charge',style: TextStyle(fontSize: 15),),
                            value: 'Fix Charge',
                            onChanged: (val) {
                              setState(() {
                                operation = val;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            groupValue: operation,
                            title: Text('Interest',style: TextStyle(fontSize: 15),),
                            value: 'Interest',
                            onChanged: (val) {
                              setState(() {
                                operation = val;
                              });
                            },
                          ),
                        )
                      ],
                    ),

                    operation == "Interest" ?   constantTextField().InputField(
                        "Enter Interest Charge",
                        "",
                        validationKey.validDocumentType,
                        _enterInterestCharge,
                        false,
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        1,
                        1,
                        TextInputType.name,
                        false): constantTextField().InputField(
                        "Enter Fix Charge",
                        "",
                        validationKey.validDocumentType,
                        _enterFixCharge,
                        false,
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        1,
                        1,
                        TextInputType.name,
                        false),



                    Padding(
                      padding: EdgeInsets.all(10),
                      child: RaisedButton(
                        onPressed: () {
                          addAccountingData();
                        },
                        child: Text("Submit"),
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
  addAccountingData() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      AccountingModel accountingModel = AccountingModel(
          accountingId: Uuid().v1(),
          accountHeader: _headerController.text,
          area: _areaController.text,
          timePeriod: _timePeriodController.text,
          enable: true,
          day: enterValidDay.text,
          mandatory: _mandatoryController.text,
          fixedCharge: _enterFixCharge.text,
          interestAmount: _enterInterestCharge.text,
          startDate:
          DateFormat(global.dateFormat).parse(_firstDateController.text),
          endDate:
          DateFormat(global.dateFormat).parse(_secondDateController.text),
          payment: _payment.text);
      Firestore.instance
          .collection("Society")
          .document(global.societyId)
          .collection("Accounting")
          .document(widget.accountingModel.accountingId)
          .setData(jsonDecode(jsonEncode(accountingModel.toJson())));
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
                  "Accounting Header is Update ",
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
