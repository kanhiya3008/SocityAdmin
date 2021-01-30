import 'dart:convert';
import 'dart:io';

import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/model/vendors.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:MyDen/constants/global.dart' as global;
class EditVendors extends StatefulWidget {
  final Vendor vendor;

  const EditVendors({Key key, this.vendor}) : super(key: key);
  @override
  _EditVendorsState createState() => _EditVendorsState();
}

class _EditVendorsState extends State<EditVendors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> list = [];

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  File _image;
  String photoUrl = "";

  bool isLoading = false;

  bool callOneFunction = false;

  TextEditingController _guardNameController = TextEditingController();
  TextEditingController _guardMobileController = TextEditingController();
  TextEditingController _guardOtherMobileController = TextEditingController();
  TextEditingController _documentTypeController = TextEditingController();
  TextEditingController _guardDutyTimingController = TextEditingController();
  TextEditingController _documentNumber = TextEditingController();


  @override
  void initState() {
    global.documentData.keys.forEach((element) => list.add(element));
    global.image = null;
    super.initState();
    read();

}


  read(){
    _guardNameController = TextEditingController(text: widget.vendor.name);
    _guardDutyTimingController = TextEditingController(text: widget.vendor.dutyTiming);
     _guardMobileController = TextEditingController(text: widget.vendor.mobileNumber);
    _guardOtherMobileController = TextEditingController(text: widget.vendor.otherMobileNumber);
    _documentNumber = TextEditingController(text: widget.vendor.documentNumber);
    _documentTypeController = TextEditingController(text: widget.vendor.documentType);

  }

  SaveOtherVendor() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Vendor vendor = Vendor(
        name: _guardNameController.text,
        mobileNumber: _guardMobileController.text,
        otherMobileNumber: _guardOtherMobileController.text,
        dutyTiming: _guardDutyTimingController.text,
        startDate: DateTime.now(),
        documentNumber: _documentNumber.text,
        documentType: _documentTypeController.text,
        enable: true,
        service: "Vendors",
        photoUrl: widget.vendor.photoUrl
      );
      Firestore.instance
          .collection('Society')
          .document(global.societyId)
          .collection("Vendors")
          .document(_documentNumber.text)
          .updateData(jsonDecode(jsonEncode(vendor.toJson())),).then((data) async {
        setState(() {
          _showDialog();
        });
      });
    }
  }


  SaveVendor()  {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      String fileName = 'Vendor/${DateTime.now()}.png';
      StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(_image);
      StorageTaskSnapshot storageTaskSnapshot;
      uploadTask.onComplete.then((value) {
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            photoUrl = downloadUrl;
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
                .then((data) async {
              setState(() {
                _showDialog();
              });
            });
          }
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Vendor',style: TextStyle(color: UniversalVariables.ScaffoldColor),),
        backgroundColor: UniversalVariables.background,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body:   SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  Form(
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
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(widget.vendor.photoUrl,fit: BoxFit.cover,),
                              )
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
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if(callOneFunction != true){
                        SaveOtherVendor();
                      }else
                      {
                        SaveVendor();
                      }
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
                                  "Update Vendor",
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
            Positioned(
              child: isLoading ?  Container(
                color: Colors.transparent,
                child: Center(child: CircularProgressIndicator(),) ,) : Container(),
            ),
          ],
        ),
      ),
    );
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
                  "Vendor is Update ",
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
    final pickedFile = await picker.getImage(source: ImageSource.camera,maxHeight:global.imageHeight,maxWidth: global.imageWidth );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        showScaffold('No image selected.');
      }
    });
  }
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: global.imageHeight,maxWidth: global.imageWidth).then((image) {
      setState(() {
        _image = image;
      });
    });
  }
}
