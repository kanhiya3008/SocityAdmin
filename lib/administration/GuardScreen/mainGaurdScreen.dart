import 'dart:async';
import 'package:MyDen/administration/RWAScreen/addAnotherRAW.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/guard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'EditGuardData.dart';
import 'addGaurd.dart';
import 'package:MyDen/constants/global.dart' as globals;

class AddGuard extends StatefulWidget {
  @override
  _VendorsScreenState createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<AddGuard> {
  List<Guard> guardList = List<Guard>();

  List<String> list = [];

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {

    getGuardDetails(lastDocument: null);
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getGuardDetails(lastDocument: null);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Guards',
              style: TextStyle(color: UniversalVariables.ScaffoldColor),
            ),
          ],
        ),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: [
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
            height: 10,
          ),
          Expanded(
            child: guardList.length == 0
                ? Center(
                    child: Text("No data"),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: guardList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Card(
                            elevation: 10,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                       Container(

                                         width: MediaQuery.of(context).size.width/1.5,
                                         child: Text(
                                           guardList[index].guardName,
                                           style: TextStyle(
                                               fontWeight: FontWeight.w800,
                                               fontSize: 20),
                                         ),
                                       ),
                                        Spacer(),
                                        GestureDetector(
                                            onTap: () {
                                              Route route = CupertinoPageRoute(
                                                  builder: (context) =>
                                                      updateGuard(
                                                        guard: guardList[index],
                                                      ));
                                              Navigator.push(context, route)
                                                  .then(onGoBack);
                                            },
                                            child: Icon(Icons.edit)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              _showDeletDialog(
                                                  guardList[index]);
                                            },
                                            child: Icon(Icons.delete)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.black,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black54),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Container(
                                              height: 110,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              UniversalVariables
                                                                  .background),
                                                    ),
                                                    width: 50.0,
                                                    height: 50.0,
                                                    padding: EdgeInsets.only(
                                                        left: 15,
                                                        top: 20,
                                                        right: 15,
                                                        bottom: 20),
                                                  ),
                                                  imageUrl:
                                                      guardList[index].photoUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width/1.8,
                                              child: Text(
                                              guardList[index].guardCompanyName,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800),
                                            ),),
                                            Text(
                                              guardList[index].mobileNumber,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width/1.8,
                                              child: Text(
                                                guardList[index].guardName,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                )),
                          ));
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

  getGuardDetails({DocumentSnapshot lastDocument}) async {
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
    if (lastDocument == null) {
      guardList.clear();
      querySnapshot = await Firestore.instance
          .collection(globals.SOCIETY)
          .document(globals.societyId)
           .collection("Guards")
          .where("enable", isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection(globals.SOCIETY)
          .document(globals.societyId)
          .collection("Guards")
          .where("enable", isEqualTo: true)
          .startAfterDocument(lastDocument)
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
          var notice = Guard();
          notice = Guard.fromJson(element.data);
          guardList.add(notice);
        });
      });
    }

    print("load more data");
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showDeletDialog(Guard guard) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are You sure want to Delete this Guard",
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
                deleteGuard(guard);
              },
            ),
          ],
        );
      },
    );
  }

  deleteGuard(Guard guard) async {
    await Firestore.instance
        .collection('LocalServices')
        .document(guard.documentNumber)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        isLoading = false;
      });
      setState(() {
        guardList.remove(guard);
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

  getSocietGuards() {
    Firestore.instance
        .collection("Society")
        .document(globals.societyId)
        .collection("Guards")
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        print("bbbbb ");
        element['details'].forEach((element2){
          list.add(element2['id']) ;

        });
      });
      list.forEach((element) {
        print("code ${element.toString()}");
       // getGuardDetails(lastDocument: lastDocument,documentId:element.toString());
      }

      );
    });
  }





  FutureOr onGoBack(dynamic value) {
    hasMore = true;
    print("On call back");
    getGuardDetails(lastDocument: null);
    setState(() {});
  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddGuardData());
    Navigator.push(context, route).then(onGoBack);
  }
}
