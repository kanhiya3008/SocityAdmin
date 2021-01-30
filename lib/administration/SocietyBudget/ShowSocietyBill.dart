import 'dart:async';

import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/SocietySalary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'AddSocietySalary.dart';

class ShowSocietyBill extends StatefulWidget {
  @override
  _ShowSocietyBillState createState() => _ShowSocietyBillState();
}

class _ShowSocietyBillState extends State<ShowSocietyBill> {
  List<SocietyTotalSalary> societyListSalary = List<SocietyTotalSalary>();
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument = null;
  bool isExpanded = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSocietySalary(lastDocument);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Billing"),
      ),
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: societyListSalary.length == 0
              ? Center(child: Text("No Data"))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: societyListSalary.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder:(context)=> PayBill (
                              //   billingId: societyListSalary[index].billingId,
                              // )));
                            },
                            child: Card(
                                child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        societyListSalary[index].headerName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          _showDeletDialog(
                                              societyListSalary[index]);
                                        },
                                        child: Icon(Icons.delete)),

                                  ]),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(children: [
                                    Text(
                                      societyListSalary[index].salaryMode,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "Total Amount - " +
                                          societyListSalary[index]
                                              .totalAmount
                                              .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                                  Text(
                                    "Bill Issue Date - " +
                                        DateFormat(global.dateFormat).format(
                                            societyListSalary[index]
                                                .billGenerateDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  societyListSalary[index].salaryMode == "PerUnit" ||  societyListSalary[index].salaryMode == "Sq.fit" ?
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          societyListSalary[index].salaryMode == "PerUnit" ?
                                          Text("Total Unit        " + societyListSalary[index].unit):
                                          Text("Total Sq.fit        " + societyListSalary[index].unit),
                                          societyListSalary[index].salaryMode == "PerUnit" ?
                                          Text("Per Unit Price  "+societyListSalary[index].unitPrice):
                                          Text("Per Sq.fit Price " + societyListSalary[index].unitPrice),
                                        ],
                                      ): societyListSalary[index].salaryMode == "Semi Fix" ?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Fix Amount            " + societyListSalary[index].fixAmount),
                                      Text("Total Unit                " + societyListSalary[index].unit),
                                      Text("Per Unit Amount  "+societyListSalary[index].unitPrice)
                                    ],
                                  ):societyListSalary[index].salaryMode == "fixed" ?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Fix Amount            " + societyListSalary[index].fixAmount),

                                    ],
                                  ):Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ))));
                  },
                ),
        ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(5),
                color: UniversalVariables.background,
                child: Text(
                  'Loading......',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UniversalVariables.ScaffoldColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container()
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateSecondPage();
        },
        child: Text("click"),
      ),
    );
  }

  getSocietySalary(DocumentSnapshot _lastDocument) async {
    int documentLimit = 10;
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    print('No More Data');
    if (_lastDocument == null) {
      societyListSalary.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("SocietySalary")
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("SocietySalary")
          .startAfterDocument(_lastDocument)
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    }
    print("Society data");

    if (querySnapshot.documents.length < documentLimit) {
      print("data finish");
      hasMore = false;
    }
    if (querySnapshot.documents.length != 0) {
      lastDocument =
          querySnapshot.documents[querySnapshot.documents.length - 1];
      print("final data");

      setState(() {
        querySnapshot.documents.forEach((element) {
          var societySalary = SocietyTotalSalary();
          societySalary = SocietyTotalSalary.fromJson(element.data);
          societyListSalary.add(societySalary);
        });
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  FutureOr onGoBack(dynamic value) {
    hasMore = true;
    print("On call back");
    getSocietySalary(null);
    setState(() {});
  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddSocietySalary());
    Navigator.push(context, route).then(onGoBack);
  }



  Future<void> _showDeletDialog(SocietyTotalSalary societyTotalSalary) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are You sure want to Delete this Bill",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
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
                deleteBill(societyTotalSalary);
              },
            ),
          ],
        );
      },
    );
  }
  deleteBill(SocietyTotalSalary societyTotalSalary) async {
    await Firestore.instance
        ..collection('Society')
            .document(global.societyId)
            .collection("SocietySalary")
            .document(societyTotalSalary.societySalaryId)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        isLoading = false;
      });
      setState(() {
        societyListSalary.remove(societyTotalSalary);
      });
      Fluttertoast.showToast(msg: "Delete successfully");
      Navigator.pop(context);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }
}
