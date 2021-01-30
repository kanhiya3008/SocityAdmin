import 'dart:async';

import 'package:MyDen/administration/AmenityScreen/addAmenity.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/amenity.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'editAmenity.dart';
class AmenityScreen extends StatefulWidget {
  @override
  _AmenityScreenState createState() => _AmenityScreenState();
}

class _AmenityScreenState extends State<AmenityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  List<Amenity> amenityList = List<Amenity>();
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {

      getGetDetails(lastDocument);

    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amenity',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
            bottom: 60,
            left: -MediaQuery.of(context).size.width * .4,
            child: BezierContainerTwo(),
          ),
          Column(
            children: [
              SizedBox(height: 10,),
              Expanded(
                child: amenityList.length == 0
                    ? Center(
                  child: Text("No data"),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: amenityList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(children: [
                                Container(
                                  width: MediaQuery.of(context).size.width/1.5,
                                  child:  Text(
                                    amenityList[index].amenity,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: UniversalVariables.background),overflow: TextOverflow.ellipsis,maxLines: 1,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                    onTap: (){
                                      Route route = CupertinoPageRoute(builder: (context) =>editAmenity(
                                        amenity: amenityList[index],
                                      ));
                                      Navigator.push(context, route).then(onGoBack);
                                    },
                                    child: Icon(Icons.edit)),
                                GestureDetector(
                                    onTap: (){
                                      _showDeletDialog(amenityList[index]);

                                    },
                                    child: Icon(Icons.delete)),

                              ]),
                              Text(
                                amenityList[index].operation,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: UniversalVariables.background),)
                            ],
                          ),
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
            ],
          ),
        ],
      ),



      floatingActionButton: (FloatingActionButton(
        onPressed: () {
          navigateSecondPage();
        },
        child: Icon(Icons.add),
      )),
    );
  }


  getGetDetails(DocumentSnapshot _lastDocument) async {
    int documentLimit = 10;
    if (!hasMore) {
      showScaffold("No More Data");
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
      amenityList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Amenity")
          .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      print('No call data');
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Amenity")
          .startAfterDocument(_lastDocument)
          .where("enable",isEqualTo: true)
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
          var amenity = Amenity();
          amenity = Amenity.fromJson(element.data);
          amenityList.add(amenity);
        });
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showDeletDialog(Amenity amenity) async {
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
                  "Are You sure want to Delete this Amenity",
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
                delete(amenity);
              },
            ),
          ],
        );
      },
    );
  }

  delete(Amenity amenity) async {
    await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Amenity")
        .document(amenity.amenityId)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        isLoading = false;
      });
      setState(() {
        amenityList.remove(amenity);
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
     getGetDetails(null);

    setState(() {});
  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => addAmenity());
    Navigator.push(context, route).then(onGoBack);
  }
}
