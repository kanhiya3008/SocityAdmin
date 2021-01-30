import 'dart:convert';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/amenity.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class addAmenity extends StatefulWidget {
  // final Amenity amenity;
  //
  // const addAmenity({Key key, this.amenity}) : super(key: key);

  @override
  _addAmenityState createState() => _addAmenityState();
}

class _addAmenityState extends State<addAmenity> {
  TextEditingController _amenityController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String operation = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  @override
  void initState() {

    //  _amenityController = TextEditingController(text: widget.amenity.amenity ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
            Padding(
              padding: EdgeInsets.all(15),
              child: ListView(
                children: [SizedBox(height: MediaQuery.of(context).size.width/4,),
                  Form(
                    key: formKey,
                    child: constantTextField().InputField(
                        "enter Amenity",
                        "",
                        validationKey.amenity,
                        _amenityController,
                        false,
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.clear,
                            )),
                        1,1,
                        TextInputType.text,
                        false),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RadioListTile(
                          groupValue: operation,
                          title: Text('Open'),
                          value: 'Open',
                          onChanged: (val) {
                            setState(() {
                              operation = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          groupValue: operation,
                          title: Text('Close'),
                          value: 'Close',
                          onChanged: (val) {
                            setState(() {
                              operation = val;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        color: UniversalVariables.background,
                        onPressed: () {
                          // if (widget.amenity != null) {
                          //   print("update success");
                          //   updateInformation();
                          // } else
                          //   {
                          //   print("add success");
                            SaveInformation();
                          },
                      //  },
                        child: Text("Submit"),
                      ),
                    ],)
                ],
              ),
            )
          ],
        )

    );
  }

  SaveInformation() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      if (operation != null && operation != '') {
        Amenity amenity = Amenity(
            amenityId: Uuid().v1(),
            amenity: _amenityController.text,
            operation: operation,
            enable: true);

        await Firestore.instance
            .collection('Society')
            .document(global.societyId)
            .collection("Amenity")
            .document(amenity.amenityId)
            .setData(jsonDecode(jsonEncode(amenity.toJson())))
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
      } else {
        showScaffold("Choose operation first");
      }
    }
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
                  "Added Successfully ",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // updateInformation() async {
  //   if (formKey.currentState.validate()) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     if (operation != null && operation != '') {
  //       Amenity amenity = Amenity(
  //           amenityId: widget.amenity.amenityId,
  //           amenity: _amenityController.text,
  //           operation: operation,
  //           enable: true);
  //
  //       await Firestore.instance
  //           .collection('Society')
  //           .document()
  //           .collection("Amenity")
  //           .document(widget.amenity.amenityId)
  //           .updateData(jsonDecode(jsonEncode(amenity.toJson())))
  //           .then((data) async {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         _showDialog();
  //       }).catchError((err) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         print(err.toString());
  //         Fluttertoast.showToast(msg: err.toString());
  //       });
  //     } else {
  //       showScaffold("Choose operation first");
  //     }
  //   }
  // }
}
