import 'dart:async';
import 'package:MyDen/bloc/AuthBloc.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/loginScreen/ActivationScreen.dart';
import 'package:MyDen/loginScreen/AdminSignIn.dart';
import 'package:MyDen/loginScreen/EmailVerifactionScreen.dart';
import 'package:MyDen/model/user_model.dart';
import 'package:MyDen/screens/checkAccessList.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MyDen/constants/global.dart' as global;




class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<UserData> _getUserData() async {
    print("getUserData -----------------");
    return await context.bloc<AuthBloc>().currentUser();
  }


  @override
  void initState() {
    _getUserData().then((fUser) {

      if(fUser!=null) {
        if(!fUser.emailVerified){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => EmailVerification()));
          }
        else if( fUser.accessList != null && fUser.accessList.length == 1 ) {
          global.societyId = fUser.accessList[0].id.toString();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TabBarScreen()));
        }
        else if ( fUser.accessList != null && fUser.accessList.length > 1){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => accessList()));


        }
        else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ActivationScreen()));
        }
      }
      else {
        print('Login Page');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: Container(
      height: MediaQuery.of(context).size.height,
         child: Stack(
           children: [
            CustomPaint(
              child: Container(
              height: 300.0,
            ),
            painter: CurvePainter(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        Text(
                          "MY Den",
                          style: TextStyle(
                              fontSize: 35,
                              color: UniversalVariables.background,
                              fontWeight: FontWeight.w800),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    ));
  }


}

