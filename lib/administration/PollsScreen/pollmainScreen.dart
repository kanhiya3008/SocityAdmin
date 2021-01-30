import 'dart:async';

import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/polls.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'addPollDetails.dart';

import 'package:MyDen/constants/global.dart' as global;

class mainPollScreen extends StatefulWidget {
  @override
  _mainPollScreenState createState() => _mainPollScreenState();
}

class _mainPollScreenState extends State<mainPollScreen> {
  List<Polls> pollsList = List<Polls>();
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;
  DateTime getSelectedStartDate = DateTime.now();
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
      getGetDetails(lastDocument);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polls',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
        onPressed: (){
          Navigator.pop(context);
      },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              bottom: 60,
              left: -MediaQuery.of(context).size.width * .4,
              child: BezierContainerTwo(),
            ),
            Padding(
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Expanded(
                    child: pollsList.length == 0
                        ? Center(
                            child: Text("No data"),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: pollsList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12),
                                  child: Card(
                                      color: UniversalVariables.ScaffoldColor,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                                Text(
                                                  "Poll Date     " +
                                                      DateFormat(
                                                              global.dateFormat)
                                                          .format(
                                                              pollsList[index]
                                                                  .startDate),
                                                  style: TextStyle(
                                                      color: UniversalVariables
                                                          .background,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                                Text(
                                                  "Poll Topic   " + pollsList[index].pollName,
                                                  style: TextStyle(
                                                      color: UniversalVariables
                                                          .background,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Result:",
                                                  style: TextStyle(
                                                      color: UniversalVariables
                                                          .background,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                )
                                              ],
                                            ),
                                            Card(
                                              color:
                                                  UniversalVariables.background,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Options",
                                                        style: TextStyle(
                                                            color: UniversalVariables
                                                                .ScaffoldColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                  optionList(pollsList[index].options),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Votes",
                                                        style: TextStyle(
                                                            color: UniversalVariables
                                                                .ScaffoldColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      optionList(pollsList[index].options),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Percentage",
                                                        style: TextStyle(
                                                            color: UniversalVariables
                                                                .ScaffoldColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      optionList(pollsList[index].options),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )));
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (FloatingActionButton(
        onPressed: () {
          navigateSecondPage();
        },
        child: Icon(Icons.add),
      )),
    );
  }

  Widget optionList(List data) {
    return Container(
      width: 100,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return  Column(
              children: [
              Text(
              data[index],
              style: TextStyle(
                  color: UniversalVariables
                      .ScaffoldColor,
                  fontWeight:
                  FontWeight
                      .w800),)
              ],
            );
          }
      ),
    );
  }

  Widget voteList(List data) {
    return Container(
     // height: 100,
      width: 100,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return  Column(
              children: [
                Text(
                  data[index],
                  style: TextStyle(
                      color: UniversalVariables
                          .ScaffoldColor,
                      fontWeight:
                      FontWeight
                          .w800),)
              ],
            );
          }
      ),
    );
  }
  Widget percentageList(List data) {
    return Container(
     // height: 100,
      width: 100,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return  Column(
              children: [
                Text(
                  data[index],
                  style: TextStyle(
                      color: UniversalVariables
                          .ScaffoldColor,
                      fontWeight:
                      FontWeight
                          .w800),)
              ],
            );
          }
      ),
    );
  }




  getGetDetails(DocumentSnapshot _lastDocument) async {
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
    print('No More Data');
    if (_lastDocument == null) {
      pollsList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Polls")
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Polls")
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
      // querySnapshot.documents.
      //events.addAll(querySnapshot.documents);

      setState(() {
        querySnapshot.documents.forEach((element) {
          var polls = Polls();
          polls = Polls.fromJson(element.data);
          pollsList.add(polls);
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
     getGetDetails(null);

    setState(() {});
  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => addPolles());
    Navigator.push(context, route).then(onGoBack);
  }
}
