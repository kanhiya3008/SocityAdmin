import 'dart:convert';

import 'dart:io';
import 'dart:math';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/vendors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;
class AddVendors extends StatefulWidget {


  @override
  _AddAllLocalServiceState createState() => _AddAllLocalServiceState();
}

class _AddAllLocalServiceState extends State<AddVendors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
  List<String> list = [];

  bool isExpanded = false;
  var checkSelectedType = "";




  @override
  void initState(){
    global.documentData.keys.forEach((element) => list.add(element));
    global.image = null;

    super.initState();

  }




  bool isLoading = false;
  TextEditingController _guardNameController = TextEditingController();
  TextEditingController _guardMobileController = TextEditingController();
  TextEditingController _guardOtherMobileController = TextEditingController();
  TextEditingController _documentTypeController = TextEditingController();
  TextEditingController _guardDutyTimingController = TextEditingController();
  TextEditingController _documentNumber = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  AddDataToSociety(String photourl)  {

    Vendor vendor = Vendor(
        name: _guardNameController.text,
        mobileNumber: _guardMobileController.text,
        otherMobileNumber: _guardOtherMobileController.text,
        dutyTiming: _guardDutyTimingController.text,
        startDate: DateTime.now(),
        photoUrl: photourl,
        documentNumber: _documentNumber.text,
        documentType: _documentTypeController.text,
        enable: true,
        service: "Vendors",
        password: _passwordController.text

    );
    Firestore.instance
        .collection('Society')
        .document(global.societyId)
        .collection("Vendors")
        .document(_documentNumber.text)
        .setData(jsonDecode(jsonEncode(vendor.toJson())),merge: true);
  }


  SaveInformation() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;

      });
      if(global.image != null){

        String fileName = "Vendors" +'/${DateTime.now()}.png';
        StorageReference reference =
        FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = reference.putFile(global.image);
        StorageTaskSnapshot storageTaskSnapshot;
        uploadTask.onComplete.then((value) {
          if (value.error == null) {
            storageTaskSnapshot = value;
            storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
              global.photoUrl = downloadUrl;
              AddDataToSociety(global.photoUrl);
              Vendor vendor = Vendor(
                name: _guardNameController.text,
                mobileNumber: _guardMobileController.text,
                otherMobileNumber: _guardOtherMobileController.text,
                dutyTiming: _guardDutyTimingController.text,
                startDate: DateTime.now(),
                photoUrl: global.photoUrl,
                documentNumber: _documentNumber.text,
                documentType: _documentTypeController.text,
                enable: true,
                service: "Vendors",
              );
              Firestore.instance
                  .collection("LocalServices")
                  .document(_documentNumber.text)
                  .setData(jsonDecode(jsonEncode(vendor.toJson())),merge: true)
                  .then((data) {
                History history = History(
                    Id: Uuid().v1(),
                    startDate: DateTime.now(),
                    societyID:global.societyId);
                Firestore.instance
                    .collection("LocalServices")
                    .document(_documentNumber.text)
                    .collection("records")
                    .document(history.Id)
                    .setData(jsonDecode(jsonEncode(history.toJson())),merge: true)
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

        });

      }else{
        isLoading = false;
        showScaffold("Add " + "Vendors" + " photo First");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: UniversalVariables.background,
        title: Text("Vendors"),
      ),
      body:  Stack(children: [
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
                                _documentTypeController,
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
                                  _documentTypeController.text = val;
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
                          _documentNumber,
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
                          "Vendors" + " Name",
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
                          "",
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
                          "",
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
                                    minute: DateTime.now().minute)).then((TimeOfDay value ) {

                              if(value != null){
                                _guardDutyTimingController.text = value.format(context);
                              }
                            });
                          },
                          child:IgnorePointer(
                            child:  constantTextField().InputField(
                                "Timing",
                                "6:00 am to 9:00 am ",
                                validationKey.time,
                                _guardDutyTimingController,
                                true,
                                IconButton(
                                  icon: Icon(Icons.access_time),
                                ),
                                1,1,TextInputType.emailAddress,false),
                          )
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {

                          int min = 1000;
                          int max = 9999;
                          var randomizer = new Random();
                          var rNum = min + randomizer.nextInt(max - min);
                          _passwordController.text = rNum.toString();

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
                                      "Add " + "Vendors",
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
                  onTap: (){
                    chooseFileFromCamera();
                    Navigator.pop(context);
                  },
                  child:  Text(
                    "Camera",
                    style: TextStyle(color: UniversalVariables.background),
                  ),
                ),
                SizedBox(height: 10,),
                InkWell(
                  onTap: (){
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Vendors" + " is Added ",
                  style: TextStyle(color: UniversalVariables.background),
                ),
                Text(
                  "Password of" + " Vendors " + ": "+ _passwordController.text,
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
                onTap: () async {
                  var response = await FlutterShareMe().shareToSystem(
                      msg: global.RWATokenMsg + _passwordController.text);
                  if (response == 'success') {}
                  Navigator.pop(context);
                  setState(() {
                    isLoading = false;
                  });
                },
                child: Container(
                    color: UniversalVariables.background,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.share,
                        color: UniversalVariables.ScaffoldColor,
                        size: 30,
                      ),
                    )))
          ],
        );
      },
    );
  }
}
