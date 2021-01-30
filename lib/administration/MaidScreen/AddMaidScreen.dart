import 'dart:convert';
import 'dart:io';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/maid.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class AddMaid extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<AddMaid> {
  String constantUid = Uuid().v1();

  File _image;

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController _guardNameController = TextEditingController();
  TextEditingController _guardMobileController = TextEditingController();
  TextEditingController _guardOtherMobileController = TextEditingController();
  TextEditingController _guardStartDateController = TextEditingController();
  TextEditingController _guardDutyTimingController = TextEditingController();
  TextEditingController _adharCardController = TextEditingController();

  Future<Null> _selectDate(
      BuildContext context, DateTime firstDate, DateTime lastDate) async {
    DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      selectedDate = picked;
    String _formattedate =
    new DateFormat(global.dateFormat).format(selectedDate);
    setState(() {
      _guardStartDateController.value = TextEditingValue(text: _formattedate);
    });
  }

  SaveInformation() {
    String photoUrl = "";
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      String fileName = 'Maids/${DateTime.now()}.png';
      StorageReference reference =
      FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(_image);
      StorageTaskSnapshot storageTaskSnapshot;
      uploadTask.onComplete.then((value) {
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            photoUrl = downloadUrl;
            Maid maid = Maid(
              maidName: _guardNameController.text,
              mobileNumber: _guardMobileController.text,
              otherMobileNumber: _guardOtherMobileController.text,
              dutyTiming: _guardDutyTimingController.text,
              startDate: DateFormat(global.dateFormat).parse(_guardStartDateController.text),
              photoUrl: photoUrl,
              enable: true,
              adharCard: _adharCardController.text
            );
            Firestore.instance
            //  prefs.get("activationCode")
                .collection("Maid")
                .document(_adharCardController.text)
                .setData(jsonDecode(jsonEncode(maid.toJson())))
                .then((data) {
              History history = History(
                  maidId: Uuid().v1(),
                  startDate: DateFormat(global.dateFormat).parse(_guardStartDateController.text),
                  societyID: global.societyId);
              Firestore.instance
                  .collection("Maid")
                  .document(_adharCardController.text)
                  .collection("records")
                  .document(history.maidId)
                  .setData(jsonDecode(jsonEncode(history.toJson())))
                  .then((value) => setState(() {
                _showDialog();
              }));
            });
          });
        }
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
      body: Stack(children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * .15,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainer(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: ListView(
            children: [
              _backButton(),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      constantTextField().InputField(
                          "Maid AudharCard Number",
                          "",
                          validationKey.companyName,
                          _adharCardController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Maid Name",
                          "",
                          validationKey.name,
                          _guardNameController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Mobile No",
                          "abc.pvt.ltd",
                          validationKey.mobileNo,
                          _guardMobileController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,1,
                          TextInputType.number,false),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Other Mobile No",
                          "abc.pvt.ltd",
                          validationKey.mobileNo,
                          _guardOtherMobileController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,1,
                          TextInputType.number,false),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          _selectDate(
                              context,
                              DateTime.now().subtract(Duration(days: 0)),
                              DateTime.now().add(Duration(days: 365)));
                        },
                        child: IgnorePointer(
                            child: constantTextField().InputField(
                                "Start Date",
                                "",
                                validationKey.date,
                                _guardStartDateController,
                                true,
                                IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () {},
                                ),
                                1,1,
                                TextInputType.name,false)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black54),
                            ),
                            child: _image != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _image.path,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Icon(
                              Icons.person,
                              size: 90,
                            ),
                          ),
                          Spacer(),
                          Card(
                              color: UniversalVariables.background,
                              elevation: 10,
                              child: GestureDetector(
                                onTap: () {
                                  chooseFile();
                                  //getImage(true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Choose Image",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      constantTextField().InputField(
                          "Duty Timing",
                          "abc.pvt.ltd",
                          validationKey.time,
                          _guardDutyTimingController,
                          false,
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {},
                          ),
                          1,1,
                          TextInputType.name,false),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          SaveInformation();
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                  color: UniversalVariables.background,
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Add Maid",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )),
                            ]),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container(),
        ),
      ]),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(top: 25),
        child: Row(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back_ios,
                    color: UniversalVariables.background),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Society Maid',
                    style: TextStyle(
                        color: UniversalVariables.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
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
                  "Guard is Added ",
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

// getImage(bool isCamera) async {
//   //File image;
//
//   if (isCamera) {
//     _image = await ImagePicker.pickImage(source: ImageSource.camera);
//   } else {
//     _image = await ImagePicker.pickImage(source: ImageSource.gallery);
//   }
//
//   setState(() {
//     _image = _image;
//   });
// }

//
// Future uploadFile() async {
//   String fileName = "Guard";
//   StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
//   StorageUploadTask uploadTask = reference.putFile(_image);
//   StorageTaskSnapshot storageTaskSnapshot;
//   uploadTask.onComplete.then((value) {
//     if (value.error == null) {
//       storageTaskSnapshot = value;
//       storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//         photoUrl = downloadUrl;
//         Firestore.instance.collection('Society')
//             .document("1").collection("Guards")..document(Uuid().v1()).setData({
//           'photoUrl': photoUrl
//         });
//       }
//       );
//     }
//   }
//   );
// }
}
