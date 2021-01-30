import 'dart:convert';
import 'dart:math';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/OTP.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/ActivationModel.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class addRAW extends StatefulWidget {
  @override
  _addRAWState createState() => _addRAWState();
}

class _addRAWState extends State<addRAW> {




  bool isLoading = false;

  SaveRAW() async {
      ActivationCode activationCode = ActivationCode(
          iD: global.uuid,
          type: "RWA",
          society: global.societyId,
          creationDate: DateTime.now(),
          societyId: global.tokn,
          enable: true);

      await Firestore.instance
          .collection('ActivationCode')
          .document(activationCode.iD)
          .setData(jsonDecode(jsonEncode(activationCode.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        _showDialog();
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add RWA',
          style: TextStyle(color: UniversalVariables.ScaffoldColor),
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
          bottom: -MediaQuery.of(context).size.height * .100,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainerThree(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "To Create New RWA Member, Click on below button ",
                style: TextStyle(
                    color: UniversalVariables.background,
                    fontWeight: FontWeight.w800,
                    wordSpacing: 3),
              ),
              SizedBox(
                height: 50,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 2,
                ),
                GestureDetector(
                    onTap: () {
                      global.tokn = RandomString(10);
                      global.uuid = Uuid().v1();
                      SaveRAW();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add RWA",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ])
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "RAW is Added ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('share Code'),
              onPressed: () async {
                var response = await FlutterShareMe().shareToSystem(
                  msg: global.RWATokenMsg + global.tokn,
                );
                if (response == 'success') {
                  print('navigate success');
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
