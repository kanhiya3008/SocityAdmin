import 'dart:async';
import 'package:MyDen/administration/EventsScreen/EventHistory.dart';
import 'package:MyDen/administration/NoticeScreen/EditNoticeData.dart';
import 'package:MyDen/administration/NoticeScreen/NoticeHistory.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/notice.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;
import 'AddNotice.dart';

class NoticesScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<NoticesScreen> {
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  List<Notice> noticeList = List<Notice>();

  bool isExpanding = false;
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();
  DateTime getSelectedStartDate = DateTime.now().subtract(Duration(days: -30));
  DateTime getSelectedEndDate = DateTime.now().subtract(Duration(days: -1));
  final formKey = GlobalKey<FormState>();

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
    getNoticeDetails(lastDocument);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      print("build widget call");
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getNoticeDetails(lastDocument);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notice',
          style: TextStyle(color: UniversalVariables.ScaffoldColor),
        ),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.history,
                size: 30,
              ),
              onPressed: () {
                _noticeHistory();
              })
        ],
      ),
      body: Stack(children: [
        Positioned(
          bottom: -MediaQuery.of(context).size.height * .100,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainerThree(),
        ),
        Column(children: [
          SizedBox(
            height: 10,
          ),
          //  _backButton(),
          Expanded(
            child: noticeList.length == 0
                ? Center(child: Text("No Data"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: noticeList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: GestureDetector(
                            onTap: () {
                              //  _showFullDetailsDialog(noticeList[index]);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: ExpansionTile(
                                title: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Row(children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        noticeList[index].noticeHeading,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          Route route = MaterialPageRoute(
                                              builder: (context) =>
                                                  EditNoticeData(
                                                      notice:
                                                          noticeList[index]));
                                          Navigator.push(context, route)
                                              .then(onGoBack);
                                        },
                                        child: Icon(Icons.mode_edit)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          _showDeletDialog(noticeList[index]);
                                        },
                                        child: Icon(Icons.delete)),
                                  ]),
                                ),
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Text(
                                              "Date - " +
                                                  DateFormat(global.dateFormat)
                                                      .format(noticeList[index]
                                                          .startDate),
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ]),
                                          Text(
                                            "endDate - " +
                                                DateFormat(global.dateFormat)
                                                    .format(noticeList[index]
                                                        .endDate),
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            noticeList[index].description,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                                onExpansionChanged: (bool expanding) =>
                                    setState(
                                        () => this.isExpanding = expanding),
                              ),
                            )),
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

  getNoticeDetails(DocumentSnapshot _lastDocument) async {
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
      noticeList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Notice")
          .orderBy("startDate")
          .where("startDate",
              isGreaterThanOrEqualTo:
                  DateTime.now().subtract(Duration(days: 1)).toIso8601String())
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Notice")
          .orderBy("startDate")
          .where("startDate",
              isGreaterThanOrEqualTo:
                  DateTime.now().subtract(Duration(days: 1)).toIso8601String())
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
      // querySnapshot.documents.
      //events.addAll(querySnapshot.documents);

      setState(() {
        querySnapshot.documents.forEach((element) {
          var notice = Notice();
          notice = Notice.fromJson(element.data);
          noticeList.add(notice);
        });
      });
    }

    print("load more data");
    print(noticeList.length);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _noticeHistory() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
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
                                  1,
                                  1,
                                  TextInputType.emailAddress,
                                  false
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
                                    DateTime.now()
                                        .subtract(Duration(days: 365)),
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
                                  1,
                                  1,
                                  TextInputType.emailAddress,
                                  false),
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
                Navigator.pop(context);
                updateInformation();
                //
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateInformation() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;

        Route route = MaterialPageRoute(
            builder: (context) => NoticeHistory(
                  startDate: _startDateController.text,
                  endDate: _endDateController.text,
                ));
        Navigator.push(context, route).then(onGoBack);
      });
    }
  }

  Future<void> _showDeletDialog(Notice notice) async {
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
                deleteEvent(notice);
              },
            ),
          ],
        );
      },
    );
  }

  deleteEvent(Notice notice) async {
    await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Notice")
        .document(notice.noticeId)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        isLoading = false;
      });
      setState(() {
        noticeList.remove(notice);
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

  FutureOr onGoBack(dynamic value) {
    hasMore = true;
    print("On call back");
    getNoticeDetails(null);

    setState(() {});
  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddNotice());
    Navigator.push(context, route).then(onGoBack);
  }
}
