import 'dart:async';

import 'package:MyDen/administration/Accounting/EditAccountingScreen.dart';
import 'package:MyDen/administration/Accounting/addAccounting.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/AccountingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
class AccountingMainScreen extends StatefulWidget {
  @override
  _AccountingMainScreenState createState() => _AccountingMainScreenState();
}

class _AccountingMainScreenState extends State<AccountingMainScreen> {
  List<AccountingModel> accountinList = List<AccountingModel>();
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument = null;
  bool isExpanded = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getAccountinDetails(lastDocument);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.background,
        title: Text("Accounting",style: TextStyle(color: UniversalVariables.ScaffoldColor),),
      ),
      body:  Stack(children: [
        Column(children: [
          SizedBox(
            height: 10,
          ),

          Expanded(
            child: accountinList.length == 0
                ? Center(child: Text("No Data"))
                : ListView.builder(
              controller: _scrollController,
              itemCount: accountinList.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: GestureDetector(
                        onTap: () {

                        },
                        child: Card(
                          // width: MediaQuery.of(context).size.width,
                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(children: [
                                Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  child: Text(
                                    accountinList[index].accountHeader,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,

                                    ),overflow: TextOverflow.ellipsis,maxLines: 1,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                    onTap: () {
                                      Route route = MaterialPageRoute(
                                          builder: (context) =>
                                              EditAccountingScreen(
                                                  accountingModel: accountinList[
                                                  index]));
                                      Navigator.push(context, route)
                                          .then(onGoBack);
                                    },
                                    child: Icon(Icons.mode_edit)),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      _showDeletDialog(
                                          accountinList[index]);
                                    },
                                    child: Icon(Icons.delete)),
                              ]),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(
                                        "Area - " +
                                            accountinList[index].area,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "TimePeriod - " +
                                            accountinList[index].timePeriod,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ]),
                                    Text(
                                      "Bill Issue Date - " +
                                          DateFormat(global.dateFormat)
                                              .format(accountinList[index]
                                              .startDate),
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Last Date - " +
                                          DateFormat(global.dateFormat)
                                              .format(accountinList[index]
                                              .endDate),
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Valid UpTo - " +
                                          accountinList[index].day + " days",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    // Text(
                                    //   eventList[index].description,
                                    //   style: TextStyle(
                                    //       fontSize: 15,fontWeight: FontWeight.w800
                                    //   ),
                                    // ),
                                  ],
                                ),
                              )
                            ],
                            onExpansionChanged: (bool expanding) =>
                                setState(
                                        () => this.isExpanded = expanding),
                          ),
                        )
                    )


                );
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
      ]),

      floatingActionButton: (FloatingActionButton(
        onPressed: () {
          navigateSecondPage();
        },
        child: Icon(Icons.add),
      )),
    );
  }


  getAccountinDetails(DocumentSnapshot _lastDocument) async {
    if (!hasMore) {
      print('No More Data');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      accountinList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Accounting")
          // .orderBy("startDate")
          // .where("startDate",
          // isGreaterThanOrEqualTo:
          // DateTime.now().subtract(Duration(days: 1)).toIso8601String())
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Accounting")
          .orderBy("startDate")
          // .where("startDate",
          // isGreaterThanOrEqualTo:
          // DateTime.now().subtract(Duration(days: 1)).toIso8601String())
          .where("enable", isEqualTo: true)
          .startAfterDocument(_lastDocument)
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
          var accounting = AccountingModel();
          accounting = AccountingModel.fromJson(element.data);
          accountinList.add(accounting);
        });
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showDeletDialog(AccountingModel accountingModel) async {
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
                  "Are You sure want to Delete this Event",
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
                deleteEvent(accountingModel);
              },
            ),
          ],
        );
      },
    );
  }


  deleteEvent(AccountingModel accountingModel) async {
    bool _isRequesting = false;
    await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Accounting")
        .document(accountingModel.accountingId)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        _isRequesting = false;
      });
      setState(() {
        accountinList.remove(accountingModel);
      });
      Fluttertoast.showToast(msg: "Delete successfully");
      Navigator.pop(context);
    }).catchError((err) {
      setState(() {
        _isRequesting = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }
  FutureOr onGoBack(dynamic value) {
    hasMore = true;
    print("On call back");
    getAccountinDetails(null);

    setState(() {});
  }
  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddAccounting());
    Navigator.push(context, route).then(onGoBack);
  }
}
