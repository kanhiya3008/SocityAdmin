import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/houses.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MyDen/constants/global.dart' as global;

class updateHouseDetail extends StatefulWidget {
  final House house;

  const updateHouseDetail({Key key, this.house}) : super(key: key);

  @override
  _updateHouseDetailState createState() => _updateHouseDetailState();
}

class _updateHouseDetailState extends State<updateHouseDetail> {
  TextEditingController _flatNumberController = TextEditingController();
  TextEditingController _flatOwnerController = TextEditingController();
  TextEditingController _flatMemberController = TextEditingController();
  TextEditingController _towerController = TextEditingController();
  bool isLoading = false;


  @override
  void initState() {

      read();

    super.initState();
  }

  read() {
    _flatNumberController =
        TextEditingController(text: widget.house.flatNumber);
    _flatOwnerController = TextEditingController(text: widget.house.flatOwner);
    _flatMemberController =
        TextEditingController(text: widget.house.flatMember);
    _towerController = TextEditingController(text: widget.house.tower);
  }

  SaveInformation() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      House house = House(
        houseId: widget.house.houseId,
        flatMember: _flatMemberController.text,
        flatNumber: _flatNumberController.text,
        flatOwner: _flatOwnerController.text,
        tower: _towerController.text,

        enable: true,
      );
      await Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Houses")
          .document(widget.house.houseId)
          .updateData(jsonDecode(jsonEncode(house.toJson())))
          .then((data) async {
        setState(() {
          isLoading = false;
        });
        _showDialog();
        //  Navigator.pop(context);
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
        title: Text(' Edit Houses',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
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
            bottom: -MediaQuery.of(context).size.height * .100,
            right: -MediaQuery.of(context).size.width * .4,
            child: BezierContainerThree(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ListView(
              children: [
                SizedBox(height: 10,),
                Form(
                    key: global.formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Enter Flat Number",
                            "c - 12",
                            validationKey.flatNo,
                            _flatNumberController,
                            false,
                            IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: null),
                            1,1,
                            TextInputType.name,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Enter Owner Name",
                            "Mr.Rajesh Singh",
                            validationKey.ownerName,
                            _flatOwnerController,
                            false,
                            IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: null),
                            1,1,
                            TextInputType.name,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Enter Tower Number",
                            " 67",
                            validationKey.towerNumber,
                            _towerController,
                            false,
                            IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: null),
                            1,1,
                            TextInputType.name,
                            false),
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
                            TextInputType.number,
                            false),
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
                        SaveInformation();
                      },
                      child: Card(
                          color: UniversalVariables.background,
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Update House",
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
        ],
      ),
    );
  }

  Widget _backButton() {
    return Container(
      padding: EdgeInsets.only(top: 30, right: 20, bottom: 5),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back_ios,
                    color: UniversalVariables.background),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Update Houses',
                    style: TextStyle(
                        color: UniversalVariables.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
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
                  "Update Successfully ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('ok'),
              onPressed: () {
                setState(() {
                  isLoading = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
