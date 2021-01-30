import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/guard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;

class updateGuard extends StatefulWidget {
  final Guard guard;

  const updateGuard({Key key, this.guard}) : super(key: key);

  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<updateGuard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  bool isLoading = false;

  bool callOneFunction = false;
  DateTime getSelectedStartDate = DateTime.now();
  TextEditingController _guardCompanyController = TextEditingController();
  TextEditingController _guardNameController = TextEditingController();
  TextEditingController _guardMobileController = TextEditingController();
  TextEditingController _guardOtherMobileController = TextEditingController();
  TextEditingController _guardStartDateController = TextEditingController();
  TextEditingController _guardDutyTimingController = TextEditingController();
  TextEditingController _documentNameController = TextEditingController();
  TextEditingController _documentNumberController = TextEditingController();
  TextEditingController _paymentController = TextEditingController();
  List<String> list = [];
  @override
  void initState() {
    global.documentData.keys.forEach((element) => list.add(element));
    read();
    super.initState();
  }

  void read() {
    _guardNameController = TextEditingController(text: widget.guard.guardName);
    _guardCompanyController =
        TextEditingController(text: widget.guard.guardCompanyName);
    _guardMobileController =
        TextEditingController(text: widget.guard.mobileNumber);
    _guardOtherMobileController =
        TextEditingController(text: widget.guard.otherMobileNumber);
    _guardStartDateController = TextEditingController(
        text: DateFormat(global.dateFormat).format(widget.guard.startDate));
    _guardDutyTimingController =
        TextEditingController(text: widget.guard.dutyTiming);
    _documentNumberController = TextEditingController(text: widget.guard.documentNumber);
    _documentNameController = TextEditingController(text: widget.guard.documentType);
    _paymentController = TextEditingController(text: widget.guard.guardSalary);
  }

  Future<Null> _selectDate(BuildContext context, DateTime firstDate,
      DateTime lastDate, DateTime selectedDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null)
      setState(() {
        String formatDate = new DateFormat(global.dateFormat).format(picked);
        getSelectedStartDate = picked;
        _guardStartDateController.value = TextEditingValue(text: formatDate);
      });
  }

  SaveOtherVendor() async {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Guard guard = Guard(
          guardCompanyName: _guardCompanyController.text,
          guardName: _guardNameController.text,
          mobileNumber: _guardMobileController.text,
          otherMobileNumber: _guardOtherMobileController.text,
          startDate: DateFormat(global.dateFormat)
              .parse(_guardStartDateController.text),
          dutyTiming: _guardDutyTimingController.text,
          photoUrl: widget.guard.photoUrl,
          enable: true,
          documentNumber: _documentNumberController.text,
          documentType: _documentNameController.text,
          guardSalary:  _paymentController.text,
          service: widget.guard.service);
      await Firestore.instance
          .collection('LocalServices')
          .document(widget.guard.documentNumber)
          .updateData(jsonDecode(jsonEncode(guard.toJson())))
          .then((data) async {
        setState(() {
          _showDialog();
        });
      });
    }
  }

  SaveInformation() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      String fileName = 'Guards/${DateTime.now()}.png';
      StorageReference reference =
          FirebaseStorage.instance.ref().child("fileName");
      StorageUploadTask uploadTask = reference.putFile(global.image);
      StorageTaskSnapshot storageTaskSnapshot;
      uploadTask.onComplete.then((value) {
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            global.photoUrl = downloadUrl;
            Guard guard = Guard(
                guardCompanyName: _guardCompanyController.text,
                guardName: _guardNameController.text,
                mobileNumber: _guardMobileController.text,
                otherMobileNumber: _guardOtherMobileController.text,
                dutyTiming: _guardDutyTimingController.text,
                startDate: DateFormat(global.dateFormat).parse(_guardStartDateController.text),
                photoUrl: global.photoUrl ?? widget.guard.photoUrl,
                guardSalary:  _paymentController.text,
                documentNumber: _documentNumberController.text,
                documentType: _documentNameController.text,
                enable: true,
                guardId: widget.guard.guardId,
                service: widget.guard.service);
            print("guardDEtail");
            print(jsonEncode(guard.toJson()));
            Firestore.instance
                .collection(global.SOCIETY)
              .document(global.societyId)
              .collection("Guards")
                .document(widget.guard.guardId)
                .setData(
                  jsonDecode(jsonEncode(guard.toJson())),merge: true
                )
                .then((data) {
              Firestore.instance
                  .collection("LocalServices")
                  .document(widget.guard.guardId)
                  .setData(jsonDecode(jsonEncode(guard.toJson())),merge: true);
              _showDialog();

            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Edit Society Guard',
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
          top: -MediaQuery.of(context).size.height * .15,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainer(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: ListView(
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
                          "abc.pvt.ltd",
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
                          "abc.pvt.ltd",
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
                              DateTime.now().subtract(Duration(days: 365)),
                              DateTime.now().subtract(Duration(days: 1)),
                              DateTime.now().subtract(Duration(days: 31)));
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
                                : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            widget.guard.photoUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        )

                          ),
                          Spacer(),
                          Card(
                              color: UniversalVariables.background,
                              elevation: 10,
                              child: GestureDetector(
                                onTap: () {
                                  _choosePhotoFrom();
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
                         //  if (callOneFunction != true) {
                         //    SaveOtherVendor();
                         //  } else {
                         //    SaveInformation();
                         //  }
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
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
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
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        maxHeight: global.imageHeight,
        maxWidth: global.imageWidth);

    setState(() {
      if (pickedFile != null) {
        global.image = File(pickedFile.path);
        callOneFunction = true;
      } else {
        showScaffold('No image selected.');
      }
    });
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: global.imageHeight,
            maxWidth: global.imageWidth)
        .then((image) {
      setState(() {
        callOneFunction = true;
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
                  "Guard Detail is Update ",
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
