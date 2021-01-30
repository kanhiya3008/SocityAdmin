import 'dart:math';
import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/OTP.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/gate.dart';
import 'package:MyDen/model/houses.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/HomeScreen.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:MyDen/constants/global.dart' as global;




class generateHouseToken extends StatefulWidget {
  final  House house;

  const generateHouseToken({Key key, this.house}) : super(key: key);
  @override
  _generateNewTokenState createState() => _generateNewTokenState();
}

class _generateNewTokenState extends State<generateHouseToken> {


  bool isLoading = false;

  TextEditingController _controller = TextEditingController();


//
//   updateToken() {
//     if (global.formKey.currentState.validate()) {
//       setState(() {
//         isLoading = true;
//       });
//     Firestore.instance.
//     collection("Society").
//     document(global.societyId).
//     collection("Houses").
//     document(widget.house.houseId)
//         .updateData(
//         { "tokenNo": _controller.text}
//     );
//   }
// }
  updateActivationTokn() {
    if (global.formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
    Firestore.instance.
    collection("ActivationCode").
    document(widget.house.houseId)
        .updateData(
        { "tokenNo": _controller.text,
          "enable": true}
    );_showDialog();
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
          children: [
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.arrow_back_ios,color: UniversalVariables.background,),
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("Reset House ",style: TextStyle(fontWeight: FontWeight.w800,color: UniversalVariables.background,),),
                        ),
                      )

                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height/4.5,),
                 Form(
                   key: global.formKey,
                   child:  IgnorePointer(
                     child: constantTextField().InputField("Generate new token", "",
                         validationKey.activationCode, _controller, false,
                         IconButton(icon: Icon(Icons.add), onPressed: (){}), 1, 1,TextInputType.name,false)
                   ),
                 ),
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _controller.text = RandomString(10);
                        },
                        child: Card(
                          color: UniversalVariables.background,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Generate New Token",style:
                            TextStyle(color: UniversalVariables.ScaffoldColor,
                                fontWeight: FontWeight.w800,fontSize: 18),),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){


                          updateActivationTokn();

                        },
                        child: Card(
                          color: UniversalVariables.background,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 70,right: 70,top: 8,bottom: 8),
                            child: Text("Update",style:
                            TextStyle(color: UniversalVariables.ScaffoldColor,
                                fontWeight: FontWeight.w800,fontSize: 18),),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),]
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
                 global.RWATokenMsg + _controller.text,
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text('share Code'),
              onPressed: () async {
                var response = await FlutterShareMe().shareToSystem(msg:
                "hello,this is yor unique Code dont't share it with another " + _controller.text,);
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
