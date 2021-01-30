import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/OTP.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/ActivationModel.dart';
import 'package:MyDen/model/houses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/Constants/Constant_colors.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class AddHouseScreen extends StatefulWidget {
  @override
  _AddHouseScreenState createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  TextEditingController _flatNumberController = TextEditingController();
  TextEditingController _flatOwnerController = TextEditingController();
  TextEditingController _flatMemberController = TextEditingController();
  TextEditingController _towerController = TextEditingController();
  TextEditingController _tokenController = TextEditingController();
 TextEditingController _areaController = TextEditingController();
  bool isLoading = false;

  SaveInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
    //
      House house = House(
          houseId: global. uuid,
          flatMember: _flatMemberController.text,
          flatNumber: _flatNumberController.text,
          flatOwner: _flatOwnerController.text,
          tower: _towerController.text,
          enable: true,
          enableId: global.houseEnableId,
          area: _areaController.text,
        );
      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Houses")
          .document(house.houseId)
          .setData(jsonDecode(jsonEncode(house.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        createMembers(house.houseId);
        _showDialog();
        SaveActivation();

        //  Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }
  }

  SaveActivation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      ActivationCode activationCode = ActivationCode(
          iD: global.uuid,
          type: "Residents",
          enableId: global.houseEnableId,
          society: global.societyId,
          master: true,
          flatNo: _flatNumberController.text,
          creationDate: DateTime.now(),
          societyId: _tokenController.text,
          enable: true);

      await Firestore.instance
          .collection('ActivationCode')
          .document(activationCode.enableId)
          .setData(jsonDecode(jsonEncode(activationCode.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Houses',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
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
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(
            children: [
              Form(
                  key: global.formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter Flat Number",
                          "",
                          validationKey.flatNo,
                          _flatNumberController,
                          false,
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: null),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter area",
                          "",
                          validationKey.houseArea,
                          _areaController,
                          false,
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: null),
                          1,1,
                          TextInputType.number,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter Owner Name",
                          "Mr.Rajesh Singh",
                          validationKey.name,
                          _flatOwnerController,
                          false,
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: null),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter Tower Number",
                          "",
                          validationKey.towerNumber,
                          _towerController,
                          false,
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: null),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Enter Family Number",
                          "3",
                          validationKey.familyMember,
                          _flatMemberController,
                          false,
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: null),
                          1,1,
                          TextInputType.number,false),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
              SizedBox(
                height: 50,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 2,
                ),
                GestureDetector(
                    onTap: () {
                     // SaveInformation();
                      CheckHouseDetail();

                    },
                    child: Card(
                      color:  UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add House",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ])
            ],
          ),
        ),
        Positioned(
          child: isLoading
              ? Container(
            color: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Container(),
        ),
      ]),
    );
  }



  Future<void> _showDialog() async {
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
                  " House Add Successfully ",
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
                  msg:
                     global.RWATokenMsg +
                          _tokenController.text,
                );
                if (response == 'success') {

                }
                setState(() {
                  isLoading = false;
                });
                Navigator.pop(context);
                _flatNumberController.clear();
                _areaController.clear();
                _flatOwnerController.clear();
                _towerController.clear();
                _flatMemberController.clear();
              },
            ),
          ],
        );
      },
    );
  }



  createMembers(String houseId){
    Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Houses")
        .document(houseId).collection("members").document().setData({'example':"test"}) ;
    
  }



  CheckHouseDetail(){
    Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Houses").getDocuments().then((value) {
          value.documents.forEach((element) {
            if(element['flatNumber'] == _flatNumberController.text){
              _showCheckHouse(element['flatOwner']);
              return;
            } else{
              _tokenController.text = RandomString(10);
              global.uuid = Uuid().v1();
              global.houseEnableId = Uuid().v1();
              SaveInformation();
            }
          });
    });
  }



  Future<void> _showCheckHouse(String name) async {
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
                  " This Flat Number is already registered to " + name,
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('ok'),
              onPressed: ()  {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


}

//489871
