

import 'dart:async';

import 'package:MyDen/administration/HousesScreen/EditHOuseDetails.dart';
import 'package:MyDen/administration/HousesScreen/generateHouseToken.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/houses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'AddHouse.dart';



class HousesScreen extends StatefulWidget {
  @override
  _HousesScreenState createState() => _HousesScreenState();
}

class _HousesScreenState extends State<HousesScreen> {
  String query = "";
  List<House> houseList = List<House>();
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();
  DateTime getSelectedStartDate = DateTime.now();
  TextEditingController searchController = new TextEditingController();


  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
   super.initState();
      getGetDetails(lastDocument);
   }
  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      print("build widget call");
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        print("load data");
        getGetDetails(lastDocument);
      }
    });
    return Scaffold(
      appBar: searchAppBar(context),

      // AppBar(
      //   title: Text('Houses',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
      //   backgroundColor: UniversalVariables.background,
      //   leading: IconButton(icon: Icon(Icons.arrow_back_ios),
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
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
          Expanded(
            child: houseList.length == 0
                ? Center(
                    child: Text("No data"),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: houseList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                    houseList[index].flatOwner,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        ),
                                  ),
                                   Spacer(),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> generateHouseToken(
                                          house: houseList[index]
                                      )));
                                    },
                                    child: Row(children: [
                                      GestureDetector(
                                          onTap: (){

                                            Route route = CupertinoPageRoute(builder: (context) =>updateHouseDetail(
                                              house: houseList[index],
                                            ));
                                            Navigator.push(context, route).then(onGoBack);
                                          },
                                          child: Icon(Icons.edit)),
                                      GestureDetector(
                                          onTap: (){
                                            _showDeletDialog(houseList[index]);

                                          },
                                          child: Icon(Icons.delete)),
                                      SizedBox(width: 10,),
                                    ]),
                                  ),
                                ]),
                                Text(
                                  "Flat No - " + houseList[index].flatNumber,
                                  style: TextStyle(
                                      fontSize: 15,
                                      ),
                                ),
                                Row(children: [

                                  Text(
                                    "Family Members - " +
                                        houseList[index].flatMember,
                                    style: TextStyle(
                                        fontSize: 15,
                                        ),
                                  ),
                                  Spacer(),
                                InkWell(
                                  onTap: (){
                                    Route route = CupertinoPageRoute(builder: (context) =>generateHouseToken(
                                      house: houseList[index],
                                    ));
                                    Navigator.push(context, route).then(onGoBack);
                                  },
                                  child:      Column(children: [
                                    Icon(Icons.compare_arrows,
                                    ),
                                    Text(
                                      "Reset Devices",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ]),
                                ),
                                  SizedBox(
                                    width: 6,
                                  )
                                ]),
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
    if (_lastDocument == null) {
      houseList.clear();
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Houses")
          .orderBy("flatNumber")
          .where("enable",isEqualTo: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Houses")
          .orderBy("flatNumber",)
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
      // querySnapshot.documents.
      //events.addAll(querySnapshot.documents);

      setState(() {
        querySnapshot.documents.forEach((element) {
          var house = House();
          house = House.fromJson(element.data);
          houseList.add(house);
        });
      });
    }
    setState(() {
      isLoading = false;
    });
  }






  Future<void> _showDeletDialog(House house) async {
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
                  "Are You sure want to Delete this House",
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
                deleteGate(house);
                deleteActivationCode(house);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  deleteGate(House house) async {
    await Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Houses")
        .document(house.houseId)
        .updateData({
      "enable": false,
    }).then((data) async {
      setState(() {
        isLoading = false;
      });
      setState(() {
        houseList.remove(house);
      });
      Fluttertoast.showToast(msg: "Delete successfully");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  deleteActivationCode(House house) async {
    await Firestore.instance
        .collection('ActivationCode')
        .document(house.houseId)
        .updateData({
      "enable": false,
    });
  }

  FutureOr onGoBack(dynamic value) {
    hasMore = true;
    print("On call back");
    getGetDetails(null);


  }

  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddHouseScreen());
    Navigator.push(context, route).then(onGoBack);
  }



  searchAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      backgroundColor: UniversalVariables.background,
      elevation: 2,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            cursorColor: Colors.black,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search Flat No. / Name",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }




}
