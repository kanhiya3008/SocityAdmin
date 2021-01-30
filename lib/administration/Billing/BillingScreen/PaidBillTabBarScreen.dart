import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/billing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'DueBillingHistory.dart';
import 'PaidBillScreen.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'PayBill.dart';
class PaidBillTabBarscreen extends StatefulWidget {
  final billHead;

  const PaidBillTabBarscreen({Key key, this.billHead}) : super(key: key);
  @override
  _PaidBillTabBarscreenState createState() => _PaidBillTabBarscreenState();
}

class _PaidBillTabBarscreenState extends State<PaidBillTabBarscreen>  with SingleTickerProviderStateMixin  {
  TabController _tabController;
  ScrollController _DuescrollController = ScrollController();
  ScrollController _getPaidController = ScrollController();
  List<BillingModel> billingList = List<BillingModel>();
  List<BillingModel> PaidbillingList = List<BillingModel>();

  bool dueIsLoading = false;
  bool dueHasMore = true;
  bool padIsLoading = false;
  bool padHasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument = null;

  @override
  void initState() {
    super.initState();
    getBillingDetails(lastDocument);
    PaidBillingDetails(lastDocument);


    _tabController = new TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.billHead),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.amber,
          tabs: [
            Tab(
              child: Text(
                "Due Bill",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Tab(
              child: Text(
                "Paid Bill",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [_getDueBillScreen(), _getpaidBill()],
        controller: _tabController,
      ),
    );
  }

  Widget _getpaidBill(){
    _getPaidController.addListener(() {
      print("build widget call");
      double maxScroll = _getPaidController.position.maxScrollExtent;
      double currentScroll = _getPaidController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        print("load data");
        PaidBillingDetails(lastDocument);
      }
    });
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: PaidbillingList.length == 0
              ? Center(child: Text("No Data"))
              : ListView.builder(
            controller: _getPaidController,
            itemCount: PaidbillingList.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder:(context)=> PayBill (
                        //   billingId: PaidbillingList[index].billingId,
                        // )));
                      },
                      child: Card(
                        // width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      PaidbillingList[index].billingHeader,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,

                                      ),overflow: TextOverflow.ellipsis,maxLines: 1,
                                    ),
                                    Text(
                                      "Paid Bill",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: Colors.green

                                      ),overflow: TextOverflow.ellipsis,maxLines: 1,
                                    )

                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(

                                      PaidbillingList[index].mode,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "Total Amount - " +
                                          PaidbillingList[index].totalAmount.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                                  Text(
                                    "Bill Issue Date - " +
                                        DateFormat(global.dateFormat)
                                            .format(PaidbillingList[index]
                                            .startDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Bill Pay Date - " +
                                        DateFormat(global.dateFormat)
                                            .format(PaidbillingList[index]
                                            .endDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Valid UpTo - " +
                                        PaidbillingList[index].validDays + " days",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),


                                  SizedBox(height: 10,),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                  )


              );
            },
          ),
        ),
        padIsLoading
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
    );

  }
  PaidBillingDetails(DocumentSnapshot _lastDocument) async {
    int documentLimit = 10;
    if (!padHasMore) {
      return;
    }
    if (padIsLoading) {
      return;
    }
    setState(() {
      padIsLoading = true;
    });

    QuerySnapshot querySnapshot;
    print('No More Data');
    if (_lastDocument == null) {
      PaidbillingList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Billing")
          .where("billingHeader",isEqualTo: widget.billHead)
          .where("enable",isEqualTo: false)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Billing")
          .startAfterDocument(_lastDocument)
          .where("billingHeader",isEqualTo: widget.billHead)
          .where("enable",isEqualTo: false)
          .limit(documentLimit)
          .getDocuments();
    }
    print("Society data");

    if (querySnapshot.documents.length < documentLimit) {
      print("data finish");
      padHasMore = false;
    }
    if (querySnapshot.documents.length != 0) {
      lastDocument =
      querySnapshot.documents[querySnapshot.documents.length - 1];
      print("final data");

      setState(() {
        querySnapshot.documents.forEach((element) {
          var billing = BillingModel();
          billing = BillingModel.fromJson(element.data);
           PaidbillingList.add(billing);
         // PaidbillingList.forEach((element) {
         //   print(element.enable);
         // });
        });
      });
    }
    setState(() {
      padIsLoading = false;
    });
  }

  getBillingDetails(DocumentSnapshot _lastDocument) async {
    int documentLimit = 10;
    if (!dueHasMore) {

      return;
    }
    if (dueIsLoading) {
      return;
    }
    setState(() {
      dueIsLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      billingList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Billing")
          .where("billingHeader",isEqualTo: widget.billHead)
          .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Billing")
          .startAfterDocument(_lastDocument)
          .where("billingHeader",isEqualTo: widget.billHead)
          .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    }
    print("Society data");

    if (querySnapshot.documents.length < documentLimit) {
      print("data finish");
      dueHasMore = false;
    }
    if (querySnapshot.documents.length != 0) {
      lastDocument =
      querySnapshot.documents[querySnapshot.documents.length - 1];
      print("final data");

      setState(() {
        querySnapshot.documents.forEach((element) {
          var billing = BillingModel();
          billing = BillingModel.fromJson(element.data);
          billingList.add(billing);
          print("paidBilling $PaidbillingList");
          billingList.forEach((element) {
            print(element.enable);
          });
        });
      });
    }
    setState(() {
      dueIsLoading = false;
    });
  }


  Widget _getDueBillScreen(){
    _DuescrollController.addListener(() {
      print("build widget call");
      double maxScroll = _DuescrollController.position.maxScrollExtent;
      double currentScroll = _DuescrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        print("load data");
        PaidBillingDetails(lastDocument);
      }
    });
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: billingList.length == 0
              ? Center(child: Text("No Data"))
              : ListView.builder(
            controller: _DuescrollController,
            itemCount: billingList.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder:(context)=> PayBill (
                        //   billingId: billingList[index].billingId,
                        // )
                        // )
                        // );

                      },
                      child: Card(
                        // width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      billingList[index].billingHeader,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,

                                      ),overflow: TextOverflow.ellipsis,maxLines: 1,
                                    ),
                                    Text(
                                      "Due Bill",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: Colors.red[900]

                                      ),overflow: TextOverflow.ellipsis,maxLines: 1,
                                    )

                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(

                                      billingList[index].mode,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "Total Amount - " +
                                          billingList[index].totalAmount.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                                  Text(
                                    "Bill Issue Date - " +
                                        DateFormat(global.dateFormat)
                                            .format(billingList[index]
                                            .startDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Bill Pay Date - " +
                                        DateFormat(global.dateFormat)
                                            .format(billingList[index]
                                            .endDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Valid UpTo - " +
                                        billingList[index].validDays + " days",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),


                                  SizedBox(height: 10,),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                  )


              );
            },
          ),
        ),
        dueIsLoading
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
    );
  }
}
