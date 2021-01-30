// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:residents/Constant/globalsVariable.dart' as global;
//
// class PayBill extends StatefulWidget {
//   final billingId;
//
//   const PayBill({Key key, this.billingId}) : super(key: key);
//
//   @override
//   _PayBillState createState() => _PayBillState();
// }
//
// class _PayBillState extends State<PayBill> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("PayBill"),
//       ),
//       body: Container(
//           height: MediaQuery.of(context).size.height,
//           child: Padding(
//             padding: EdgeInsets.all(15),
//             child: ListView(
//               children: [
//                 RaisedButton(
//                     onPressed: () {
//                       payBillOfResident();
//                     },
//                     child: Text("Pay Bill"))
//               ],
//             ),
//           )),
//     );
//   }
//
//   payBillOfResident() {
//     Firestore.instance
//         .collection(global.SOCIETY)
//         .document(global.mainId)
//         .collection("Billing")
//         .document(widget.billingId)
//         .setData({"enable": false},merge: true);
//     Fluttertoast.showToast(msg: 'Bill Pay Successfully');
//   }
// }
