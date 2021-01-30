
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/event.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'EditEventData.dart';
class EventHistory extends StatefulWidget {
  final startDate;
  final endDate;

  const EventHistory({Key key, this.startDate,this.endDate}) : super(key: key);
  @override
  _EventHistoryState createState() => _EventHistoryState();
}

class _EventHistoryState extends State<EventHistory> {
  List<Event> eventList = List<Event>();
  bool hasMore = true;
  bool isExpanded = false;
  @override
  void initState() {

      getEventDetails();

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Events History',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom:-MediaQuery.of(context).size.height * .10,
            left: -MediaQuery.of(context).size.width * .4,
            child: BezierContainerTwo(),
          ),

          Column(
            children: [
              SizedBox(height: 10,),


              Expanded(
                child: eventList.length == 0
                    ? Center(child: Text("No Data"))
                    :
                ListView.builder(

                        shrinkWrap: true,

                        itemCount: eventList.length,
                        itemBuilder: (context, index) {
                          return  Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: GestureDetector(
                              onTap: () {

                              },
                              child:  Card(
                                // width: MediaQuery.of(context).size.width,
                                child: ExpansionTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width/2,
                                        child: Text(
                                          eventList[index].eventName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,

                                          ),overflow: TextOverflow.ellipsis,maxLines: 1,
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
                                          Row(children: [
                                            Text(
                                              "Venue - " +
                                                  eventList[index].venue,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              "Entry - " +
                                                  eventList[index].eventFee,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ]),
                                          Text(
                                            "Date - " +
                                                DateFormat(global.dateFormat)
                                                    .format(eventList[index]
                                                    .startDate),
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "endDate - " +
                                                DateFormat(global.dateFormat)
                                                    .format(eventList[index]
                                                    .endDate),
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "Timing - " +
                                                eventList[index].eventTiming,
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Text(
                                            eventList[index].description,
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
                                              () => this.isExpanded = expanding),
                                ),
                              )
                            ),
                          );
                        }
                )
                )
            ],
          )
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, top: 25,bottom: 5),
        child: Row(
          children: <Widget>[
            Icon(Icons.keyboard_arrow_left,
                color: UniversalVariables.background),
            Text('Back',
                style: TextStyle(
                    color: UniversalVariables.background,
                    fontSize: 15,
                    fontWeight: FontWeight.w800))
          ],
        ),
      ),
    );
  }

  getEventDetails() async {
    QuerySnapshot querySnapshot;
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Events")
          .orderBy("startDate")
          .where("startDate", isGreaterThanOrEqualTo: DateFormat(global.dateFormat).parse( widget.startDate).toIso8601String())
          .where("startDate", isLessThanOrEqualTo: DateFormat(global.dateFormat).parse(widget.endDate).toIso8601String())
          .where("enable", isEqualTo: true)
          .getDocuments();

    if (querySnapshot.documents.length != 0) {
      setState(() {
        querySnapshot.documents.forEach((element) {
          var event = Event();
          event = Event.fromJson(element.data);
          eventList.add(event);
        });
      });
    }


  }






}
