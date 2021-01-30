
import 'dart:convert';
import 'dart:io';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/ActivationModel.dart';
import 'package:MyDen/model/guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;

class AddGuardData extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}
class _AddEventsState extends State<AddGuardData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  List<String> list=[] ;

  @override
  void initState() {
    global.documentData.keys.forEach((element) => list.add(element));

    super.initState();
    global.image = null;

  }

  TextEditingController _guardCompanyController = TextEditingController();
  TextEditingController _guardNameController = TextEditingController();
  TextEditingController _guardMobileController = TextEditingController();
  TextEditingController _guardOtherMobileController = TextEditingController();
  TextEditingController _guardStartDateController = TextEditingController();
  TextEditingController _guardDutyTimingController = TextEditingController();
  TextEditingController _documentNameController = TextEditingController();
  TextEditingController _documentNumberController = TextEditingController();
  TextEditingController _paymentController = TextEditingController();
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

  // SaveGuard() async {
  //   ActivationCode activationCode = ActivationCode(
  //       iD: global.uuid,
  //       type: "Guard",
  //       society: global.societyId,
  //       creationDate: DateTime.now(),
  //       societyId: global.tokn,
  //       enable: true);
  //
  //   await Firestore.instance
  //       .collection('ActivationCode')
  //       .document(activationCode.iD)
  //       .setData(jsonDecode(jsonEncode(activationCode.toJson())))
  //       .then((data) async {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     _showDialog();
  //   }).catchError((err) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(msg: err.toString());
  //   });
  //
  // }



  AddDataToSociety(String photoUrl,String guardId) {
    Guard guard = Guard(
      guardId: guardId,
        guardCompanyName: _guardCompanyController.text,
        guardName: _guardNameController.text,
        mobileNumber: _guardMobileController.text,
        otherMobileNumber: _guardOtherMobileController.text,
        dutyTiming: _guardDutyTimingController.text,
        startDate: DateFormat(global.dateFormat).parse(_guardStartDateController.text),
        photoUrl:photoUrl,
        documentNumber: _documentNumberController.text,
        enable: true,
        guardSalary: _paymentController.text,
        documentType: _documentNameController.text,
        service: global.GUARD);
    Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Guards")
        .document(guard.guardId)
        .setData(jsonDecode(jsonEncode(guard.toJson()))

     );
  }

  // AddDataToSociety() async {
  //   await Firestore.instance
  //       .collection('Society')
  //       .document(global.societyId)
  //       .collection("Guards")
  //       .document(global.societyId)
  //       .setData({
  //     "details": FieldValue.arrayUnion([
  //       {
  //         "id": _documentNumberController.text,
  //         "status": true,
  //       }
  //     ])
  //   }, merge: true);
  // }

  SaveInformation() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      if (global.image != null) {


        String fileName = global.GUARD + '/${DateTime.now()}.png';
        StorageReference reference =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = reference.putFile(global.image);
        StorageTaskSnapshot storageTaskSnapshot;
        uploadTask.onComplete.then((value) {
          if (value.error == null) {
            storageTaskSnapshot = value;
            storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
              global.photoUrl = downloadUrl;

              Guard guard = Guard(
                 guardId: Uuid().v1(),
                  guardCompanyName: _guardCompanyController.text,
                  guardName: _guardNameController.text,
                  mobileNumber: _guardMobileController.text,
                  otherMobileNumber: _guardOtherMobileController.text,
                  dutyTiming: _guardDutyTimingController.text,
                  startDate: DateFormat(global.dateFormat).parse(_guardStartDateController.text),
                  photoUrl: global.photoUrl,
                  documentNumber: _documentNumberController.text,
                  enable: true,
                  guardSalary: _paymentController.text,
                  documentType: _documentNameController.text,
                  service: global.GUARD);
              Firestore.instance
                  .collection("LocalServices")
                  .document(guard.guardId)
                  .setData(jsonDecode(jsonEncode(guard.toJson())))
                  .then((data) {
                History history = History(
                    guardId:_documentNumberController.text,
                    startDate: DateFormat(global.dateFormat)
                        .parse(_guardStartDateController.text),
                    societyID: global.societyId);
                Firestore.instance
                    .collection("LocalServices")
                    .document(guard.guardId)
                    .collection("records")
                    .document(guard.guardId)
                    .setData(jsonDecode(jsonEncode(history.toJson())))
                    .then((value) => setState(() {
                  AddDataToSociety( global.photoUrl,guard.guardId);
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
      } else {
        isLoading = false;
        showScaffold("Add Guard photo first");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Society Guard',
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
      key: _scaffoldKey,
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Form(
                    key: global.formKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            IgnorePointer(
                              child: constantTextField().InputField(
                                  "Select Document Type",
                                  "",
                                  validationKey.validDocumentType,
                                  _documentNameController,
                                  false,
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed: () {},
                                  ),
                                  1,
                                  1,
                                  TextInputType.name,
                                  false),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_downward),
                                  onSelected: (String val) {
                                    _documentNameController.text = val;
                                    setState(() {
                                      global.changeValidation = global.documentData[val];
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return
                                      list
                                          .map<PopupMenuItem<String>>((String val) {
                                        return new PopupMenuItem(
                                            child: new Text(val), value: val);
                                      }
                                      ).toList();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Guard Document Number",
                            "",
                            global.changeValidation,
                            _documentNumberController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Enter Salary",
                            "",
                            validationKey.payment,
                            _paymentController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.number,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Guard Company Name",
                            "abc.pvt.ltd",
                            validationKey.companyName,
                            _guardCompanyController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Guard Name",
                            "",
                            validationKey.name,
                            _guardNameController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.name,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Mobile No",
                            "",
                            validationKey.mobileNo,
                            _guardMobileController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.number,
                            false),
                        SizedBox(
                          height: 10,
                        ),
                        constantTextField().InputField(
                            "Other Mobile No",
                            "",
                            validationKey.mobileNo,
                            _guardOtherMobileController,
                            false,
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {},
                            ),
                            1,
                            1,
                            TextInputType.number,
                            false),
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
                                  1,
                                  1,
                                  TextInputType.name,
                                  false)),
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
                              child: global.image != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  global.image.path,
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
                                    _choosePhotoFrom();

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
                        InkWell(
                            onTap: () {
                              showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: DateTime.now().hour,
                                      minute: DateTime.now().minute))
                                  .then((TimeOfDay value) {
                                if (value != null) {
                                  _guardDutyTimingController.text =
                                      value.format(context);
                                }
                              });
                            },
                            child: IgnorePointer(
                              child: constantTextField().InputField(
                                  "Duty Timing",
                                  "6:00 am to 9:00 am ",
                                  validationKey.time,
                                  _guardDutyTimingController,
                                  true,
                                  IconButton(
                                    icon: Icon(Icons.access_time),
                                  ),
                                  1,
                                  1,
                                  TextInputType.emailAddress,
                                  false),
                            )),
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
                                        "Add Guards",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    )),
                              ]),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
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



  Future<void> _choosePhotoFrom() async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Photo From"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    chooseFileFromCamera();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Camera",
                    style: TextStyle(color: UniversalVariables.background),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    chooseFile();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Gallery",
                    style: TextStyle(color: UniversalVariables.background),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }



  Future chooseFileFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality:global.imageQuelity );

    setState(() {
      if (pickedFile != null) {
        global.image = File(pickedFile.path);
      } else {
        showScaffold('No image selected.');
      }
    });
  }
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: global.imageQuelity,

    ).then((image) {
      setState(() {
        global.image = image;
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

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
