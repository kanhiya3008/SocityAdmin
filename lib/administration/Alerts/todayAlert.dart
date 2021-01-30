import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/AlertsModel.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;
class newAlert extends StatefulWidget {
  @override
  _newAlertState createState() => _newAlertState();
}

class _newAlertState extends State<newAlert> {
  List<Alerts> alertsList = List<Alerts>();
  bool isLoading = false;
  bool isExpanding = false;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
     super.initState();
     getGetDetails(lastDocument);

  }



  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getGetDetails(lastDocument);
      }
    });
    return
      Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child:Stack(
          children: [
            Positioned(
              bottom: 60,
              left: -MediaQuery.of(context).size.width * .4,
              child: BezierContainerTwo(),
            ),
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Column(children: [
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  SizedBox(width: 10,),
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
                                " Today Emergency",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: alertsList.length == 0
                    ? Center(
                  child: Text("No data"),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: alertsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Card(

                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child:
                                Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  child: Text(
                                    alertsList[index].alertsHeading,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: UniversalVariables.background

                                    ),overflow: TextOverflow.ellipsis,maxLines: 2,
                                  ),
                                ),

                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        children:[ Text(
                                          "Date - " +
                                              DateFormat(global.dateFormat)
                                                  .format(alertsList[index]
                                                  .startDate),
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),]
                                    ),
                                    SizedBox(height: 10,),
                                    Text(
                                      alertsList[index].description,
                                      style: TextStyle(
                                          fontSize: 15,fontWeight: FontWeight.w800
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                            onExpansionChanged: (bool expanding) =>
                                setState(
                                        () => this.isExpanding = expanding),
                          ),

                      ),
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
          ],
        ),
      )
    );
  }
  getGetDetails(DocumentSnapshot _lastDocument) async {
    bool hasMore = true;
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
    if (_lastDocument == null) {
      alertsList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Alerts")
           .orderBy("startDate",descending: true)
          .where("startDate",
                isGreaterThanOrEqualTo:
                DateTime.now().subtract(Duration(days: 1)).toIso8601String())
           .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Alerts")
           .orderBy("startDate",descending: true)
          .where("startDate",
          isGreaterThanOrEqualTo:
          DateTime.now().subtract(Duration(days: 1)).toIso8601String())
           .startAfterDocument(_lastDocument)
           .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    }
    if (querySnapshot.documents.length < documentLimit) {

      hasMore = false;
    }
    if (querySnapshot.documents.length != 0) {
      lastDocument =
      querySnapshot.documents[querySnapshot.documents.length - 1];
      setState(() {
        querySnapshot.documents.forEach((element) {
          var alerts = Alerts();
          alerts = Alerts.fromJson(element.data);
          alertsList.add(alerts);
        });
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
