
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';

import 'package:MyDen/model/notice.dart';
import 'package:MyDen/model/sharedperef.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;


class NoticeHistory extends StatefulWidget {
  final startDate;
  final endDate;

  const NoticeHistory({Key key, this.startDate,this.endDate}) : super(key: key);
  @override
  _EventHistoryState createState() => _EventHistoryState();
}

class _EventHistoryState extends State<NoticeHistory> {
  List<Notice> noticeList = List<Notice>();
  bool hasMore = true;
  bool isExpanding = false;

  @override
  void initState() {
   super.initState();
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
                  child: noticeList.length == 0
                      ? Center(child: Text("No Data"))
                      :
                  ListView.builder(

                      shrinkWrap: true,

                      itemCount: noticeList.length,
                      itemBuilder: (context, index) {
                        return  Padding(
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
                                          noticeList[index].noticeHeading,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,

                                          ),overflow: TextOverflow.ellipsis,maxLines: 2,
                                        ),
                                      ),
                                      Spacer(),
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
                                                        .format(noticeList[index]
                                                        .startDate),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),]
                                          ),
                                          Text(
                                            "endDate - " +
                                                DateFormat(global.dateFormat)
                                                    .format(noticeList[index]
                                                    .endDate),
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Text(
                                            noticeList[index].description,
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


  getEventDetails() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Notice")
        .orderBy("startDate")
        .where("startDate", isGreaterThanOrEqualTo: DateFormat(global.dateFormat).parse( widget.startDate).toIso8601String())
        .where("startDate", isLessThanOrEqualTo: DateFormat(global.dateFormat).parse(widget.endDate).toIso8601String())
        .where("enable", isEqualTo: true)
        .getDocuments();

    if (querySnapshot.documents.length != 0) {
      setState(() {
        querySnapshot.documents.forEach((element) {
          var notice = Notice();
          notice = Notice.fromJson(element.data);
          noticeList.add(notice);
        });
      });
    }


  }






}
