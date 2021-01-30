import 'dart:io';
import 'package:MyDen/bloc/AuthBloc.dart';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/model/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';




class Profile extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  UserData _userData = UserData();

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  TextEditingController controllerNickname;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileNumber = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  var gender = [
    'Male',
    'Female',
  ];

  bool isLoading = false;
  File avatarImageFile;


  @override
  void initState() {
    _userData = context.bloc<AuthBloc>().getCurrentUser();
    _emailController = TextEditingController(text: _userData.email);
    controllerNickname = TextEditingController(text: _userData.name);
    _mobileNumber = TextEditingController(text: _userData.phoneNo);
    _genderController = TextEditingController(text: _userData.gender);
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body:  ListView(
            children: [
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2.1,
                child: Stack(
                  children: [
                    ClipPath(
                      child: Container(color: UniversalVariables.background),
                      clipper: getClipper(),
                    ),
                    Positioned(
                        right: MediaQuery
                            .of(context)
                            .size
                            .width / 3.1,
                        top: MediaQuery
                            .of(context)
                            .size
                            .height / 5.3,
                        child: Container(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (_userData.profilePhoto != ''
                                  ? Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                        ),
                                        width: 90.0,
                                        height: 90.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                  imageUrl: _userData.profilePhoto,
                                  width: 150.0,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(70.0)),
                                clipBehavior: Clip.hardEdge,
                              )
                                  : Icon(
                                Icons.account_circle,
                                size: 150.0,

                              ))
                                  : Material(
                                child: Image.file(
                                  avatarImageFile,
                                  width: 150.0,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(70.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),

                                    child: IconButton(
                                      icon: Icon(
                                        Icons.camera_alt,
                                      ),
                                      onPressed: getImage,
                                      splashColor: Colors.transparent,

                                      iconSize: 30.0,
                                    ),
                                  )
                              )

                            ],
                          ),
                        )
                    ),

                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(15),
                  child:

                  Form(
                    key: formKey,
                    child:  Column(
                      children: [
                        SizedBox(height: 10,),
                        constantTextField().InputField(
                            "name",
                            "Rohan",
                            validationKey.name,
                            controllerNickname,
                            false,
                            IconButton(icon: Icon(Icons.email), onPressed: () {}),
                            1,1,
                            TextInputType.name,false),
                        SizedBox(height: 10,),
                        constantTextField().InputField(
                            "Mobile Number",
                            "Rohan",
                            validationKey.mobileNo,
                            _mobileNumber,
                            false,
                            IconButton(icon: Icon(Icons.email), onPressed: () {}),
                            1,1,
                            TextInputType.name,false),
                        SizedBox(height: 10,),
                        constantTextField().InputField(
                            "Email id",
                            "Rohan",
                            validationKey.email,
                            _emailController,
                            false,
                            IconButton(icon: Icon(Icons.email), onPressed: () {}),
                            1,1,
                            TextInputType.name,false),
                        SizedBox(height: 10,),
                        Stack(children: [
                          IgnorePointer(
                            child: constantTextField().InputField(
                                "Enter Your Gender",
                                "Male/Female",
                                validationKey.gender,
                                _genderController,
                                false,
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.calendar_today),
                                ),
                                1,1,
                                TextInputType.name,false,),
                          ),
                          Positioned(
                              right: 0,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_downward),
                                  onSelected: (String val) {
                                    _genderController.text = val;
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return gender
                                        .map<PopupMenuItem<String>>((String val) {
                                      return new PopupMenuItem(
                                          child: new Text(val), value: val);
                                    }).toList();
                                  },
                                ),
                              ))
                        ]),

                        SizedBox(height: 50,),
                        RaisedButton(
                          child: Text("Update Profile"),
                          onPressed: () {
                            uploadDetail();
                          },
                        ),


                      ],
                    ),
                  )
              )

            ],
          )

    );
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery,);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }



  Future uploadFile() async {
    String photoUrl;
    final userid = _userData.uid;
    String fileName = userid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance.collection('users').document(userid).updateData({
            'photoUrl': photoUrl
          }).then((data)  {
           // await savelocalCode().toSaveStringValue(profile, photoUrl);
            Fluttertoast.showToast(msg: "Upload Successful");
            _userData.profilePhoto = photoUrl;
            context.bloc<AuthBloc>().updateUser(_userData);
          }).catchError((err) {
            Fluttertoast.showToast(msg: err.toString());
            print("gggggggggggg${err.toString()}");

          });
        }, onError: (err) {
          showScaffold("This file is not an image");
        });
      } else {
        showScaffold('This file is not an image');
      }
    }, onError: (err) {
      Fluttertoast.showToast(msg: err.toString());
      print("hhhhhhhh${err.toString()}");
    });
  }

   uploadDetail() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _userData.email = _emailController.text;
      _userData.name = controllerNickname.text;
      _userData.phoneNo = _mobileNumber.text;
      _userData.gender = _genderController.text;
    Firestore.instance.collection('users').document(_userData.uid).updateData({
      "email": _userData.email,
      "name": _userData.name,
      "phoneNo": _userData.phoneNo,
      "gender": _userData.gender,
    }).then((data) async {
      context.bloc<AuthBloc>().updateUser(_userData);
      showScaffold("Update Successfully");
    });
  }
  }
}

class getClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height / 1);
    path.lineTo(size.width + 140, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
