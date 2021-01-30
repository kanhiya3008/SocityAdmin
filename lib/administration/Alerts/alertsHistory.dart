
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/AlertsModel.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;
class alertsHistory extends StatefulWidget {
  final startDate;
  final endDate;
  const alertsHistory({Key key, this.startDate,this.endDate}) : super(key: key);
  @override
  _alertsHistoryState createState() => _alertsHistoryState();
}

class _alertsHistoryState extends State<alertsHistory> {

  List<Alerts> alertsList = List<Alerts>();
//  var activationValue = "";
  bool isExpanding = false;

  @override
  void initState() {
//    savelocalCode().toGetDate(societyId).then((value){
//      setState(() {
//        activationValue = value;
//      });
      getEventDetails();
//    }
//    );
  }


  @override
  Widget build(BuildContext context) {
    return   Scaffold(
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
                  height: 20,
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
                                " History",
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
                      ? Center(child: Text("No Data found between this date"))
                      : ListView.builder(
                    itemCount: alertsList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Card(

                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(children: [
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
                                Spacer(),
                                SizedBox(
                                  width: 5,
                                ),

                              ]),
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
                                setState(() => this.isExpanding = expanding),
                          ),

                        ),
                      );
                    },
                  ),
                ),
              ]),
            ],
          ),
        )
    );
  }


  getEventDetails() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Alerts")
        .orderBy("startDate")
        .where("startDate", isGreaterThanOrEqualTo: DateFormat(global.dateFormat).parse( widget.startDate).toIso8601String())
        .where("startDate", isLessThanOrEqualTo: DateFormat(global.dateFormat).parse(widget.endDate).toIso8601String())
        .where("enable", isEqualTo: true)
        .getDocuments();

    if (querySnapshot.documents.length != 0) {
      setState(() {
        querySnapshot.documents.forEach((element) {
          var alerts = Alerts();
          alerts = Alerts.fromJson(element.data);
          alertsList.add(alerts);
        });
      });
    }
  }
}
