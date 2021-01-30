import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/model/AccountingModel.dart';
import 'package:MyDen/model/billing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BillingAddMainScreen extends StatefulWidget {
  @override
  _BillingMainScreenState createState() => _BillingMainScreenState();
}

class _BillingMainScreenState extends State<BillingAddMainScreen> {
  TextEditingController _houseNumber = TextEditingController();
  TextEditingController _header = TextEditingController();
  TextEditingController _perUnitController = TextEditingController();
  List<AccountingModel> accountingList = List<AccountingModel>();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  List<String> list = [];
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var area = "";
  var head = "";
  var paymenthead = "";
  double totalamount = 0;
  List<String> flatNumber = [];
  List<String> header = [];

  //List<String> area = [];

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  DateTime getSelectedStartDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null)
      setState(() {
        isLoading = true;
        String formatDate = new DateFormat(global.dateFormat).format(picked);
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
        String formatDate = new DateFormat(global.dateFormat).format(picked);
        _endDateController.value = TextEditingValue(text: formatDate);
      });
  }




  @override
  void initState() {
    getHouseDetails();
    getHeaderDetails();
    _header.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Billing"),
        actions: [
          IconButton(icon:Icon (Icons.history), onPressed: (){
            _eventHistory();
          })
        ],
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
                          getHeadreDetails();
                          setState(() {
                            global.changeValidation = global.documentData[val];
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return accountingList
                              .map<PopupMenuItem<String>>((val) {
                            return new PopupMenuItem(
                                child: new Text(val.accountHeader),
                                value: val.accountHeader);
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
                  constantTextField().InputField(
                      "Select Flat Number",
                      "",
                      validationKey.flatNo,
                      _houseNumber,
                      false,
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {},
                      ),
                      1,
                      1,
                      TextInputType.name,
                      false),
                  Positioned(
                    right: 0,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_downward),
                        onSelected: (String val) {
                          _houseNumber.text = val;
                          getAccountigHeader();
                          setState(() {
                            global.changeValidation = global.documentData[val];
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return flatNumber
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
              Text(
                "Unit",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Card(
                      child: _header.text == null
                          ? Text("kjkj")
                          : Text('$paymenthead')),
                  Text(" * "),
                  Expanded(
                    child: Container(
                        child: _houseNumber.text != null
                            ? head == "fixed"
                                ? Text("1")
                                : head == "Sq.fit"
                                    ? Text('$area')
                                    : head == "perUnit"
                                        ? constantTextField().InputField(
                                            "Enter Unit",
                                            "",
                                            validationKey.mandatory,
                                            _perUnitController,
                                            false,
                                            IconButton(
                                              icon: Icon(Icons.arrow_back_ios),
                                              onPressed: () {},
                                            ),
                                            1,
                                            1,
                                            TextInputType.number,
                                            false)
                                        : Container()
                            : Container()),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "Total = ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Card(
                    child: Text(totalamount.toString()),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: _header.text != null ?  Container() : Text(DateFormat(global.dateFormat)
                    .format(accountingList[0]
                    .startDate)),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: RaisedButton(
                  onPressed: () {
                     saveDataTofirebase();
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

  getHouseDetails() {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("Houses")
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          flatNumber.add(element['flatNumber']);
        });
      });
    });
  }

  getHeadreDetails() {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("Accounting")
        .where("accountHeader", isEqualTo: _header.text)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          head = element['area'];
          paymenthead = element['payment'];
        });
        print(head);
      });
    });
  }

  getAccountigHeader() {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("Houses")
        .where("flatNumber", isEqualTo: _houseNumber.text)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          area = element['area'];
        });
        print(area);
      });
    });
    // if(_header == null){
    //   showScaffold("Choose operation first");
    // }
  }

  calcute() {
    print(paymenthead);
    double fff = double.parse(paymenthead);
    if (head == "fixed") {
      setState(() {
        totalamount = fff;
      });
    } else if (head == "Sq.fit") {
      double are = double.parse(area);
      setState(() {
        totalamount = fff * are;
      });
    } else {
      setState(() {
        totalamount = fff * double.parse(_perUnitController.text);
      });
    }
  }

  getHeaderDetails() {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("Accounting")
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          var accounting = AccountingModel();
          accounting = AccountingModel.fromJson(element.data);
          accountingList.add(accounting);
        });
      });
    });
  }

  saveDataTofirebase() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;

      });
      calcute();
    if (totalamount == 0.0) {
      showScaffold('Enter bill detail ');
    } else  {

      BillingModel billingModel = BillingModel(
          billingId: Uuid().v1(),
          billingHeader: _header.text,
          enable: true,
          validDays: accountingList[0].day,
          startDate: accountingList[0].startDate,
          endDate: accountingList[0].endDate,
          flatNumber: _houseNumber.text,
          totalAmount: totalamount,
          mode: accountingList[0].area,
          perUnit: _perUnitController.text);
      Firestore.instance
          .collection("Society")
          .document(global.societyId)
          .collection("Billing")
          .document(billingModel.billingId)
          .setData(jsonDecode(jsonEncode(billingModel.toJson())));
      showScaffold("Bill Add Successfully");
      _header.clear();
      _houseNumber.clear();

    }
  }
  }


  Future<void> _eventHistory() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "First Date",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: InkWell(
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
                                    onPressed: () {},
                                    icon: Icon(Icons.calendar_today),
                                  ),
                                  1,1,
                                  TextInputType.emailAddress,false
                                //Icon(Icons.calendar_today)

                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Last Date",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: InkWell(
                            onTap: () {
                              if (isLoading == true) {
                                _selectEndDate(
                                    context,
                                    DateTime.now().subtract(Duration(days: 365)),
                                    DateTime.now(),
                                    DateTime.now());
                              }
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
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              child: Text('Yes'),
              onPressed: () {
               // updateInformation();
              },
            ),
          ],
        );
      },
    );
  }

}
