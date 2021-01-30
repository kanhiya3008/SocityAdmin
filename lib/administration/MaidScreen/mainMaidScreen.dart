import 'dart:async';

import 'package:MyDen/administration/MaidScreen/AddMaidScreen.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/maid.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class MaidScreen extends StatefulWidget {
  @override
  _MaidScreenState createState() => _MaidScreenState();
}

class _MaidScreenState extends State<MaidScreen> {

  List<Maid> maidList = List<Maid>();

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 4;
  DocumentSnapshot lastDocument = null;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getVendorDetails(lastDocument);
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
        getVendorDetails(lastDocument);
      }
    });
    return Scaffold(
      body: Stack(
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
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Card(child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.arrow_back_ios),
                    ),),
                  ),
                  Card(child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text("Guards",style: TextStyle(fontWeight: FontWeight.w800),),
                  ),)

                ],
              ),
            ),
            Expanded(
              child: maidList.length == 0
                  ? Center(
                child: Text("No data"),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: maidList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15),
                      child: Card(
                        elevation: 10,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      maidList[index].maidName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: (){
                                          // Route route = MaterialPageRoute(builder: (context) =>updateGuard(
                                          //   guard: guardList[index],
                                          // ));
                                          // Navigator.push(context, route).then(onGoBack);
                                        },
                                        child: Icon(Icons.edit)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                        onTap: (){
                                          //  _showDeletDialog(vendorsList[index]);

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
                                              maidList[index].photoUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                    ),
                                    SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          maidList[index].maidName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          maidList[index].mobileNumber,
                                        ),
                                        Text(
                                          maidList[index].maidName,
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                        ),
                      ));
                },
              ),
            ) ,  isLoading
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
          ]),]

      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
       navigateSecondPage();
      },

      child: Icon(Icons.add),
      ),
    );
  }

  getVendorDetails(DocumentSnapshot _lastDocument) async {
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
      maidList.clear();
      querySnapshot = await Firestore.instance
          .collection('Maid')
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('Maid')
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
      setState(() {
        querySnapshot.documents.forEach((element) {
          var maid = Maid();
          maid = Maid.fromJson(element.data);
          maidList.add(maid);
        });
      });
    }

    print("load more data");
    setState(() {
      isLoading = false;
    });
  }


  FutureOr onGoBack(dynamic value) {
   // hasMore = true;
    print("On call back");
   // getVendorDetails(null);
    setState(() {});
  }
  void navigateSecondPage() {
    Route route = CupertinoPageRoute(builder: (context) => AddMaid());
    Navigator.push(context, route).then(onGoBack);
  }
}
