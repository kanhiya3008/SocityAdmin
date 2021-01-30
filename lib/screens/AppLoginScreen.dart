import 'dart:async';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lock_screen/flutter_lock_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/circle_input_button.dart';
import 'package:flutter_screen_lock/lock_screen.dart';
import 'package:local_auth/local_auth.dart';



// class PassCodeScreen extends StatefulWidget {
//   PassCodeScreen({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _PassCodeScreenState createState() => new _PassCodeScreenState();
// }
//
// class _PassCodeScreenState extends State<PassCodeScreen> {
//   bool isFingerprint = false;
//   final LocalAuthentication auth = LocalAuthentication();
//   bool _canCheckBiometrics;
//   List<BiometricType> _availableBiometrics;
//   String _authorized = 'Not Authorized';
//   bool _isAuthenticating = false;
//
//
//
//
//
//
//
//   Future<Null> biometrics() async {
//     final LocalAuthentication auth = new LocalAuthentication();
//     bool authenticated = false;
//
//     try {
//       authenticated = await auth.authenticateWithBiometrics(
//           localizedReason: 'Scan your fingerprint to authenticate',
//           useErrorDialogs: true,
//           stickyAuth: false);
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     if (!mounted) return;
//     if (authenticated) {
//       setState(() {
//         isFingerprint = true;
//       });
//     }
//   }
//
//   Future<void> _checkBiometrics() async {
//     bool canCheckBiometrics;
//     try {
//       canCheckBiometrics = await auth.canCheckBiometrics;
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     if (!mounted) return;
//
//     setState(() {
//       _canCheckBiometrics = canCheckBiometrics;
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     var myPass = [1, 2, 3, 4];
//     return Scaffold(
//       body: Container(
//         color:UniversalVariables.background,
//         child: LockScreen(
//             title: "This is Screet ",
//             passLength: myPass.length,
//             bgImage:"images/fingerprint1.png",
//             fingerPrintImage: "images/fingerprint.png",
//             showFingerPass: true,
//             fingerFunction: biometrics,
//             numColor: UniversalVariables.background,
//             fingerVerify: isFingerprint,
//             borderColor: Colors.white,
//             showWrongPassDialog: true,
//             wrongPassContent: "Wrong pass please try again.",
//             wrongPassTitle: "Opps!",
//             wrongPassCancelButtonText: "Cancel",
//             passCodeVerify: (passcode) async {
//               for (int i = 0; i < myPass.length; i++) {
//                 if (passcode[i] != myPass[i]) {
//                   return false;
//                 }
//               }
//
//               return true;
//             },
//             onSuccess: () {
//               Navigator.of(context).pushReplacement(
//                   new MaterialPageRoute(builder: (BuildContext context) {
//                     return SplashScreen();
//                   }));
//             }),
//       )
//     );
//   }
// }

class PassCodeScreen extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PassCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Open Lock Screen'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  onCompleted: (context, result) {
                    // if you specify this callback,
                    // you must close the screen yourself
                    Navigator.of(context).maybePop();
                  },
                  onUnlocked: () => print('Unlocked.'),
                ),
              ),
              RaisedButton(
                child: Text('6 Digits'),
                onPressed: () => showLockScreen(
                  context: context,
                  digits: 6,
                  correctString: '123456',
                ),
              ),
              RaisedButton(
                child: Text('Use local_auth'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  canBiometric: true,
                  // biometricButton is default Icon(Icons.fingerprint)
                  // When you want to change the icon with `BiometricType.face`, etc.
                  biometricButton: Icon(Icons.face),
                  biometricAuthenticate: (context) async {
                    final localAuth = LocalAuthentication();
                    final didAuthenticate =
                    await localAuth.authenticateWithBiometrics(
                        localizedReason: 'Please authenticate');

                    if (didAuthenticate) {
                      return true;
                    }

                    return false;
                  },
                  onUnlocked: () {
                    print('Unlocked.');
                  },
                ),
              ),
              RaisedButton(
                child: Text('Open biometric first'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  canBiometric: true,
                  showBiometricFirst: true,
                  biometricFunction: (context) async {
                    final localAuth = LocalAuthentication();
                    final didAuthenticate =
                        await localAuth.authenticateWithBiometrics(
                            localizedReason: 'Please authenticate');

                    if (didAuthenticate) {
                      Navigator.of(context).pop();
                    }
                  },
                  biometricAuthenticate: (_) async {
                    final localAuth = LocalAuthentication();
                    final didAuthenticate =
                    await localAuth.authenticateWithBiometrics(
                        localizedReason: 'Please authenticate');

                    if (didAuthenticate) {
                      return true;
                    }

                    return false;
                  },
                  onUnlocked: () => print('Unlocked.'),
                ),
              ),
              RaisedButton(
                child: Text('Can\'t cancel'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  canCancel: false,
                ),
              ),
              RaisedButton(
                child: Text('Customize text'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  cancelText: 'Close',
                  deleteText: 'Remove',
                ),
              ),
              RaisedButton(
                child: Text('Confirm mode.'),
                onPressed: () => showConfirmPasscode(
                  context: context,
                  onCompleted: (context, verifyCode) {
                    print(verifyCode);
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
              RaisedButton(
                child: Text('Change styles.'),
                onPressed: () => showLockScreen(
                  context: context,
                  correctString: '1234',
                  backgroundColor: Colors.grey.shade50,
                  backgroundColorOpacity: 1,
                  circleInputButtonConfig: CircleInputButtonConfig(
                    textStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.1,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.blue,
                    backgroundOpacity: 0.5,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.blue,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}