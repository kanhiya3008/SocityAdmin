import 'dart:async';

import 'package:MyDen/administration/SocietyScreen/AddSocietyData.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/resources/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/Constants/Constant_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MyDen/constants/global.dart' as global;
class SocietyScreen extends StatefulWidget {

  @override
  _SocietyScreenState createState() => _SocietyScreenState();
}

class _SocietyScreenState extends State<SocietyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society"),
        actions: [
          Row(children: [
            Icon(Icons.my_location),
            SizedBox(
              width: 5,
            ),
          ])
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25,right: 25),
        child:  StreamBuilder(
            stream: Firestore.instance.collection('Society')
                .document(global.societyId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('loading....');
              return ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(
                        context, snapshot.data.documents[index]);
                  });
            }),
      ),

      floatingActionButton: (FloatingActionButton(
        onPressed: () {
          navigateSecondPage();
        },
        child: Icon(Icons.add),
      )),


    );
  }
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Padding(
        padding: EdgeInsets.all(0),
        child: Text(document['password']));
  }


  FutureOr onGoBack(dynamic value) {
   // hasMore = true;
    print("On call back");
  //  getGetDetails(null);

    setState(() {});
  }

  void navigateSecondPage() {
    Route route = MaterialPageRoute(builder: (context) => AddSocietyData());
    Navigator.push(context, route).then(onGoBack);
  }
}

