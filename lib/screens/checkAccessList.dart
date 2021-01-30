import 'dart:convert';
import 'dart:math';

import 'package:MyDen/bloc/AuthBloc.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/RWA.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/model/user_model.dart';
import 'package:MyDen/resources/firebase_repository.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MyDen/constants/global.dart' as globals;

class accessList extends StatefulWidget {
  @override
  _accessListState createState() => _accessListState();
}

class _accessListState extends State<accessList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
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
        Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).size.width / 4,
              bottom: MediaQuery.of(context).size.width / 4,
            ),
            child:
                BlocBuilder<AuthBloc, AuthBlocState>(builder: (context, state) {
              return ListView.builder(
                  itemCount: state.userData.accessList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          globals.societyId =
                              state.userData.accessList[index].id.toString();
                          savelocalCode().toSaveStringValue(societyId,
                              state.userData.accessList[index].id.toString());
                          _getToken(
                              state.userData.accessList[index].id.toString(),
                              state.userData.uid);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TabBarScreen()));
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 20, right: 20),
                                color: Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)],
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child:
                                      Text(state.userData.accessList[index].id),
                                )),
                          ],
                        ));
                  });
            }))
      ]),
    ));
  }

  _getToken(String societyId, String userId) {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      RWAModel rwaModel = RWAModel(
          RWAId: userId, enable: true, token: token);
      Firestore.instance
          .collection("Society")
          .document(societyId)
          .collection("RWA")
          .document(userId)
          .setData(jsonDecode(jsonEncode(rwaModel.toJson())), merge: true);
    });
  }
}
